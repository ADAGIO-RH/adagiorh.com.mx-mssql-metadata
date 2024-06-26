USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spAportacionesFondoDeAhorro](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN

	DECLARE
		 @Ejercicio INT
		,@IDTipoNomina INT
		,@ClaveEmpleadoInicial VARCHAR(20)
		,@ClaveEmpleadoFinal VARCHAR(20)
		,@IDFondoAhorro INT
		,@Empleados [RH].[dtEmpleados]

	SELECT @Ejercicio = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 [VALUE] FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),CAST(YEAR(GETDATE()) AS INT))
	SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
	SELECT @ClaveEmpleadoInicial = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
	SELECT @ClaveEmpleadoFinal = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')

	SELECT @IDFondoAhorro = IDFondoAhorro
	FROM Nomina.tblCatFondosAhorro 
	WHERE IDTipoNomina = @IDTipoNomina AND Ejercicio = @Ejercicio

	INSERT INTO @Empleados
	EXEC [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial, @EmpleadoFin = @ClaveEmpleadoFinal, @IDTipoNomina = @IDTipoNomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	DECLARE @TempFondo AS TABLE (
		 IDDetallePeriodo INT
		,IDEmpleado INT
		,IDConcepto INT
		,Codigo VARCHAR(5)
		,Fecha DATE
		,Periodo VARCHAR(255)
		,DescripcionPeriodo VARCHAR(255)
		,ImporteAbono DECIMAL(18,2)
		,ImporteCargo DECIMAL(18,2)
		,Descripcion VARCHAR(255)
		,TotalPaginas INT
		,TotalRegistros INT
	);

	DECLARE 
		 @IDEmpleado INT
		,@Counter INT

	SELECT @Counter = MIN(IDEmpleado) FROM @Empleados
	
	WHILE @Counter <= (SELECT MAX(IDEmpleado) FROM @Empleados)
		BEGIN

			SELECT @IDEmpleado = IDEmpleado FROM @Empleados WHERE IDEmpleado = @Counter

			INSERT INTO @TempFondo (IDDetallePeriodo,IDEmpleado,IDConcepto,Codigo,Fecha,Periodo,DescripcionPeriodo,ImporteAbono,ImporteCargo,Descripcion,TotalPaginas,TotalRegistros)
			EXEC Nomina.[spBuscarAportacionesFondoAhorroPorEmpleado] @IDFondoAhorro = @IDFondoAhorro, @IDEmpleado = @IDEmpleado,@IDUsuario = @IDUsuario

			SELECT @Counter = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @Counter

		END

		SELECT
			 E.ClaveEmpleado AS [CLAVE EMPLEADO]
			,E.NombreCompleto AS [NOMBRE]
			,E.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,FORMAT(F.Fecha,'dd/MM/yyyy') AS [FECHA]
			,F.Periodo AS [PERIODO]
			,F.DescripcionPeriodo AS [DESCRIPCION PERIODO]
			,F.ImporteAbono AS [IMPORTE ABONO]
			,F.ImporteCargo AS [IMPORTE CARGO]
			,F.Descripcion AS [DESCRIPCION]
		FROM @TempFondo F
			INNER JOIN @Empleados E
				ON F.IDEmpleado = E.IDEmpleado
		ORDER BY E.ClaveEmpleado, E.ClasificacionCorporativa
END
GO
