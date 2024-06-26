USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spPeriodosDeNominaAExcel](

	@dtFiltros [Nomina].[dtFiltrosRH] READONLY
   ,@IDUsuario INT

) AS

BEGIN

	DECLARE 
		@Ejercicio INT
	   ,@IDTipoNomina INT
	   ,@IDMes INT
	   ,@Identificadores VARCHAR(MAX)

		SELECT @Ejercicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtfiltros WHERE Catalogo = 'Ejercicio'),',')),1900)
		SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @IDMes = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)

		IF ((@Ejercicio = 1900 OR @Ejercicio IS NULL))
		BEGIN
			RAISERROR('SELECCIONE UN EJERCICIO',16,1)
			RETURN
		END

		IF ((@IDTipoNomina = 0 OR @IDTipoNomina IS NULL))
		BEGIN
			RAISERROR('SELECCIONE UN TIPO DE NOMINA',16,1)
			RETURN
		END

		IF ((@IDMes = 0 OR @IDMes IS NULL))
		BEGIN
			RAISERROR('SELECCIONE UN MES',16,1)
			RETURN
		END

		SELECT @Identificadores = STRING_AGG(IDPeriodo,',') FROM Nomina.tblCatPeriodos WHERE (Ejercicio = @Ejercicio AND IDTipoNomina = @IDTipoNomina AND IDMes = @IDMes AND Cerrado = 1)

		SELECT 
			P.IDPeriodo AS [IDPeriodo]
		   ,TN.Descripcion AS [Tipo Nomina]
		   ,P.Ejercicio AS Ejercicio
		   ,P.ClavePeriodo AS [Clave Periodo]
		   ,P.Descripcion AS Periodo
		   ,FORMAT(P.FechaInicioPago, 'dd/MM/yyyy') AS [Fecha Inicio Pago]
		   ,FORMAT(P.FechaFinPago, 'dd/MM/yyyy') AS [Fecha Fin Pago]
		   ,FORMAT(P.FechaInicioIncidencia, 'dd/MM/yyyy') AS [Fecha Inicio Incidencia]
		   ,FORMAT(P.FechaFinIncidencia, 'dd/MM/yyyy') AS [Fecha Fin De Incidencia]
		   ,P.Dias AS Dias
		   ,CASE WHEN P.Cerrado   = 1 THEN 'Cerrado' ELSE 'Abierto' END AS [Estatus Periodo]
		   ,CASE WHEN P.General   = 1 THEN 'General'
				 WHEN P.Finiquito = 1 THEN 'Finiquito'
				 WHEN P.Especial  = 1 THEN 'Especial'
			END AS [Tipo Periodo]
		  ,@Identificadores AS [Identificadores]
		FROM Nomina.tblCatPeriodos P
		INNER JOIN Nomina.tblCatTipoNomina TN 
			ON TN.IDTipoNomina = P.IDTipoNomina
		WHERE (P.Ejercicio = @Ejercicio AND P.IDTipoNomina = @IDTipoNomina AND P.IDMes = @IDMes)

END
GO
