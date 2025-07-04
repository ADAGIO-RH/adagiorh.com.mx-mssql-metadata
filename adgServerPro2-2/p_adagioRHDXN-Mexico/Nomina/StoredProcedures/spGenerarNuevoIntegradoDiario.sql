USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ?
** Autor			: ?
** Email			: ?
** FechaCreacion	: ?
** Paremetros		:  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2025-02-20		    JOSE ROMAN		Procedimiento para asignar nuevos movimientos afiliatorios por 
									dia, para cambio de factor de integración. 
 ***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spGenerarNuevoIntegradoDiario]--'2025-01-07'
(
	@Fecha date = null
)
AS
BEGIN
--select * from @Empleados


declare 
	@UMA decimal(18,4),
	@TOPEUMA decimal(18,2),
	@Ejercicio int,
	@CalcularIntegradoAutomatico bit = 0;


	SELECT @CalcularIntegradoAutomatico = CAST(isnull(Valor,0) as bit )
	from Nomina.tblconfiguracionNomina with(nolock)
	where Configuracion = 'CalcularIntegradoAutomatico'

	IF(@CalcularIntegradoAutomatico <> 1)
	BEGIN
		RETURN;
	END

	IF(ISNULL(@Fecha,'') = '')
	BEGIN
		SET @Fecha = CAST(getdate() as date)
	END


	if object_id('tempdb..#tempMovimientosAniversarioAntiguedad') is not null drop table #tempMovimientosAniversarioAntiguedad; 
	
	 --SELECT @Ejercicio = Ejercicio
	 --FROM Nomina.tblcatPeriodos p WITH(NOLOCK)
	 --WHERE p.IDPeriodo = @IDPeriodo


	SELECT TOP 1 @UMA = UMA
		,@TOPEUMA = UMA * 25.0-- Aqui se obtiene el valor de la UMA del catalogo de Salarios minimos  
	FROM Nomina.tblSalariosMinimos  WITH(NOLOCK)
	WHERE Year(Fecha) = YEAR(@Fecha)  
	ORDER BY Fecha DESC

	IF @UMA is null OR ISNULL(@UMA,0) = 0  
    BEGIN  
		RAISERROR ('El valor de la UMA para este ejercicio no ha sido capturado', 16, 1);  
		RETURN 1;  
    END 

	
	SET DATEFIRST 7;

	SELECT DISTINCT e.IDEmpleado 
	, dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(YEAR(@Fecha) as varchar(4))+'-01-01' as date))) FechaActual
	, tpd.Factor
	, e.IDRegPatronal
	, e.SalarioDiario
	, e.SalarioVariable
	, e.SalarioIntegrado
	, e.SalarioDiarioReal
	, CAST(CASE WHEN ((e.SalarioDiario * tpd.Factor) + e.SalarioVariable) >= @TOPEUMA THEN @TOPEUMA
		ELSE ((e.SalarioDiario * tpd.Factor) + e.SalarioVariable)
		END as decimal(18,2)) NuevoIntegrado
	
	INTO #tempMovimientosAniversarioAntiguedad
	FROM  RH.tblEmpleadosMaster e with(nolock)
		
		LEFT JOIN IMSS.tblMovAfiliatorios mov	 WITH(NOLOCK)
			on mov.IDEmpleado = e.IDEmpleado
			and Mov.Fecha = dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(YEAR(@Fecha) as varchar(4))+'-01-01' as date))) 
		INNER JOIN RH.tblCatTiposPrestacionesDetalle tpd  WITH(NOLOCK)
			on tpd.IDTipoPrestacion = e.IDTipoPrestacion
			and tpd.Antiguedad = CAST(datediff(year, e.FechaAntiguedad , dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(YEAR(@Fecha) as varchar(4))+'-01-01' as date)))  ) +1 as int)
		CROSS APPLY [IMSS].[fnObtenerUltimoMovimientoEmpleado](e.IDEmpleado) as LastMov
	WHERE 
	dateadd(day,datepart(day,e.FechaAntiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(YEAR(@Fecha) as Varchar(4))+'-01-01' as date))) = @Fecha
	and e.Vigente = 1
	and [Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad, @Fecha) >= 1
	and lastmov.IDTipoMovimiento <> 2
	and mov.IDMovAfiliatorio  is null;
	
	select * from #tempMovimientosAniversarioAntiguedad
	--where IDRegPatronal in (SELECT IDRegPatronal from RH.tblCatRegPatronal)
    DECLARE @IdentityMovAfiliatorios TABLE (IDMovAfiliatorio INT);
    DECLARE @IdentityEmpleados TABLE (IDEmpleado INT);

	MERGE IMSS.tblMovAfiliatorios AS TARGET                  
	USING #tempMovimientosAniversarioAntiguedad AS SOURCE                  
	ON (TARGET.IDEmpleado = SOURCE.IDEmpleado                   
			and TARGET.Fecha = SOURCE.FechaActual
			)                              
	WHEN NOT MATCHED BY TARGET and SOURCE.IDRegPatronal in (SELECT IDRegPatronal from RH.tblCatRegPatronal) THEN                   
	INSERT(IDEmpleado
				,Fecha
				,IDTipoMovimiento
				,SalarioDiario
				,SalarioIntegrado
				,SalarioVariable
				,SalarioDiarioReal
				,IDRegPatronal
				,RespetarAntiguedad
			)                  
		VALUES(
			 SOURCE.IDEmpleado
			,SOURCE.FechaActual
			,4
			,SOURCE.SalarioDiario
			,SOURCE.NuevoIntegrado
			,SOURCE.SalarioVariable
			,SOURCE.SalarioDiarioReal
			,SOURCE.IDRegPatronal
			,0
		)
        OUTPUT INSERTED.IDMovAfiliatorio INTO @IdentityMovAfiliatorios
		;        



		select * from @IdentityMovAfiliatorios

        DECLARE @CurrentIdentity INT;                
        SELECT TOP 1 @CurrentIdentity = MIN(IDMovAfiliatorio)
        FROM @IdentityMovAfiliatorios;                
        WHILE @CurrentIdentity IS NOT NULL
        BEGIN
			select @CurrentIdentity
            exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios] @IDMovAfiliatorio=@CurrentIdentity;
            SELECT TOP 1 @CurrentIdentity = MIN(IDMovAfiliatorio)
            FROM @IdentityMovAfiliatorios
            WHERE IDMovAfiliatorio > @CurrentIdentity;
        END;
        
		DECLARE @html VARCHAR(MAX);

