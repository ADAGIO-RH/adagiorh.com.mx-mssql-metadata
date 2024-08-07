USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteBasicoReporteISNImpreso_SURFAX]( 

	 @Cliente	        VARCHAR(MAX) = ''      
	,@TipoNomina        VARCHAR(MAX)     
	,@Ejercicio	        VARCHAR(MAX)       
	,@IDMes		        VARCHAR(MAX)       
	,@RazonesSociales	VARCHAR(MAX)      
	,@RegPatronales		VARCHAR(MAX)      
	,@Sucursales		VARCHAR(MAX)   
	,@IDUsuario			INT        

) AS   

BEGIN

	SET FMTONLY OFF 
	
	DECLARE 
		 @EmpleadosTemp [RH].[dtEmpleados]             
		,@Periodo [Nomina].[dtPeriodos]       
		,@dtFiltros [Nomina].[dtFiltrosRH]       
		,@IDConcepto540 INT  
		,@IDIdioma VARCHAR(10)
		,@dtFiltrosBuscarEmpleados [Nomina].[dtFiltrosRH]  
		,@Conceptos VARCHAR(MAX)
		,@Sucursal INT
		,@IDEstadoSucursal INT 
	;        

	SELECT @IDIdioma = APP.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
   
	SELECT @IDConcepto540 = IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo = '540'
	
	INSERT INTO @dtFiltros(Catalogo,Value)      
	VALUES ('RazonesSociales',@RazonesSociales)      
		  ,('RegPatronales',@RegPatronales)      
		  ,('Sucursales',@Sucursales) 
		  
	SELECT @Sucursal = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFIltros WHERE Catalogo = 'Sucursales'),',')),0)
	SELECT @IDEstadoSucursal = ISNULL(IDEstadoSTPS,'') FROM RH.tblCatSucursales WHERE IDSucursal = @Sucursal
              
	INSERT INTO @Periodo      
	SELECT *
		-- IDPeriodo      
		--,IDTipoNomina      
		--,Ejercicio      
		--,ClavePeriodo      
		--,Descripcion      
		--,FechaInicioPago      
		--,FechaFinPago      
		--,FechaInicioIncidencia      
		--,FechaFinIncidencia      
		--,Dias      
		--,AnioInicio      
		--,AnioFin      
		--,MesInicio      
		--,MesFin      
		--,IDMes      
		--,BimestreInicio      
		--,BimestreFin      
		--,Cerrado      
		--,General      
		--,Finiquito      
		--,ISNULL(Especial,0)      
	FROM Nomina.tblCatPeriodos      
	WHERE Ejercicio = @Ejercicio AND IDTipoNomina = @TipoNomina AND IDMes = @IDMes       
               
    INSERT INTO @EmpleadosTemp            
    EXEC [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltrosBuscarEmpleados, @IDUsuario = @IDUsuario

	DECLARE 
	 @CodigoConceptoISN VARCHAR(10) = '540'
	,@IDEmpresa INT

	SELECT @Conceptos = (SELECT STRING_AGG(CONVERT(NVARCHAR(MAX),Codigo),',') FROM Nomina.tblCatConceptos WHERE (IDTipoConcepto = 1 OR IDConcepto = @IDConcepto540) AND IDConcepto NOT IN (SELECT Item FROM App.Split((SELECT IDConceptos FROM Nomina.tblConfigISN WHERE IDEstado = @IDEstadoSucursal),','))) 
	SELECT @IDEmpresa = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RazonesSociales'),',')),0)

	DECLARE @EmpleadoISN TABLE(

		 IDEmpleado INT 
		,ClaveEmpleado VARCHAR(20)
		,Colaborador VARCHAR(MAX)
		,IDConcepto INT
		,CodigoConcepto VARCHAR(10)
		,Concepto VARCHAR(500)
		,Periodo INT
		,Total DECIMAL(18,2)
		,OrdenCalculo INT 
	);

	INSERT INTO @EmpleadoISN
	EXEC [Nomina].[spBuscarAcumuladoPorMesyEmpresaConceptosEmpleados_SURFAX] @Ejercicio = @Ejercicio,@CodigosConceptos = @Conceptos,@dtEmpleados = @EmpleadosTemp,@IDUsuario = @IDUsuario,@IDEmpresa = @IDEmpresa,@IDMes = @IDMes
	
	IF OBJECT_ID('TempDB..#TempData') IS NOT NULL DROP TABLE #TempData
	IF OBJECT_ID('TempDB..#TempData2') IS NOT NULL DROP TABLE #TempData2

	SELECT 
		  HEP.IDPeriodo AS IDPeriodo
		 ,HEP.IDEmpleado AS IDEmpleado
		 ,E.ClaveEmpleado AS ClaveEmpleado
		 ,E.NOMBRECOMPLETO AS NombreCompleto
		 ,ISNULL(HEP.Departamento,'SIN DEPARTAMENTO') AS Departamento
		 ,ISNULL(HEP.Sucursal,'SIN SUCURSAL') AS Sucursal
		 ,ISNULL(HEP.Puesto,'SIN PUESTO') AS Puesto
		 ,ISNULL(HEP.RazonSocial,'SIN RAZON SOCIAL') AS RazonSocial
		 ,ISNULL(HEP.RegistroPatronal,'SIN REGISTRO PATRONAL') AS Registro_Patronal
		 ,ISN.OrdenCalculo AS OrdenCalculo
		 ,ISN.CodigoConcepto+' '+ISN.Concepto AS Concepto
		 ,ISNULL(ISN.Total,0) AS Importe_ISN
		 ,ISNULL(ConfigISN.Porcentaje,0) AS Porcentaje
		 ,JSON_VALUE(Mes.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma,'-','')), 'Descripcion')) AS Mes
		 ,ISN.CodigoConcepto AS CodigoConcepto
	INTO #TempData
	FROM @Periodo P
	INNER JOIN (
				SELECT 
					 HEP.IDHistorialEmpleadoPeriodo
					,HEP.IDPeriodo
					,HEP.IDEmpleado
					,HEP.IDRegPatronal
					,D.Descripcion AS Departamento
					,S.Descripcion AS Sucursal
					,P.Descripcion AS Puesto
					,E.NombreComercial AS RazonSocial
					,R.RazonSocial AS RegistroPatronal
				FROM Nomina.tblHistorialesEmpleadosPeriodos HEP
				INNER JOIN RH.tblCatDepartamentos D ON D.IDDepartamento = HEP.IDDepartamento
				INNER JOIN RH.tblCatSucursales S ON S.IDSucursal= HEP.IDSucursal
				INNER JOIN RH.tblCatPuestos P ON P.IDPuesto = HEP.IDPuesto
				INNER JOIN RH.tblEmpresa E ON E.IDEmpresa = HEP.IDEmpresa
				INNER JOIN RH.tblCatRegPatronal R ON R.IDRegPatronal = HEP.IDRegPatronal
				WHERE HEP.IDPeriodo IN (SELECT IDPeriodo FROM @Periodo)) HEP ON HEP.IDPeriodo = P.IDPeriodo
	INNER JOIN @EmpleadosTemp E ON E.IDEmpleado = HEP.IDEmpleado
	INNER JOIN @EmpleadoISN ISN ON ISN.IDEmpleado = E.IDEmpleado AND ISN.Periodo = P.IDPeriodo
	INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = E.IDEmpleado
	INNER JOIN Nomina.tblCatMeses Mes ON Mes.IDMes = P.IDMes
	,(SELECT * FROM Nomina.tblConfigISN WHERE IDEstado = @IDEstadoSucursal) ConfigISN
	WHERE /*M.Vigente = 1 
		  AND*/ E.IDTipoNomina = @TipoNomina
		  AND HEP.IDRegPatronal IN (ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RegPatronales'),',')),0))
  
	SELECT
		 ClaveEmpleado
		,NombreCompleto
		,Departamento
		,Sucursal
		,Puesto
		,RazonSocial
		,Registro_Patronal AS Registro_Patronal
		,OrdenCalculo
		,Concepto
		,SUM(ISNULL(Importe_ISN,0)) AS Importe_ISN
		,Porcentaje
		,Mes
		,CodigoConcepto
	INTO #TempData2
	FROM #TempData 
	GROUP BY 
		 ClaveEmpleado
		,NombreCompleto
		,Departamento
		,Sucursal
		,Puesto
		,RazonSocial
		,Registro_Patronal
		,OrdenCalculo
		,Concepto
		,Porcentaje
		,Mes
		,CodigoConcepto
	ORDER BY ClaveEmpleado, CodigoConcepto

	INSERT INTO #TempData2
	SELECT  
		 ClaveEmpleado
		,NombreCompleto
		,Departamento
		,Sucursal
		,Puesto
		,RazonSocial
		,Registro_Patronal AS Registro_Patronal
		,0 AS OrdenCalculo 
		,'000'+' - '+'TOTAL BASE' AS Concepto   
		,SUM(Importe_ISN) as Importe_ISN 
		,Porcentaje  
		,Mes  
		,'000'CodigoConcepto
	FROM #TempData2
	WHERE CodigoConcepto <> '540'
	GROUP BY
		ClaveEmpleado,  
		NombreCompleto,  
		Departamento,    
		Sucursal,    
		Puesto,      
		RazonSocial,    
		Registro_Patronal,    
		Porcentaje,
		Mes
    
   SELECT * FROM #TempData2
   ORDER BY ClaveEmpleado, CodigoConcepto

END
GO
