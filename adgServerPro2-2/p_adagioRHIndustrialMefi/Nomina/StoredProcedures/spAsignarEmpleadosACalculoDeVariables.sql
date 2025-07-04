USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-15
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Nomina].[spAsignarEmpleadosACalculoDeVariables](    	
     @IDControlCalculoVariables int
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY
    ,@IDUsuario int = 0    
)
AS
BEGIN
    
    DECLARE 
        @IDBimestre                                 INT
       ,@Aplicar                                    BIT
       ,@Ejercicio                                  INT
       ,@IDRegPatronal                              INT
       ,@FechaInicioBimestre                        DATE  
	   ,@FechaFinBimestre                           DATE  
       ,@Empleados                                  [RH].[dtEmpleados]
       ,@EmpleadosTrabajables                       [RH].[dtEmpleados]
       ,@FechasUltimaVigencia                       [App].[dtFechas]
       ,@ListaFechasUltimaVigencia                  [App].[dtFechasVigenciaEmpleado]	   
       ,@FiltrosLocal                               [Nomina].[dtFiltrosRH]

    --- CONSTANTES
       ,@VALOR_APLICADO                             BIT = 1
       ,@CODIGO_MOV_AFILIATORIO_BAJA                VARCHAR(1) = 'B'

    --- TEMPORALES
    IF OBJECT_ID('tempdb..#tempMovBajas') IS NOT NULL DROP TABLE #tempMovBajas

    SELECT @IDBimestre     = IDBimestre 
          ,@Aplicar        = Aplicar
          ,@IDRegPatronal  = IDRegPatronal
          ,@Ejercicio      = Ejercicio
    FROM Nomina.tblControlCalculoVariablesBimestrales
    WHERE IDControlCalculoVariables = @IDControlCalculoVariables
    
    --- BEGIN VALIDACIONES
    IF @Aplicar = @VALOR_APLICADO
	BEGIN  
		RAISERROR('El cálculo ya ha sido aplicado y no se puede modificar en este estado', 16, 1);  
		RETURN;  
	END  

    IF EXISTS ( SELECT TOP 1 1 FROM Nomina.TblCalculoVariablesBimestralesMaster WHERE IDControlCalculoVariables=@IDControlCalculoVariables AND IDMovAfiliatorio IS NOT NULL)
    BEGIN
        RAISERROR('El cálculo cuenta con movimientos salariales aplicados y no se puede modificar en este estado', 16, 1);  
		RETURN;  
    END
   --- END VALIDACIONES

   INSERT INTO @FiltrosLocal(Catalogo,Value) VALUES ('RegPatronales',CAST(@IDRegPatronal AS VARCHAR(10)))  
   INSERT INTO @FiltrosLocal SELECT * FROM @dtFiltros
   
	      


   SELECT @FechaInicioBimestre = MIN(DATEADD(MONTH,IDMes-1,DATEADD(YEAR,@Ejercicio-1900,0)))   
   FROM Nomina.tblCatMeses WITH (NOLOCK)  
   WHERE CAST(IDMes AS VARCHAR) IN (SELECT item FROM app.Split( (SELECT TOP 1 meses FROM Nomina.tblCatBimestres WITH (NOLOCK) WHERE IDBimestre = @IDBimestre),','))  
   
   SET @FechaFinBimestre = [Asistencia].[fnGetFechaFinBimestre](@FechaInicioBimestre)


    

   INSERT INTO @Empleados  
   EXEC RH.spBuscarEmpleados 
    @FechaIni = @FechaInicioBimestre  
    ,@Fechafin = @FechaFinBimestre  
    ,@dtFiltros= @FiltrosLocal   
    ,@IDUsuario = @IDUsuario
    

   INSERT INTO @FechasUltimaVigencia
   EXEC [App].[spListaFechas] @FechaFinBimestre,@FechaFinBimestre    

   INSERT @ListaFechasUltimaVigencia
   EXEC [RH].[spBuscarListaFechasVigenciaEmpleado] @Empleados,@FechasUltimaVigencia,@IDUsuario

    SELECT m.*,ROW_NUMBER()OVER(PARTITION BY m.idempleado ORDER BY m.fecha DESC) RN
    INTO #tempMovBajas
    FROM @Empleados  E
	INNER JOIN IMSS.tblMovAfiliatorios M
	    ON E.IDEmpleado = M.IDEmpleado
	    AND m.Fecha >= e.FechaAntiguedad
		AND m.Fecha <= @fechaFinBimestre
		AND m.IDRegPatronal = @IDRegPatronal
	
	DELETE #tempMovBajas WHERE RN > 1
    
    DELETE #tempMovBajas WHERE IDTipoMovimiento <> (SELECT  IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos WHERE Codigo = @CODIGO_MOV_AFILIATORIO_BAJA)

    
	INSERT INTO @EmpleadosTrabajables  
		SELECT ev.*   
		FROM @Empleados ev  
			INNER JOIN @ListaFechasUltimaVigencia fuv 
				ON ev.IDEmpleado = fuv.IDEmpleado
				AND fuv.Vigente = 1
			LEFT JOIN IMSS.tblMovAfiliatorios mov WITH (NOLOCK)  
				on ev.IDEmpleado = mov.IDEmpleado  
			    AND mov.Fecha = DATEADD(DAY,1,@FechaFinBimestre)  
			LEFT JOIN Asistencia.tblIncidenciaEmpleado IE with(nolock)
				ON Ev.idEmpleado = IE.idempleado
				AND IE.IDIncidencia = 'I'
				AND IE.fecha = DATEADD(DAY,1,@FechaFinBimestre)
            LEFT JOIN #tempMovBajas bajas
                ON bajas.IDEmpleado = ev.IDEmpleado
		WHERE mov.IDMovAfiliatorio IS NULL   
		AND ie.IDIncidenciaEmpleado IS NULL
        AND bajas.IDEmpleado IS NULL

    MERGE [Nomina].[TblCalculoVariablesBimestralesMaster] AS TARGET      
		USING @EmpleadosTrabajables AS SOURCE      
		ON TARGET.IDEmpleado    = SOURCE.IDEmpleado AND      
           TARGET.IDControlCalculoVariables = @IDControlCalculoVariables
        WHEN MATCHED THEN
        UPDATE
        SET	
        TARGET.FechaAntiguedad = SOURCE.FechaAntiguedad,
        TARGET.IDTipoPrestacion = SOURCE.IDTipoPrestacion
		WHEN NOT MATCHED BY TARGET THEN       
		INSERT(IDEmpleado,IDControlCalculoVariables,FechaAntiguedad,IDTipoPrestacion)      
		VALUES(SOURCE.IDEmpleado,@IDControlCalculoVariables,SOURCE.FechaAntiguedad,SOURCE.IDTipoPrestacion)		
		WHEN NOT MATCHED BY SOURCE AND TARGET.IDControlCalculoVariables = @IDControlCalculoVariables AND TARGET.IDEmpleado NOT IN (SELECT IDEmpleado FROM @EmpleadosTrabajables)
        THEN       
		DELETE; 

END
GO
