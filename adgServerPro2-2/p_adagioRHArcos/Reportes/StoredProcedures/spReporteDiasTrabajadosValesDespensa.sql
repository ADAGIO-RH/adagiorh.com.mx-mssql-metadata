USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteDiasTrabajadosValesDespensa](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

) AS

BEGIN

	DECLARE
		 @Ejercicio INT
		,@IDTipoNomina INT
		,@IDMes INT
		,@Periodo [Nomina].[dtPeriodos]
		,@FechaIni DATE
		,@FechaFin DATE
		,@Empleados [RH].[dtEmpleados]
		,@CodigoConceptoDiasPagados VARCHAR(5) = '005'
		,@IDConceptoDiasPagados INT
		,@CodigoConceptoDiasVacaciones VARCHAR(5) = '002'
		,@IDConceptoDiasVacaciones INT

		SELECT @Ejercicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
		SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @IDMes = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
		SELECT @IDConceptoDiasPagados = ISNULL(IDConcepto,0) FROM Nomina.tblCatConceptos WHERE Codigo = @CodigoConceptoDiasPagados
		SELECT @IDConceptoDiasVacaciones = ISNULL(IDConcepto,0) FROM Nomina.tblCatConceptos WHERE Codigo = @CodigoConceptoDiasVacaciones

		INSERT INTO @Periodo
		SELECT *
		FROM Nomina.tblCatPeriodos
		WHERE IDTipoNomina = @IDTipoNomina AND Ejercicio = @Ejercicio AND IDMes = @IDMes

		SELECT @FechaIni = MIN(FechaInicioPago) 
			  ,@FechaFin = MAX(FechaFinPago)
		FROM @Periodo

		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

		SELECT 
			 Clave
			,Nombre
			,CAST(Antiguedad AS VARCHAR(10)) AS Antiguedad
			,Estatus
			,(ISNULL(DiasPagados,0) + ISNULL(DiasVacaciones,0)) AS DiasPagados
			,CASE WHEN (ISNULL(DiasPagados,0) + ISNULL(DiasVacaciones,0)) >= 16 THEN 'SI' ELSE 'NO' END AS PagarVales
		FROM
			(SELECT 
				 E.ClaveEmpleado AS Clave
				,E.NOMBRECOMPLETO AS Nombre
				,E.FechaAntiguedad AS Antiguedad
				,CASE WHEN M.Vigente = 1 THEN 'VIGENTE' ELSE 'BAJA' END AS Estatus
				,AcumDiasPagados.ImporteTotal1 AS DiasPagados
				,AcumDiasVacaciones.ImporteTotal1 AS DiasVacaciones
			FROM @Empleados E
				 LEFT JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = E.IDEmpleado
				 CROSS APPLY [Nomina].[fnObtenerAcumuladoPorConceptoPorMes_ARCOS](E.IDEmpleado,@IDConceptoDiasPagados,@IDMes,@Ejercicio) AS AcumDiasPagados
				 CROSS APPLY [Nomina].[fnObtenerAcumuladoPorConceptoPorMes_ARCOS](E.IDEmpleado,@IDConceptoDiasVacaciones,@IDMes,@Ejercicio) AS AcumDiasVacaciones) DiasVales
		ORDER BY Clave
END
GO
