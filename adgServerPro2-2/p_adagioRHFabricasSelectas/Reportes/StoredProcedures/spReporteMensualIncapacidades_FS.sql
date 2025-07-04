USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
El presente es para solicitar tu apoyo con generarnos un reporte en el que podamos visualizar el concentrado de incapacidades por empleado, que contenga:

Folio de Incapacidad
Rama de Incapacidad (EG, RT, MAT)
Tipo de Incapacidad (Inicial, subsecuente, Alta Médica)
Fecha de Inicio
Días de Incapacidad
 
Estos datos se capturan en la nómina, lo que necesitamos en un reporte en el que podamos descargar mes con mes este concentrado por empleado.
*/


CREATE PROCEDURE [Reportes].[spReporteMensualIncapacidades_FS](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN


	SET NOCOUNT ON;


	DECLARE
		 @Empleados [RH].[dtEmpleados]
		,@Ejercicio INT
		,@IDMes INT
		,@IDTipoNomina INT
		,@FechaIni DATE
		,@FechaFin DATE


	IF EXISTS (SELECT TOP 1 Value FROM @dtFiltros WHERE Value IS NULL AND Catalogo NOT IN ('RazonesSociales','RegPatronales','ClasificacionesCorporativas'))
	BEGIN

		RAISERROR('SELECCIONE LOS PARAMETROS REQUERIDOS',16,1) 
		RETURN;
	END;

	SELECT @IDMes        = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
	SELECT @Ejercicio    = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
	SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
	SELECT @FechaIni     = DATEFROMPARTS(@Ejercicio,@IDMes,1)
	SELECT @FechaFin     = EOMONTH(@FechaIni)


	INSERT INTO @Empleados 
	EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @IDTipoNomina = @IDtipoNomina, @dtFiltros = @dtFiltros, @IDUsuario= @IDusuario


	SELECT 
		 E.ClaveEmpleado AS Clave
		,E.NOMBRECOMPLETO AS Nombre
		,E.Empresa AS [Razon Social]
		,E.RegPatronal AS [Registro Patronal]
		,E.ClasificacionCorporativa AS [Clasificacion Corporativa]
		,E.Puesto
		,E.Departamento
		,E.TipoNomina AS [Tipo Nomina]
		,E.Sucursal
		,UPPER(IE.Numero) AS [Folio Incapacidad]
		,TI.Descripcion AS [Rama Incapacidad]
		,ISNULL(CI.Nombre,'SIN ASIGNAR') AS [Tipo Incapacidad]
		,FORMAT(IE.Fecha,'dd/MM/yyyy') AS [Fecha De Inicio]
		,CAST(IE.Duracion AS VARCHAR(10))+ ' DIA(S)' AS [Dias Incapacidad]
		,FORMAT(DATEADD(DAY,IE.Duracion -1,IE.Fecha),'dd/MM/yyyy') AS [Fecha Fin]
	  FROM @Empleados E
		INNER JOIN Asistencia.tblIncapacidadEmpleado IE
			ON E.IDEmpleado = IE.IDEmpleado
		LEFT JOIN IMSS.tblCatTiposLesiones TL
			ON IE.IDTipoLesion = TL.IDTipoLesion
		LEFT JOIN IMSS.tblCatTipoRiesgoIncapacidad TRI
			ON IE.IDTipoRiesgoIncapacidad = TRI.IDTipoRiesgoIncapacidad
		LEFT JOIN IMSS.tblCatCausasAccidentes CA
			ON IE.IDCausaAccidente = CA.IDCausaAccidente
		LEFT JOIN IMSS.tblCatClasificacionesIncapacidad CI
			ON IE.IDClasificacionIncapacidad = CI.IDClasificacionIncapacidad
		LEFT JOIN IMSS.tblCatCorreccionesAccidentes CO
			ON IE.IDCorreccionAccidente = CO.IDCorreccionAccidente
		LEFT JOIN Sat.tblCatTiposIncapacidad TI
			ON IE.IDTipoIncapacidad = TI.IDTIpoIncapacidad
	WHERE IE.Fecha BETWEEN @FechaIni AND @FechaFin AND IE.IDTipoIncapacidad IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'TipoIncapacidad'),','))
	ORDER BY E.ClaveEmpleado, IE.Fecha


END
GO
