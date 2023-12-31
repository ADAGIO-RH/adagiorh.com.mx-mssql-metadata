USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción : Buscar los eventos del calendario duplicados Por Area/Departamento  
** Autor  : Emmanuel Contreras
** Email  : emmanuel.contreras@adagio.com.mx
** FechaCreacion : 2022-03-28
** Paremetros :  
		@FechaInicio date
		,@FechaFin date
		,@IDUsuario
	 
		** Notas: Tipos de eventos: 
		  0 - No Vigente
			1 - Incidencias		
			2 - Ausentismos		*
			3 - Horarios		
			4 - Checadas		
			5 - Papeletas
			6 - Festivos programados 
		** Tipos Incidencias
			AA	INC
			D	DESCANSO
			DF	DIAS FESTIVOS TRABAJADO
			DL	DESCANSO LABORADO
			DT	DESTES
			EX	TIEMPO EXTRA
			F	FALTA INJUSTIFICADA
			G	PERMISO CON GOCE
			I	INCAPACIDAD
			NC	NO CHECO
			P	PERMISO SIN GOCE
			PD	PRIMA DOMINICAL TRABAJADA
			PP	SSSS
			R	RETARDO
			S	SUSPENSIÓN
			SS	SSSSSS
			V	VACACIONES
		**** TipoSolicitud
			1	VACACIONES
			2	PERMISOS
			3	ACTUALIZACIÓN DE DATOS
			4	PRÉSTAMOS

			exec [Asistencia].[spBuscarEventosCalendarioDuplicados] '2022-09-01','2022-09-13', 1  
  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor  Comentario
------------------- ------------------- ------------------------------------------------------------
2022-09-13			Emmanuel Contreras	Se hacen ajustes a las fechas regresadas 
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Asistencia].[spBuscarEventosCalendarioDuplicados] (
	@FechaInicio DATE,
	@FechaFin DATE,
	@IDUsuario INT
	)
AS
DECLARE @dtEventos [Asistencia].[dtEventoCalendario],
	@tblFechasMaster [App].[dtFechasFull],
	@dtEmpleados RH.dtEmpleados,
	@Fechas [App].[dtFechasFull],
	@IDEmpleadoUsuario INT = 0,
	@DiasDisponibles INT = 0,
	@CALENDARIO0001 BIT = 0,
	@EsSupervisor BIT = 0,
	@Counter INT,
	@MaxId INT,
	@IDEmpleado INT,
	@FechaIniQry DATE,
	@FechaFinQry DATE,
	@IDDepartamento INT,
	@IDArea INT,
	@Duplicado BIT,
	@DiasDescansoTrabajador VARCHAR(4000),
	@IDTipoSolicitud INT;

IF (OBJECT_ID('tempdb..#templistaSolicitudesRN') IS NOT NULL)
	DROP TABLE #templistaSolicitudesRN

DECLARE @tblSolicitudesVacaciones AS TABLE (
	IDSolicitud INT,
	IDEmpleado INT,
	NOMBRECOMPLETO VARCHAR(4000),
	IDTipoSolicitud INT,
	DescripcionTipoSolicitud VARCHAR(4000),
	IDEstatusSolicitud INT,
	DescripcionEstatusSolicitud VARCHAR(4000),
	IDIncidencia VARCHAR(4000),
	FechaIni DATE,
	FechaFin DATE,
	CantidadDias INT,
	FechaCreacion DATE,
	ComentarioEmpleado VARCHAR(4000),
	CantidadMonto DECIMAL(18, 4),
	IDUsuarioAutoriza INT,
	DiasDescanso VARCHAR(4000),
	IDDetalleFiltrosEmpleadosUsuarios INT,
	IDUsuario INT,
	Filtro VARCHAR(4000),
	ValorFiltro VARCHAR(4000),
	IDCatFiltroUsuario INT,
	IDDepartamento INT,
	IDArea INT,
	Duplicado BIT,
	DiasDisponibles INT
	)
DECLARE @tblSolicitudPrestamo AS TABLE (
	IDSolicitudPrestamo INT,
	IDEmpleado INT,
	NOMBRECOMPLETO VARCHAR(4000),
	IDTipoPrestamo INT,
	MontoPrestamo DECIMAL(18, 2),
	FechaCreacion DATE,
	IDEstatusSolicitudPrestamo INT
	)
