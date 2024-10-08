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


		DECLARE
			@FechaIni DATE = CAST(GETDATE() AS DATE)
		   ,@FechaFin DATE = CAST(GETDATE() AS DATE)
		   ,@IDTipoNomina INT
		   ,@Ejercicio INT
		   ,@Empleados [RH].[dtEmpleados]
		   ,@IDEmpleado INT
		   ,@Counter INT
		   ,@IDFondoAhorro INT
		   ,@IDPeridodoPagoFA INT
		   ,@FondoAhorroPagado BIT


		SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @Ejercicio = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)


		SELECT @IDFondoAhorro = IDFondoAhorro
			  ,@IDPeridodoPagoFA = IDPeriodoPago
		FROM Nomina.tblCatFondosAhorro
		WHERE IDTipoNomina = @IDTipoNomina AND Ejercicio = @Ejercicio


		SELECT @FondoAhorroPagado = IIF((SELECT ISNULL(Cerrado,0) FROM Nomina.tblCatPeriodos WHERE IDPeriodo = @IDPeridodoPagoFA) = 1, 1, 0)


		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @IDTipoNomina = @IDTipoNomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


		SELECT @Counter = MIN(IDEmpleado) FROM @Empleados


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


		WHILE @Counter <= (SELECT MAX(IDEmpleado) FROM @Empleados)
			
			BEGIN 

				SELECT @IDEmpleado = IDEmpleado FROM @Empleados WHERE IDEmpleado = @Counter

				INSERT INTO @Totales (TotalAportacionesEmpresa,TotalAportacionesTrabajador,TotalDevolucionesEmpresa,TotalDevolucionesTrabajador,TotalRetirosEmpresa,TotalRetirosTrabajador,TotalAcumulado,TotalPrestamosFondoAhorro,TotalSaldoPendienteADescontar,NetoDisponible)
				EXEC [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado] @IDFondoAhorro = @IDFondoAhorro, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario

				UPDATE @Totales SET IDEmpleado = @IDEmpleado WHERE IDEmpleado IS NULL

				SELECT @Counter = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @Counter

			END


		SELECT 
			   E.ClaveEmpleado AS Clave
			  ,E.NombreCompleto AS Nombre
			  ,E.Departamento
			  ,E.Sucursal
			  ,E.Puesto
			  ,E.Empresa AS RazonSocial
			  ,E.TipoNomina 
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
			  --,IIF(@FondoAhorroPagado = 1, 'SI', 'NO') AS Pagado
		FROM @Empleados E
		INNER JOIN	@Totales T ON T.IDEmpleado = E.IDEmpleado
		WHERE T.TotalAportacionesEmpresa > 0 AND T.TotalAportacionesTrabajador > 0
		ORDER BY E.TipoNomina, E.ClaveEmpleado


END
GO
