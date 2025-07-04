USE [p_adagioRHIndustrialMefi]
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
2024-01-11		    Jose Vargas		Se añade el sp [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios], despues de realizar modificaciones a la tabla de "IMSS.tblMovAfiliatorios" 
                                    para realizar el calculo de "FechaAntiguedad" y "IDTipoPrestacion"
 ***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spGenerarNuevoIntegradoAlCalcularNomina](
	@IDPeriodo int,
	@empleados [RH].[dtEmpleados] READONLY
)
AS
BEGIN
--select * from @Empleados
declare 
	@UMA decimal(18,4),
	@TOPEUMA decimal(18,2),
	@Ejercicio int


	if object_id('tempdb..#tempMovimientosAniversarioAntiguedad') is not null drop table #tempMovimientosAniversarioAntiguedad; 
	
	 SELECT @Ejercicio = Ejercicio
	 FROM Nomina.tblcatPeriodos p WITH(NOLOCK)
	 WHERE p.IDPeriodo = @IDPeriodo


	SELECT TOP 1 @UMA = UMA
		,@TOPEUMA = UMA * 25.0-- Aqui se obtiene el valor de la UMA del catalogo de Salarios minimos  
	FROM Nomina.tblSalariosMinimos  WITH(NOLOCK)
	WHERE Year(Fecha) = @Ejercicio  
	ORDER BY Fecha DESC

	IF @UMA is null OR ISNULL(@UMA,0) = 0  
    BEGIN  
		RAISERROR ('El valor de la UMA para este ejercicio no ha sido capturado', 16, 1);  
		RETURN 1;  
    END 

	
	SET DATEFIRST 5;

	SELECT DISTINCT e.IDEmpleado 
	, dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(P.Ejercicio as varchar(4))+'-01-01' as date))) FechaActual
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
	FROM @Empleados e
		inner join RH.tblEmpleadosMaster master with(nolock)
			on master.IDEmpleado = e.IDEmpleado
		INNER JOIN Nomina.tblCatPeriodos p  WITH(NOLOCK)
			on p.IDPeriodo = @IDPeriodo
		LEFT JOIN IMSS.tblMovAfiliatorios mov	 WITH(NOLOCK)
			on mov.IDEmpleado = e.IDEmpleado
			and Mov.Fecha = dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(P.Ejercicio as varchar(4))+'-01-01' as date))) 
		INNER JOIN RH.tblCatTiposPrestacionesDetalle tpd  WITH(NOLOCK)
			on tpd.IDTipoPrestacion = e.IDTipoPrestacion
			and tpd.Antiguedad = CAST(datediff(year, e.FechaAntiguedad , dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(P.Ejercicio as varchar(4))+'-01-01' as date)))  ) +1 as int)
		CROSS APPLY [IMSS].[fnObtenerUltimoMovimientoEmpleado](e.IDEmpleado) as LastMov
	WHERE 
	dateadd(day,datepart(day,e.fechaantiguedad)-1,dateadd(month,datepart(month,e.FechaAntiguedad)-1,CAST(CAST(P.Ejercicio as varchar(4))+'-01-01' as date))) between p.FechaInicioPago and p.FechaFinPago
	and master.Vigente = 1
	and [Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad, p.FechaFinPago) >= 1
	and lastmov.IDTipoMovimiento <> 2
	and mov.IDMovAfiliatorio  is null;
	
	--select * from #tempMovimientosAniversarioAntiguedad
    CREATE TABLE #IdentityMovAfiliatorios (IDMovAfiliatorio INT);

	MERGE IMSS.tblMovAfiliatorios AS TARGET                  
	USING #tempMovimientosAniversarioAntiguedad AS SOURCE                  
	ON (TARGET.IDEmpleado = SOURCE.IDEmpleado                   
			and TARGET.Fecha = SOURCE.FechaActual)                              
	WHEN NOT MATCHED BY TARGET THEN                   
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
        OUTPUT INSERTED.IDMovAfiliatorio INTO #IdentityMovAfiliatorios;        

        --DECLARE @CurrentIdentity INT;                
        --SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
        --FROM #IdentityMovAfiliatorios;                
        --WHILE @CurrentIdentity IS NOT NULL
        --BEGIN
        --    exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios] @IDMovAfiliatorio=@CurrentIdentity;
        --    SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
        --    FROM #IdentityMovAfiliatorios
        --    WHERE IDMovAfiliatorio > @CurrentIdentity;
        --END;
        
END
GO
