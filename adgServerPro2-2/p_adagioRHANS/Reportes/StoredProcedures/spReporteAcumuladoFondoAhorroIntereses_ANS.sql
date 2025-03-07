USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAcumuladoFondoAhorroIntereses_ANS](
	

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT


) AS


BEGIN


		DECLARE
			@FechaIni DATE = CAST(GETDATE() AS DATE)
		   ,@FechaFin DATE = CAST(GETDATE() AS DATE)
		   ,@IDTipoNomina INT = 0
		   ,@Ejercicio INT
		   ,@Empleados [RH].[dtEmpleados]
		   ,@IDEmpleado INT
		   ,@Counter INT
		   ,@IDFondoAhorro INT
		   ,@InteresesARepartir DECIMAL(18,2)
		   ,@dtFiltrosBuscarEmpleados [Nomina].[dtFiltrosRH]
		   ,@TotalGlobalFA DECIMAL(18,2)
		   ,@CodigoConceptoInteresesFA VARCHAR(10) = '164'
		   ,@IDConceptoInteresesFA INT


		SELECT @Ejercicio = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)


		SELECT TOP 1 @IDConceptoInteresesFA = IDconcepto FROM Nomina.tblCatConceptos WHERE Codigo = @CodigoConceptoInteresesFA


		SELECT @InteresesARepartir = ISNULL((SELECT CAST(Item AS Decimal(18,2)) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),0)


		INSERT INTO @dtFiltrosBuscarEmpleados 
		SELECT * FROM @dtFiltros WHERE Catalogo <> 'ClaveEmpleadoInicial'


		IF OBJECT_ID('TempDB..#TempFondos') IS NOT NULL DROP TABLE #TempFondos


		SELECT * 
		INTO #TempFondos 
		FROM Nomina.tblCatFondosAhorro 
		WHERE Ejercicio = @Ejercicio


		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @IDTipoNomina = @IDTipoNomina, @dtFiltros = @dtFiltrosBuscarEmpleados, @IDUsuario = @IDUsuario


		IF OBJECT_ID('TempDB..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados

		SELECT *
		,0 AS IDFondoAhorro 
		INTO #TempEmpleados
		FROM @Empleados


		UPDATE T SET IDFondoAhorro =  F.IDFondoAhorro
		FROM #TempEmpleados T
		INNER JOIN #TempFondos F 
			ON F.IDTipoNomina = T.IDTipoNomina


		SELECT @Counter = MIN(IDEmpleado) FROM #TempEmpleados


		DECLARE @Totales TABLE (
			 IDEmpleado			            INT
			,TotalAportacionesEmpresa		DECIMAL(18,2)
			,TotalAportacionesTrabajador	DECIMAL(18,2)
			,TotalDevolucionesEmpresa		DECIMAL(18,2)
			,TotalDevolucionesTrabajador	DECIMAL(18,2)
			,TotalRetirosEmpresa			DECIMAL(18,2)
			,TotalRetirosTrabajador		    DECIMAL(18,2)
			,TotalAcumulado				    DECIMAL(18,2)
			,TotalPrestamosFondoAhorro		DECIMAL(18,2)
			,TotalSaldoPendienteADescontar	DECIMAL(18,2)
			,NetoDisponible                 DECIMAL(18,2)
			,Intereses						DECIMAL(18,2)
		);


		WHILE @Counter <= (SELECT MAX(IDEmpleado) FROM #TempEmpleados)
			
			BEGIN 

				SELECT @IDEmpleado = IDEmpleado FROM #TempEmpleados WHERE IDEmpleado = @Counter
				SELECT @IDFondoAhorro = IDFondoAhorro FROM #TempEmpleados WHERE IDEmpleado = @IDEmpleado

				INSERT INTO @Totales (TotalAportacionesEmpresa,TotalAportacionesTrabajador,TotalDevolucionesEmpresa,TotalDevolucionesTrabajador,TotalRetirosEmpresa,TotalRetirosTrabajador,TotalAcumulado,TotalPrestamosFondoAhorro,TotalSaldoPendienteADescontar,NetoDisponible)
				EXEC [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado] @IDFondoAhorro = @IDFondoAhorro, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario

				UPDATE @Totales SET IDEmpleado = @IDEmpleado WHERE IDEmpleado IS NULL

				SELECT @Counter = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @Counter

			END

		
		SELECT @TotalGlobalFA = SUM(TotalAcumulado) FROM @Totales


		UPDATE @Totales SET Intereses = (NetoDisponible * @InteresesARepartir / @TotalGlobalFA)


		SELECT 
			   E.ClaveEmpleado AS Clave
			  ,E.NombreCompleto AS Nombre
			  ,E.Departamento
			  ,E.Sucursal
			  ,E.Puesto
			  ,E.Empresa AS RazonSocial
			  ,E.TipoNomina 
			  ,T.NetoDisponible / 2 AS AportacioneEmpresa		
			  ,T.NetoDisponible / 2 AS TotalAportacionesTrabajador		    
			  ,T.NetoDisponible			
			  ,T.Intereses
		FROM #TempEmpleados E
		INNER JOIN	@Totales T ON T.IDEmpleado = E.IDEmpleado
		WHERE T.TotalAportacionesEmpresa > 0 AND T.TotalAportacionesTrabajador > 0
		ORDER BY E.TipoNomina, E.ClaveEmpleado


END
GO
