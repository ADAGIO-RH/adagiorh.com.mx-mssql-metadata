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

		INSERT INTO @Periodo
		SELECT 
		     IDPeriodo
			,IDTipoNomina
			,Ejercicio
			,ClavePeriodo
			,Descripcion
			,FechaInicioPago
			,FechaFinPago
			,FechaInicioIncidencia
			,FechaFinIncidencia
			,Dias
			,AnioInicio
			,AnioFin
			,MesInicio
			,MesFin
			,IDMes
			,BimestreInicio
			,BimestreFin
			,Cerrado
			,General
			,Finiquito
			,Especial
		FROM Nomina.tblCatPeriodos
		WHERE Ejercicio = @Ejercicio AND IDMes = @IDMes AND IDTipoNomina = @IDTipoNomina

		SELECT @Ejercicio,@IDTipoNomina,@IDMes
		SELECT * FROM @Periodo
END
GO
