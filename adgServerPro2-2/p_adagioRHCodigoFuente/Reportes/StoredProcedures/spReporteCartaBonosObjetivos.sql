USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteCartaBonosObjetivos] (
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario			int  
) as

Declare @IdiomaSQL varchar(50)
	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL;
declare
			@dtEmpleados [RH].[dtEmpleados]
			,@IDControlBonosObjetivos int
			,@CODIGO_CONCEPTO_PTU VARCHAR(MAX) = '131'
      ,@FechaCarta DATE
      ,@EjercicioActual INT      
      ,@IDConceptoPTU INT
      ,@NombreCicloMedicion VARCHAR(MAX)
	;
	
	if object_id('tempdb..#ptuEmpleados') is not null drop table #ptuEmpleados;

    select @IDControlBonosObjetivos = Isnull(CAST(Value AS INT),0)
	from @dtFiltros where Catalogo = 'IDControlBonosObjetivos'


    select @FechaCarta = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaCarta'

    
        SELECT @NombreCicloMedicion = STRING_AGG(CCMO.Nombre, ', ')
        FROM Nomina.tblControlBonosObjetivosCiclosMedicion CB
        INNER JOIN Evaluacion360.tblCatCiclosMedicionObjetivos CCMO
            ON CCMO.IDCicloMedicionObjetivo=CB.IDCicloMedicionObjetivo
        WHERE CB.IDControlBonosObjetivos = @IDControlBonosObjetivos;


      SELECT @IDConceptoPTU = IDConcepto
                FROM Nomina.tblCatConceptos
                WHERE Codigo = @CODIGO_CONCEPTO_PTU;


      SELECT @EjercicioActual = DATEPART(YEAR, FechaReferencia)
      FROM Nomina.TblControlBonosObjetivos
      WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;


      ;WITH CTE AS (
              SELECT  
                  DP.IDEmpleado,
                  EM.NombreComercial,
                  ROW_NUMBER() OVER (PARTITION BY DP.IDEmpleado ORDER BY DP.IDEmpleado) AS RowNum
              FROM Nomina.tblDetallePeriodo DP
              INNER JOIN Nomina.tblCatPeriodos P
                  ON P.IDPeriodo = DP.IDPeriodo
              INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP
                  ON P.IDPeriodo = HEP.IDPeriodo 
                  AND DP.IDEmpleado = HEP.IDEmpleado
              INNER JOIN RH.tblEmpresa EM
                  ON EM.IdEmpresa = HEP.IDEmpresa
              WHERE P.Ejercicio = @EjercicioActual 
                  AND P.Cerrado = 1 
                  AND DP.IDConcepto = @IDConceptoPTU
      )
      SELECT 
          IDEmpleado,
          NombreComercial
      INTO #ptuEmpleados
      FROM CTE 
      WHERE RowNum = 1


    SELECT m.ClaveEmpleado
          , CONCAT_WS(' ',
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Nombre), 1)), LOWER(SUBSTRING(Nombre, 2, LEN(Nombre)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(SegundoNombre), 1)), LOWER(SUBSTRING(SegundoNombre, 2, LEN(SegundoNombre)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Paterno), 1)), LOWER(SUBSTRING(Paterno, 2, LEN(Paterno)))), ''),
                NULLIF(CONCAT(UPPER(LEFT(LOWER(Materno), 1)), LOWER(SUBSTRING(Materno, 2, LEN(Materno)))), '')
        )  as [NombreCompleto]
          ,@FechaCarta as FechaCarta
          ,C.Ejercicio as Ejercicio
          ,CONCAT(
          FORMAT(@FechaCarta, 'dd'),
          ' de ',
          LOWER(FORMAT(@FechaCarta, 'MMMM')),
          ' del ',
          FORMAT(@FechaCarta, 'yyyy')
          ) as FechaCartaMM
          ,@NombreCicloMedicion as NombreCicloMedicion        
          ,RPTU.NombreComercial AS RazonSocialPTU
          ,FORMAT(CASE WHEN D.CalibracionPTU = -1 THEN 0 WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU ELSE ISNULL(D.PTU,0) END, 'C2', 'es-MX') AS MontoPTU
          ,[Utilerias].[fnConvertNumerosALetrasContratosSICREA](CAST(CASE WHEN D.CalibracionPTU = -1 THEN 0 WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU ELSE ISNULL(D.PTU,0) END AS VARCHAR(MAX))) AS MontoPTULetra        
          ,FORMAT(CASE WHEN D.CalibracionComplemento = -1 THEN 0 WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento ELSE ISNULL(D.Complemento,0) END, 'C2', 'es-MX') AS MontoComplemento          
          ,[Utilerias].[fnConvertNumerosALetrasContratosSICREA](CAST(CASE WHEN D.CalibracionComplemento = -1 THEN 0 WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento ELSE ISNULL(D.Complemento,0) END AS VARCHAR(MAX))) AS MontoComplementoLetra        
          ,FORMAT(CASE WHEN D.CalibracionBonoFinal = -1 THEN 0 WHEN D.CalibracionBonoFinal > 0 THEN D.CalibracionBonoFinal ELSE ISNULL(D.BonoFinal,0) END, 'C2', 'es-MX') AS MontoBono          
          ,[Utilerias].[fnConvertNumerosALetrasContratosSICREA](CAST(CASE WHEN D.CalibracionBonoFinal = -1 THEN 0 WHEN D.CalibracionBonoFinal > 0 THEN D.CalibracionBonoFinal ELSE ISNULL(D.BonoFinal,0) END AS VARCHAR(MAX))) AS MontoBonoLetra        
          ,( 
            SELECT TOP 1 CONCAT_WS(' ',
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Nombre), 1)), LOWER(SUBSTRING(E.Nombre, 2, LEN(E.Nombre)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.SegundoNombre), 1)), LOWER(SUBSTRING(E.SegundoNombre, 2, LEN(E.SegundoNombre)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Paterno), 1)), LOWER(SUBSTRING(E.Paterno, 2, LEN(E.Paterno)))), ''),
                                NULLIF(CONCAT(UPPER(LEFT(LOWER(E.Materno), 1)), LOWER(SUBSTRING(E.Materno, 2, LEN(E.Materno)))), '')
                        )
            FROM Evaluacion360.tblAvanceObjetivoEmpleado A
              INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                ON OE.IDObjetivoEmpleado = A.IDObjetivoEmpleado
              INNER JOIN Nomina.tblControlBonosObjetivosCiclosMedicion CMO
                ON OE.IDCicloMedicionObjetivo = CMO.IDCicloMedicionObjetivo AND CMO.IDControlBonosObjetivos=@IDControlBonosObjetivos
              INNER JOIN Seguridad.tblUsuarios U
               ON U.IDUsuario=A.IDUsuario
              INNER JOIN RH.tblEmpleadosMaster E
              ON U.IDEmpleado=E.IDEmpleado
            WHERE OE.IDEmpleado=D.IDEmpleado
          ) AS NombreEvaluador
          ,(            
              SELECT TOP 1 E.Puesto
              FROM Evaluacion360.tblAvanceObjetivoEmpleado A
              INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                ON OE.IDObjetivoEmpleado = A.IDObjetivoEmpleado
              INNER JOIN Nomina.tblControlBonosObjetivosCiclosMedicion CMO
                ON OE.IDCicloMedicionObjetivo = CMO.IDCicloMedicionObjetivo AND CMO.IDControlBonosObjetivos=@IDControlBonosObjetivos
              INNER JOIN Seguridad.tblUsuarios U
               ON U.IDUsuario=A.IDUsuario
              INNER JOIN RH.tblEmpleadosMaster E
              ON U.IDEmpleado=E.IDEmpleado
              WHERE OE.IDEmpleado=D.IDEmpleado
          ) AS PuestoEvaluador
          ,RPTU.NombreComercial AS RazonSocialPTU
    FROM Nomina.tblControlBonosObjetivosDetalle d
    INNER JOIN RH.TblEmpleadosMaster m
            ON m.IDEmpleado=d.IDEmpleado        
    INNER JOIN Nomina.tblControlBonosObjetivos C
            ON C.IDControlBonosObjetivos=D.IDControlBonosObjetivos
    LEFT JOIN #ptuEmpleados RPTU
            ON RPTU.IDEmpleado = d.IDEmpleado    
    WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos AND  D.ExcluirColaborador <> -1--and ISNULL(SalarioDiarioMovimiento,0)>0
GO