DECLARE @tblTempVacaciones AS TABLE (
	Anio INT,
	FechaIni DATE,
	FechaFin DATE,
	Dias INT,
	DiasTomados INT,
	DiasVencidos INT,
	DiasDisponibles DECIMAL(18, 2),
	TipoPrestacion VARCHAR(500)
	)
DECLARE @tblFechasSolicitud AS TABLE (
	IDSolicitud INT,
	IDEmpleado INT,
	Fecha DATE,
	IDArea INT,
	IDDepartamento INT,
	RN BIT NOT NULL DEFAULT 0
	)
DECLARE @tblActualizacionDatos AS TABLE (
	IDSolicitud INT,
	NOMBRECOMPLETO VARCHAR(4000),
	IDEmpleado INT,
	IDTipoSolicitud INT,
	FechaCreacion DATE,
	IDEstatusSolicitud INT,
	IDIncidencia VARCHAR(4000)
	)
DECLARE @DiasDescanso AS TABLE (Dia INT)
DECLARE @tblDuplicadosArea AS TABLE (
	Fecha DATE,
	IDArea INT,
	Cantidad INT
	)
DECLARE @tblDuplicadosDepartamento AS TABLE (
	Fecha DATE,
	IDDepartamento INT,
	Cantidad INT
	)

	SELECT @IDEmpleadoUsuario = IDEmpleado,
		@EsSupervisor = Supervisor
	FROM Seguridad.tblUsuarios
	WHERE IDUsuario = @IDUsuario

	INSERT @dtEmpleados (
		IDEmpleado,
		ClaveEmpleado,
		NOMBRECOMPLETO
		)
	SELECT em.IDEmpleado,
		ClaveEmpleado,
		NOMBRECOMPLETO
	FROM [RH].[tblEmpleadosMaster] em WITH (NOLOCK)
	JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe WITH (NOLOCK)
		ON dfe.IDEmpleado = em.IDEmpleado
			AND dfe.IDUsuario = @IDUsuario
	WHERE em.Vigente = 1
		AND em.IDEmpleado <> @IDEmpleadoUsuario

	IF EXISTS (
			SELECT TOP 1 1
			FROM Seguridad.tblPermisosEspecialesUsuarios pes
			JOIN App.tblCatPermisosEspeciales cpe
				ON pes.IDPermiso = cpe.IDPermiso
			WHERE cpe.Codigo = 'CALENDARIO0001'
			)
	BEGIN
		SET @CALENDARIO0001 = 1
	END;

	-- Insertamos las fechas en la tabla master
	-- Declaración de Variables
	--Tablas
	INSERT INTO @tblFechasMaster (Fecha)
	EXEC [App].[spListaFechas] @FechaInicio,
		@FechaFin

	-- Obtenemos todas las solicitudes
	-- de prestamos
	INSERT INTO @tblSolicitudPrestamo (
		IDSolicitudPrestamo,
		IDEmpleado,
		NOMBRECOMPLETO,
		IDTipoPrestamo,
		MontoPrestamo,
		FechaCreacion,
		IDEstatusSolicitudPrestamo
		)
	SELECT IDSolicitudPrestamo,
		tsp.IDEmpleado,
		tem.NOMBRECOMPLETO,
		'6',
		MontoPrestamo,
		FechaCreacion,
		IDEstatusSolicitudPrestamo
	FROM Intranet.tblSolicitudesPrestamos tsp
	LEFT JOIN @dtEmpleados tem
		ON tsp.IDEmpleado = tem.IDEmpleado
	WHERE FechaCreacion BETWEEN @FechaInicio
			AND @FechaFin
		AND tsp.IDEstatusSolicitudPrestamo = 1

	-- Consulta e inserta todas las peticiones en ese rango de fechas
	-- de tipo vacaciones
	INSERT INTO @tblSolicitudesVacaciones (
		IDSolicitud,
		IDEmpleado,
		NOMBRECOMPLETO,
		IDTipoSolicitud,
		DescripcionTipoSolicitud,
		IDEstatusSolicitud,
		DescripcionEstatusSolicitud,
		IDIncidencia,
		FechaIni,
		FechaFin,
		CantidadDias,
		FechaCreacion,
		ComentarioEmpleado,
		CantidadMonto,
		IDUsuarioAutoriza,
		DiasDescanso,
		IDDepartamento,
		IDArea,
		Duplicado,
		DiasDisponibles
		)
	SELECT se.IDSolicitud,
		se.IDEmpleado,
		cem.NOMBRECOMPLETO,
		se.IDTipoSolicitud,
		cts.Descripcion AS DescripcionTipoSolicitud,
		se.IDEstatusSolicitud,
		ces.Descripcion AS DescripcionEstatusSolicitud,
		se.IDIncidencia,
		se.FechaIni,
		ISNULL(se.FechaFin, se.FechaIni),
		se.CantidadDias,
		se.FechaCreacion,
		se.ComentarioEmpleado,
		se.CantidadMonto,
		se.IDUsuarioAutoriza,
		se.DiasDescanso,
		ISNULL(tde.IDDepartamento, 0) AS IDDepartamento,
		ISNULL(cca.IDArea, 0) AS IDArea,
		0 AS RN,
		ISNULL(se.DiasDisponibles, 0)
	FROM Intranet.tblSolicitudesEmpleado AS se
	INNER JOIN @dtEmpleados cem
		ON se.IDEmpleado = cem.IDEmpleado
	LEFT OUTER JOIN Intranet.tblCatTipoSolicitud AS cts
		ON se.IDTipoSolicitud = cts.IDTipoSolicitud
	LEFT OUTER JOIN Intranet.tblCatEstatusSolicitudes AS ces
		ON se.IDEstatusSolicitud = ces.IDEstatusSolicitud
	LEFT JOIN RH.tblCatArea cca
		ON cem.IDArea = cca.IDArea
	LEFT JOIN RH.tblDepartamentoEmpleado tde
		ON tde.IDEmpleado = cem.IDEmpleado
	WHERE se.IDTipoSolicitud != 3
		AND se.FechaIni BETWEEN @FechaInicio
			AND @FechaFin
		OR @FechaInicio BETWEEN se.FechaIni
			AND se.FechaFin
		AND se.IDEstatusSolicitud = 1

	-- Buscar Solicitud Actualización de Datos
	INSERT INTO @tblActualizacionDatos (
		IDSolicitud,
		NOMBRECOMPLETO,
		IDEmpleado,
		IDTipoSolicitud,
		FechaCreacion,
		IDEstatusSolicitud,
		IDIncidencia
		)
	SELECT IDSolicitud,
		NOMBRECOMPLETO,
		tse.IDEmpleado,
		IDTipoSolicitud,
		FechaCreacion,
		IDEstatusSolicitud,
		IDIncidencia
	FROM Intranet.tblSolicitudesEmpleado tse
	JOIN @dtEmpleados tem
		ON tse.IDEmpleado = tem.IDEmpleado
	WHERE IDTipoSolicitud = 3
		AND FechaCreacion BETWEEN @FechaInicio
			AND @FechaFin
		AND tse.IDEstatusSolicitud = 1

	-- Creamos las variables para el while
	SELECT @Counter = MIN(IDSolicitud),
		@MaxId = MAX(IDSolicitud)
	FROM @tblSolicitudesVacaciones

	WHILE (
			@Counter IS NOT NULL
			AND @Counter <= @MaxId
			)
	BEGIN
		SELECT @IDEmpleado = IDEmpleado,
			@FechaIniQry = FechaIni,
			@FechaFinQry = FechaFin,
			@IDArea = IDArea,
			@IDDepartamento = IDDepartamento,
			@DiasDescansoTrabajador = DiasDescanso,
			@IDTipoSolicitud = IDTipoSolicitud
		FROM @tblSolicitudesVacaciones
		WHERE IDSolicitud = @Counter

		BEGIN TRY
			DELETE
			FROM @tblTempVacaciones

			INSERT INTO @tblTempVacaciones
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,
				1,
				@FechaIniQry,
				@IDUsuario
		END TRY

		BEGIN CATCH
		END CATCH

		SELECT @DiasDisponibles = FLOOR(SUM(DiasDisponibles))
		FROM @tblTempVacaciones

		UPDATE tblS
		SET tblS.DiasDisponibles = @DiasDisponibles
		FROM @tblSolicitudesVacaciones AS tblS
		WHERE tblS.IDSolicitud = @Counter

		INSERT INTO @Fechas (Fecha)
		EXEC [App].[spListaFechas] @FechaIniQry,
			@FechaFinQry

		DELETE @Fechas
		WHERE DiaSemana IN (
				SELECT CONVERT(INT, Item)
				FROM App.Split(@DiasDescansoTrabajador, ',')
				)

		INSERT INTO @tblFechasSolicitud (
			IDSolicitud,
			IDEmpleado,
			Fecha,
			IDArea,
			IDDepartamento
			)
		SELECT @Counter,
			@IDEmpleado,
			Fecha,
			@IDArea,
			@IDDepartamento
		FROM @Fechas

		DELETE
		FROM @Fechas

		SELECT @Counter = MIN(IDSolicitud)
		FROM @tblSolicitudesVacaciones
		WHERE IDSolicitud > @Counter
	END

	SELECT m.Fecha,
		fs.IDEmpleado,
		fs.IDSolicitud,
		ROW_NUMBER() OVER (
			PARTITION BY m.Fecha,
			fs.IDArea,
			fs.IDDepartamento ORDER BY m.fecha ASC
			) AS RNN
	INTO #templistaSolicitudesRN
	FROM @tblFechasMaster m
	LEFT JOIN @tblFechasSolicitud fs
		ON m.Fecha = fs.Fecha;

	WITH CTE (
		IDSolicitud,
		DuplicateCount
		)
	AS (
		SELECT IDSolicitud,
			ROW_NUMBER() OVER (
				PARTITION BY IDEmpleado,
				Fecha ORDER BY IDSolicitud
				) AS DuplicateCount
		FROM #templistaSolicitudesRN
		)
	DELETE
	FROM CTE
	WHERE DuplicateCount > 1;

	UPDATE @tblSolicitudesVacaciones
	SET Duplicado = 1
	WHERE IDSolicitud IN (
			SELECT DISTINCT IDSolicitud
			FROM #templistaSolicitudesRN
			WHERE ISNULL(RNN, 0) > 1
			)

	INSERT INTO @dtEventos (
		id,
		TipoEvento,
		IDEmpleado,
		title,
		allDay,
		start,
		[end],
		url,
		color,
		backgroundColor,
		borderColor,
		textColor,
		[data]
		)
	SELECT IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (
			IDIncidencia --SUBSTRING (DescripcionTipoSolicitud, 1, 1)
			,
			' - ',
			NOMBRECOMPLETO,
			' (',
			CantidadDias,
			'/',
			DiasDisponibles,
			')'
			),
		1,
		FechaIni,
		FechaFin,
		'',
		'#9999ff',
		NULL,
		NULL,
		'#000000'
		--,NULL
		,
		CONCAT (
			'{ "Duplicado": ',
			Duplicado,
			', "DescripcionTipoSolicitud": "',
			DescripcionTipoSolicitud,
			'", "IDSolicitud" : "',
			IDIncidencia,
			IDSolicitud,
			'"  }'
			)
	FROM @tblSolicitudesVacaciones
	WHERE @IDTipoSolicitud = 1

	UNION

	SELECT IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (
			IDIncidencia,
			' - ',
			NOMBRECOMPLETO,
			' (',
			CantidadDias,
			'/',
			DiasDisponibles,
			')'
			),
		1,
		FechaIni,
		FechaFin,
		'#000000',
		'#0099ff',
		NULL,
		NULL,
		NULL,
		CONCAT (
			'{ "Duplicado": ',
			Duplicado,
			', "DescripcionTipoSolicitud": "',
			DescripcionTipoSolicitud,
			'", "IDSolicitud" : "',
			IDIncidencia,
			IDSolicitud,
			'"  }'
			)
	FROM @tblSolicitudesVacaciones
	WHERE @IDTipoSolicitud = 2

	UNION

	SELECT IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (
			'Actualización de Datos: ',
			NOMBRECOMPLETO
			),
		1,
		FechaCreacion,
		FechaCreacion,
		'#000000',
		'#993399',
		NULL,
		NULL,
		NULL,
		NULL
	FROM @tblActualizacionDatos

	UNION

	SELECT IDSolicitudPrestamo,
		IDTipoPrestamo,
		IDEmpleado,
		CONCAT (
			'Préstamo: ',
			NOMBRECOMPLETO,
			' (',
			'$ ',
			FORMAT(MontoPrestamo, 'N2'),
			')'
			),
		1,
		FechaCreacion,
		FechaCreacion,
		NULL,
		'#9b9b9b',
		'#000000',
		NULL,
		NULL,
		NULL
	FROM @tblSolicitudPrestamo

	SELECT id,
		TipoEvento,
		IDEmpleado,
		title,
		allDay,
		[start],
		[end],
		[url],
		color,
		backgroundColor,
		borderColor,
		textColor,
		[data]
	FROM @dtEventos
	ORDER BY id,
		TipoEvento ASC,
		IDEmpleado
GO
