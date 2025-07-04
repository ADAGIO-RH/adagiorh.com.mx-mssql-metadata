USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteAcumuladoFondoAhorroFS](
	
	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

) AS

BEGIN

		SET NOCOUNT ON;

		DECLARE
			@IDTipoNomina INT
		   ,@Ejercicio INT
		   ,@Empleados [RH].[dtEmpleados]
		   ,@IDEmpleado INT
		   ,@Counter INT
		   ,@IDFondoAhorro INT
		   ,@IDPeriodoInicialFA INT
		   ,@IDPeriodoFinalFA INT
		   ,@IDPeriodoPagoFA INT
		   ,@FechaIni DATE
		   ,@FechaFin DATE
		   ,@IDPeriodoSeleccionado INT
		   ,@CodigoConceptoDevFondoAhorroEmpresa VARCHAR(10) = '162'
		   ,@IDConcepto162 INT
		   ,@Afectar VARCHAR(10) = 'False'


		SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @Ejercicio = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
		SELECT @IDPeriodoSeleccionado = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDPeriodoInicial'),',')),0)
		SELECT @Afectar = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Afectar'),',')),'False')
		SELECT @IDConcepto162 = IDConcepto FROM Nomina.tblCatConceptos WITH (NOLOCK) WHERE Codigo = @CodigoConceptoDevFondoAhorroEmpresa


		SELECT @IDFondoAhorro      = CFA.IDFondoAhorro
			  ,@IDPeriodoInicialFA = PeriodoInicialFA.IDPeriodo
			  ,@IDPeriodoFinalFA   = PeriodoFinalFA.IDPeriodo
			  ,@IDPeriodoPagoFA    = PeriodoPagoFA.IDPeriodo
			  ,@FechaIni           = PeriodoInicialFA.FechaInicioPago
			  ,@FechaFin		   = PeriodoFinalFA.FechaFinPago
		FROM Nomina.tblCatFondosAhorro CFA
			INNER JOIN Nomina.tblCatPeriodos PeriodoInicialFA WITH (NOLOCK)
				ON CFA.IDPeriodoInicial = PeriodoInicialFA.IDPeriodo
			INNER JOIN Nomina.tblCatPeriodos PeriodoFinalFA WITH (NOLOCK)
				ON CFA.IDPeriodoFinal = PeriodoFinalFA.IDPeriodo
			INNER JOIN Nomina.tblCatPeriodos PeriodoPagoFA WITH (NOLOCK)
				ON CFA.IDPeriodoPago = PeriodoPagoFA.IDPeriodo
		WHERE CFA.IDTipoNomina = @IDTipoNomina AND CFA.Ejercicio = @Ejercicio


		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @IDTiponomina = @IDTiponomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

		
		DECLARE @Fondo TABLE (
			 TotalAportacionesEmpresa		DECIMAL(18,2)
			,TotalAportacionesTrabajador	DECIMAL(18,2)
			,TotalDevolucionesEmpresa		DECIMAL(18,2)
			,TotalDevolucionesTrabajador	DECIMAL(18,2)
			,TotalRetirosEmpresa			DECIMAL(18,2)
			,TotalRetirosTrabajador		    DECIMAL(18,2)
			,TotalAcumulado				    DECIMAL(18,2)
			,TotalPrestamosFondoAhorro		DECIMAL(18,2)
			,TotalSaldoPendienteADescontar	DECIMAL(18,2)
			,NetoDisponible                 DECIMAL(18,2)
		);


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
		);


		SELECT @Counter = MIN(IDEmpleado) FROM @Empleados


		WHILE @Counter <= (SELECT MAX(IDEmpleado) FROM @Empleados)
			
			BEGIN 

				SELECT @IDEmpleado = IDEmpleado FROM @Empleados WHERE IDEmpleado = @Counter

				INSERT INTO @Fondo (TotalAportacionesEmpresa,TotalAportacionesTrabajador,TotalDevolucionesEmpresa,TotalDevolucionesTrabajador,TotalRetirosEmpresa,TotalRetirosTrabajador,TotalAcumulado,TotalPrestamosFondoAhorro,TotalSaldoPendienteADescontar,NetoDisponible)
				EXEC [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado] @IDFondoAhorro = @IDFondoAhorro, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario

				INSERT INTO @Totales (IDEmpleado,TotalAportacionesEmpresa,TotalAportacionesTrabajador,TotalDevolucionesEmpresa,TotalDevolucionesTrabajador,TotalRetirosEmpresa,TotalRetirosTrabajador,TotalAcumulado,TotalPrestamosFondoAhorro,TotalSaldoPendienteADescontar,NetoDisponible)
				SELECT 
					 @IDEmpleado
					,TotalAportacionesEmpresa
					,TotalAportacionesTrabajador
					,TotalDevolucionesEmpresa
					,TotalDevolucionesTrabajador
					,TotalRetirosEmpresa
					,TotalRetirosTrabajador
					,TotalAcumulado
					,TotalPrestamosFondoAhorro
					,TotalSaldoPendienteADescontar
					,NetoDisponible
				FROM @Fondo

				SELECT @Counter = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @Counter

				DELETE FROM @Fondo;

			END


		SELECT 
			   E.ClaveEmpleado AS Clave
			  ,E.NombreCompleto AS Nombre
			  ,E.Departamento
			  ,E.Sucursal
			  ,E.Puesto
			  ,E.Empresa AS RazonSocial
			  ,E.TipoNomina 
			  ,CASE WHEN M.Vigente = 1 THEN 'SI' ELSE 'NO' END AS Vigente
			  ,TotalAportacionesEmpresa		
			  ,TotalAportacionesTrabajador	
			  ,TotalDevolucionesEmpresa		
			  ,TotalDevolucionesTrabajador	
			  ,TotalRetirosEmpresa			
			  ,TotalRetirosTrabajador		    
			  ,TotalAcumulado				    
			  ,TotalPrestamosFondoAhorro		
			  ,TotalSaldoPendienteADescontar	
			  ,NetoDisponible 
		FROM @Empleados E
			INNER JOIN	@Totales T ON T.IDEmpleado = E.IDEmpleado
			INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = E.IDEmpleado
		WHERE T.TotalAportacionesEmpresa > 0 AND T.TotalAportacionesTrabajador > 0
		ORDER BY E.TipoNomina, E.ClaveEmpleado


		IF (@Afectar = 'True')
		BEGIN

				MERGE Nomina.tblDetallePeriodo AS TARGET
				USING @Totales AS SOURCE
					ON TARGET.IDEmpleado  = SOURCE.IDEmpleado
					AND TARGET.IDPeriodo  = @IDPeriodoSeleccionado
					AND TARGET.IDConcepto = @IDConcepto162
					AND SOURCE.NetoDisponible > 0

				WHEN MATCHED THEN
					UPDATE 
						SET TARGET.CantidadMonto = ISNULL(SOURCE.NetoDisponible,0)

				WHEN NOT MATCHED BY TARGET THEN
					INSERT (IDEmpleado, IDPeriodo, IDConcepto, CantidadMonto)
					VALUES (SOURCE.IDEmpleado, @IDPeriodoSeleccionado, @IDConcepto162, ISNULL(SOURCE.NetoDisponible,0))

				WHEN NOT MATCHED BY SOURCE THEN
					DELETE;

		END

END
GO
