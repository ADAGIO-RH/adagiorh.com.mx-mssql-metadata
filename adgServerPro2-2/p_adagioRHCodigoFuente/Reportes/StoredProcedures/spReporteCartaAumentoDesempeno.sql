USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteCartaAumentoDesempeno] (
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario			int  
) as

Declare @IdiomaSQL varchar(50)
	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL;
declare
			@dtEmpleados [RH].[dtEmpleados]
			,@IDControlAumentosDesempeno int
			,@FechaCarta DATE
            ,@NombreEvaluacion VARCHAR(MAX)
	;
	
	

    select @IDControlAumentosDesempeno = Isnull(CAST(Value AS INT),0)
	from @dtFiltros where Catalogo = 'IDControlAumentosDesempeno'


    select @FechaCarta = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaCarta'

    
        SELECT @NombreEvaluacion = STRING_AGG(CP.Nombre, ', ')
        FROM Nomina.tblControlAumentosDesempenoProyectos CADP
        INNER JOIN Evaluacion360.tblCatProyectos CP
            ON CP.IDProyecto = CADP.IDProyecto
        WHERE CADP.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
	



    SELECT m.ClaveEmpleado
          , CONCAT_WS(' ',
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Nombre), 1)), LOWER(SUBSTRING(Nombre, 2, LEN(Nombre)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(SegundoNombre), 1)), LOWER(SUBSTRING(SegundoNombre, 2, LEN(SegundoNombre)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Paterno), 1)), LOWER(SUBSTRING(Paterno, 2, LEN(Paterno)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Materno), 1)), LOWER(SUBSTRING(Materno, 2, LEN(Materno)))), '')
        )  as [NombreCompleto]
          ,@FechaCarta as FechaCarta
          ,CONCAT(
          FORMAT(@FechaCarta, 'dd'),
          ' de ',
          LOWER(FORMAT(@FechaCarta, 'MMMM')),
          ' del ',
          FORMAT(@FechaCarta, 'yyyy')
          ) as FechaCartaMM
          ,@NombreEvaluacion as NombreEvaluacion        
          ,FORMAT(D.SueldoActualMensual, 'C2', 'es-MX') AS SalarioAnteriorFormateado
          ,[Utilerias].[fnConvertNumerosALetrasContratosSICREA](CAST(d.SueldoActual AS VARCHAR(MAX))) AS SalarioAnteriorLetra
          ,FORMAT(D.SalarioDiarioMovimiento*C.DiasSueldoMensual, 'C2', 'es-MX') AS SalarioNuevoFormateado
          ,[Utilerias].[fnConvertNumerosALetrasContratosSICREA](CAST(D.SalarioDiarioMovimiento*C.DiasSueldoMensual AS VARCHAR(MAX))) AS SalarioNuevoLetra
          ,(
            SELECT 
                    STRING_AGG(
                        CONCAT_WS(' ',
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Nombre), 1)), LOWER(SUBSTRING(E.Nombre, 2, LEN(E.Nombre)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.SegundoNombre), 1)), LOWER(SUBSTRING(E.SegundoNombre, 2, LEN(E.SegundoNombre)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Paterno), 1)), LOWER(SUBSTRING(E.Paterno, 2, LEN(E.Paterno)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Materno), 1)), LOWER(SUBSTRING(E.Materno, 2, LEN(E.Materno)))), '')
                        )
                        , ', ')
                FROM Evaluacion360.tblEvaluacionesEmpleados EM    
                INNER JOIN Evaluacion360.TBLempleadosProyectos EP
                    ON EM.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
                INNER JOIN Evaluacion360.tblCatProyectos CP
                    ON EP.IDProyecto = CP.IDProyecto
                INNER JOIN Nomina.tblControlAumentosDesempenoProyectos P
                    ON P.IDControlAumentosDesempeno=@IDControlAumentosDesempeno AND CP.IDProyecto=P.IDProyecto                       
                INNER JOIN RH.tblEmpleadosMaster E
                    ON E.IDEmpleado=EM.IDEvaluador
                WHERE EP.IDEmpleado = D.IDEmpleado and EM.IDTipoRelacion=1
          ) AS NombreEvaluador
          ,(
            SELECT 
                    STRING_AGG(
                            E.Puesto
                        , ', ')
                FROM Evaluacion360.tblEvaluacionesEmpleados EM    
                INNER JOIN Evaluacion360.TBLempleadosProyectos EP
                    ON EM.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
                INNER JOIN Evaluacion360.tblCatProyectos CP
                    ON EP.IDProyecto = CP.IDProyecto
                INNER JOIN Nomina.tblControlAumentosDesempenoProyectos P
                    ON P.IDControlAumentosDesempeno=@IDControlAumentosDesempeno AND CP.IDProyecto=P.IDProyecto                       
                INNER JOIN RH.tblEmpleadosMaster E
                    ON E.IDEmpleado=EM.IDEvaluador
                WHERE EP.IDEmpleado = D.IDEmpleado and EM.IDTipoRelacion=1
          ) AS PuestoEvaluador
    FROM Nomina.tblControlAumentosDesempenoDetalle d
    INNER JOIN RH.TblEmpleadosMaster m
            ON m.IDEmpleado=d.IDEmpleado        
    INNER JOIN Nomina.tblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno=D.IDControlAumentosDesempeno
    WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno and ISNULL(SalarioDiarioMovimiento,0)>0 AND ExcluirColaborador <> -1
GO
