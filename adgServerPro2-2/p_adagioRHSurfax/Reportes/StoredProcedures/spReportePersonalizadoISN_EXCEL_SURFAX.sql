USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePersonalizadoISN_EXCEL_SURFAX](   

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY        
	,@IDUsuario INT
	
) AS      

BEGIN
        
	DECLARE 
		 @Empleados [RH].[dtEmpleados]            
		,@Periodo [Nomina].[dtPeriodos]  
		,@IDConcepto540	INT    
		,@dtFiltrosEmpleados [Nomina].[dtFiltrosRH]
		,@Descripcion_Concepto_540 VARCHAR(250)
	;        
      
	SELECT @IDConcepto540 = IDConcepto FROM Nomina.tblCatConceptos WITH (NOLOCK) WHERE Codigo = '540'  
	SELECT @Descripcion_Concepto_540 = REPLACE(REPLACE(REPLACE(Descripcion+'_'+Codigo,' ','_'),'-',''),'.','') FROM Nomina.tblCatConceptos WHERE Codigo = '540'
        
	INSERT INTO @Periodo      
	SELECT *      
	FROM Nomina.tblCatPeriodos WITH (NOLOCK)       
	WHERE (((IDTipoNomina IN (SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')) OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'TipoNomina' AND ISNULL(Value,'')<>'')))                       
		  AND IDMes IN (SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),','))   
		  AND Ejercicio IN (SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),','))))                      
            
    INSERT INTO @Empleados            
    EXEC [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltrosEmpleados, @IDUsuario = @IDUsuario   

	DECLARE 
	 @Ejercicio INT
	,@CodigoConceptoISN VARCHAR(10) = '540'
	,@IDEmpresa INT
	,@IDMes INT

	SELECT @Ejercicio = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
	SELECT @IDEmpresa = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RazonesSociales'),',')),0)
	SELECT @IDMes = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)

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
	EXEC [Nomina].[spBuscarAcumuladoPorMesyEmpresaConceptosEmpleados_SURFAX] @Ejercicio = @Ejercicio,@CodigosConceptos = @CodigoConceptoISN,@dtEmpleados = @empleados,@IDUsuario = @IDUsuario,@IDEmpresa = @IDEmpresa,@IDMes = @IDMes
	
	IF OBJECT_ID('TempDB..#TempData') IS NOT NULL DROP TABLE #TempData

	SELECT 
		  HEP.IDPeriodo
		 ,HEP.IDEmpleado
		 ,E.ClaveEmpleado AS ClaveEmpleado
		 ,E.NOMBRECOMPLETO AS NombreCompleto
		 ,ISNULL(HEP.Departamento,'SIN DEPARTAMENTO') AS Departamento
		 ,ISNULL(HEP.Sucursal,'SIN SUCURSAL') AS Sucursal
		 ,ISNULL(HEP.Puesto,'SIN PUESTO') AS Puesto
		 ,ISNULL(HEP.RazonSocial,'SIN RAZON SOCIAL') AS RazonSocial
		 ,ISNULL(HEP.RegistroPatronal,'SIN REGISTRO PATRONAL') AS RegistroPatronal
		 ,@Descripcion_Concepto_540 AS Concepto
		 ,ISN.Total AS Importe_ISN
	INTO #TempData
	FROM @periodo P
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
				WHERE HEP.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)) HEP ON HEP.IDPeriodo = P.IDPeriodo
	INNER JOIN @empleados E ON E.IDEmpleado = HEP.IDEmpleado
	INNER JOIN @EmpleadoISN ISN ON ISN.IDEmpleado = E.IDEmpleado AND ISN.Periodo = P.IDPeriodo
	INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = E.IDEmpleado
	WHERE M.Vigente = 1 
		  AND E.IDTipoNomina IN (ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0))
		  AND HEP.IDRegPatronal IN (ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RegPatronales'),',')),0))

	SELECT
		  ClaveEmpleado
		 ,NombreCompleto
		 ,Departamento
		 ,Sucursal
		 ,Puesto
		 ,RazonSocial
		 ,RegistroPatronal
		 ,Concepto
		 ,SUM(Importe_ISN) AS Importe_ISN
	FROM #TempData
	GROUP BY 
		  ClaveEmpleado
		 ,NombreCompleto
		 ,Departamento
		 ,Sucursal
		 ,Puesto
		 ,RazonSocial
		 ,RegistroPatronal
		 ,Concepto
	ORDER BY Sucursal, ClaveEmpleado, NombreCompleto

END
GO