SET @html = 
    '<table border=''1'' style=''border-collapse:collapse;font-size:12px;''>
        <tr>
            <th>Fecha Actual</th>
            <th>Clave Empleado</th>
            <th>Nombre Completo</th>
            <th>Factor Integración</th>
            <th>Registro Patronal</th>
            <th>Salario Diario</th>
            <th>Salario Variable</th>
            <th>Salario Integrado</th>
            <th>Nuevo Salario Integrado</th>
            <th>Aplicado</th>
        </tr>' +

    (SELECT 
        '<tr>' + 
        '<td>' + FORMAT(AN.FechaActual, 'yyyy-MM-dd') + '</td>' +
        '<td>' + M.ClaveEmpleado + '</td>' +
        '<td>' + M.NombreCompleto + '</td>' +
        '<td>' + CAST(AN.Factor AS VARCHAR) + '</td>' +
        '<td>' + M.RegPatronal + '</td>' +
        '<td>' + CAST(AN.SalarioDiario AS VARCHAR) + '</td>' +
        '<td>' + CAST(AN.SalarioVariable AS VARCHAR) + '</td>' +
        '<td>' + CAST(AN.SalarioIntegrado AS VARCHAR) + '</td>' +
        '<td>' + CAST(AN.NuevoIntegrado AS VARCHAR) + '</td>' +
        '<td>' + CAST(CASE WHEN Mov.IDMovAfiliatorio IS NULL THEN 'NO' ELSE 'SI' END AS VARCHAR) + '</td>' +
        '</tr>'
    FROM #tempMovimientosAniversarioAntiguedad AN
		inner join RH.tblEmpleadosMaster M
			on AN.IDEmpleado = M.IDEmpleado
		left join IMSS.tblMovAfiliatorios movimientos
			on movimientos.IDEmpleado = AN.IDEmpleado
			and movimientos.Fecha = an.FechaActual
			and movimientos.IDTipoMovimiento = 4
		Left Join @IdentityMovAfiliatorios Mov
			on movimientos.IDMovAfiliatorio = Mov.IDMovAfiliatorio
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')

    + '</table>';
	print @html
EXEC [App].[spINotificacionesEspeciales_CalculoAplicacionNuevoIntegrado] @html;


END
GO
