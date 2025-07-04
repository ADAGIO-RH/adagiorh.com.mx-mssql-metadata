USE [p_adagioRHIndustrialMefi]
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
	--declare
	--	--@FechaInicio DATE = '2022-12-01',
	--	--@FechaFin DATE = '2022-12-31',
	--	@FechaInicio DATE = '2022-10-01',
	--	@FechaFin DATE = '2023-01-31',
	--	@dtFiltros [Nomina].[dtFiltrosRH],
	--	@IDUsuario INT = 1

CREATE PROC [Asistencia].[spBuscarEventosCalendarioDuplicados] (
	@FechaInicio DATE,
	@FechaFin DATE,
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDUsuario INT
)
AS

	DECLARE 
		@dtEventos [Asistencia].[dtEventoCalendario],
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
		@IDTipoSolicitud INT,
		@DEFAULT_CONFIG_EVENTO_CALENDARIO varchar(max) = '{ "BackgroundColor": "#9999ff", "Color": "#ffffff" }',
        @IDIdioma VARCHAR(max),
		@tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]
	;
    
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


	--select * from RH.tblCatCentroCosto

	IF (OBJECT_ID('tempdb..#templistaSolicitudesRN') IS NOT NULL) DROP TABLE #templistaSolicitudesRN

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
		Departamento varchar(max),
		IDArea INT,
		IDCentroCosto INT,
		CentroCosto varchar(max),
		ConfiguracionEventoCalendario varchar(max),
		Duplicado BIT,
		DiasDisponibles INT,
		ID int identity(1,1)
	)

	DECLARE @tblSolicitudPrestamo AS TABLE (
		IDSolicitudPrestamo INT,
		IDEmpleado INT,
		NOMBRECOMPLETO VARCHAR(4000),
		IDTipoPrestamo INT,
		MontoPrestamo DECIMAL(18, 2),
		FechaCreacion DATE,
		IDEstatusSolicitudPrestamo INT,
		IDDepartamento INT,
		Departamento varchar(max),
		IDArea INT,
		IDCentroCosto INT,
		CentroCosto varchar(max),
		ConfiguracionEventoCalendario varchar(max)
	)

	--DECLARE @tblTempVacaciones AS TABLE (
	--	Anio INT,
	--	FechaIni DATE,
	--	FechaFin DATE,
	--	Dias INT,
	--	DiasTomados INT,
	--	DiasVencidos INT,
	--	DiasDisponibles DECIMAL(18, 2),
	--	TipoPrestacion VARCHAR(500),
 --       FechaIniDisponible DATE,
 --       FechaFinDisponible DATE
	--)

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

	insert into @dtEmpleados   
	exec [RH].[spBuscarEmpleadosMaster] 
		@FechaIni	= @FechaInicio, 
		@Fechafin	= @FechaFin, 
		@dtFiltros	= @dtFiltros, 
		@IDUsuario	= @IDUsuario                
	
	INSERT INTO @tblFechasMaster (Fecha)
	EXEC [App].[spListaFechas] 
		@FechaInicio,
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
		IDEstatusSolicitudPrestamo,
		IDDepartamento,
		Departamento,
		IDArea,
		IDCentroCosto,
		CentroCosto,
		ConfiguracionEventoCalendario
	)
	SELECT IDSolicitudPrestamo,
		tsp.IDEmpleado,
		tem.NOMBRECOMPLETO,
		'6',
		MontoPrestamo,
		FechaCreacion,
		IDEstatusSolicitudPrestamo,
		ISNULL(tde.IDDepartamento, 0) AS IDDepartamento,
		ISNULL(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')),  '[SIN DEPARTAMENTO]'),
		ISNULL(cca.IDArea, 0) AS IDArea,
		ISNULL(cce.IDCentroCosto, 0) AS IDCentroCosto,
		ISNULL(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')), '[SIN CENTRO DE COSTO]'),
		isnull(cc.ConfiguracionEventoCalendario, @DEFAULT_CONFIG_EVENTO_CALENDARIO) as ConfiguracionEventoCalendario
	FROM Intranet.tblSolicitudesPrestamos tsp
		JOIN @dtEmpleados tem ON tsp.IDEmpleado = tem.IDEmpleado
		LEFT JOIN [RH].[tblAreaEmpleado] cca WITH(NOLOCK) ON cca.IDEmpleado = tem.IDEmpleado AND cca.FechaIni<= @FechaFin  and cca.FechaFin >= @FechaFin        
		LEFT JOIN RH.tblDepartamentoEmpleado tde ON tde.IDEmpleado = tem.IDEmpleado AND tde.FechaIni<= @FechaFin  and tde.FechaFin >= @FechaFin        
		left join RH.tblCatDepartamentos d on d.IDDepartamento = tde.IDDepartamento
		LEFT JOIN RH.tblCentroCostoEmpleado cce ON cce.IDEmpleado = tem.IDEmpleado AND cce.FechaIni<= @FechaFin  and cce.FechaFin >= @FechaFin     
		left join RH.tblCatCentroCosto cc on cc.IDCentroCosto = cce.IDCentroCosto
	WHERE FechaCreacion BETWEEN @FechaInicio AND @FechaFin
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
		Departamento,
		IDArea,
		IDCentroCosto,
		CentroCosto,
		ConfiguracionEventoCalendario,
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
		ISNULL(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')),  '[SIN DEPARTAMENTO]'),
		ISNULL(cca.IDArea, 0) AS IDArea,
		ISNULL(cce.IDCentroCosto, 0) AS IDCentroCosto,
		ISNULL(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')), '[SIN CENTRO DE COSTO]'),
		isnull(cc.ConfiguracionEventoCalendario, @DEFAULT_CONFIG_EVENTO_CALENDARIO) as ConfiguracionEventoCalendario,
		0 AS RN,
		ISNULL(se.DiasDisponibles, 0)
	FROM Intranet.tblSolicitudesEmpleado AS se
		INNER JOIN @dtEmpleados cem ON se.IDEmpleado = cem.IDEmpleado
		LEFT OUTER JOIN Intranet.tblCatTipoSolicitud AS cts ON se.IDTipoSolicitud = cts.IDTipoSolicitud
		LEFT OUTER JOIN Intranet.tblCatEstatusSolicitudes AS ces ON se.IDEstatusSolicitud = ces.IDEstatusSolicitud
		--LEFT JOIN RH.tblCatArea cca ON cem.IDArea = cca.IDArea 
		LEFT JOIN [RH].[tblAreaEmpleado] cca WITH(NOLOCK) ON cca.IDEmpleado = cem.IDEmpleado AND cca.FechaIni<= @FechaFin  and cca.FechaFin >= @FechaFin        
		LEFT JOIN RH.tblDepartamentoEmpleado tde ON tde.IDEmpleado = cem.IDEmpleado AND tde.FechaIni<= @FechaFin  and tde.FechaFin >= @FechaFin        
		left join RH.tblCatDepartamentos d on d.IDDepartamento = tde.IDDepartamento
		LEFT JOIN RH.tblCentroCostoEmpleado cce ON cce.IDEmpleado = cem.IDEmpleado AND cce.FechaIni<= @FechaFin  and cce.FechaFin >= @FechaFin     
		left join RH.tblCatCentroCosto cc on cc.IDCentroCosto = cce.IDCentroCosto
	WHERE se.IDTipoSolicitud = 1
		AND ( 
			   (se.FechaIni BETWEEN @FechaInicio AND @FechaFin)
			OR (@FechaInicio BETWEEN se.FechaIni AND se.FechaFin)
		)
		--AND se.IDEstatusSolicitud != 3
		--AND se.IDEstatusSolicitud = 1
	
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
		Departamento,
		IDArea,
		IDCentroCosto,
		CentroCosto,
		ConfiguracionEventoCalendario,
		Duplicado,
		DiasDisponibles
	)
	SELECT 
		ie.IDIncidenciaEmpleado as IDSolicitud,
		ie.IDEmpleado,
		e.NOMBRECOMPLETO,
		999 as IDTipoSolicitud,
		'VACACIONES' AS DescripcionTipoSolicitud,
		ie.Autorizado as IDEstatusSolicitud,
		case when isnull(ie.Autorizado, 0) = 1 then 'AUTORIZADA' else 'NO AUTORIZADA' end AS DescripcionEstatusSolicitud,
		'V' as IDIncidencia,
		ie.Fecha as FechaIni,
		ie.Fecha as FechaFin,
		1 as CantidadDias,
		ie.FechaHoraCreacion as FechaCreacion,
		ie.Comentario as ComentarioEmpleado,
		0 as CantidadMonto,
		ie.AutorizadoPor as IDUsuarioAutoriza,
		null as DiasDescanso,
		ISNULL(tde.IDDepartamento, 0) AS IDDepartamento,
		ISNULL(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')),  '[SIN DEPARTAMENTO]'),
		ISNULL(cca.IDArea, 0) AS IDArea,
		ISNULL(cce.IDCentroCosto, 0) AS IDCentroCosto,
		ISNULL(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', ''+lower(replace(@IDIdioma, '-',''))+'', 'Descripcion')), '[SIN CENTRO DE COSTO]'),
		isnull(cc.ConfiguracionEventoCalendario, @DEFAULT_CONFIG_EVENTO_CALENDARIO) as ConfiguracionEventoCalendario,
		0 AS RN,
		0 as DiasDisponibles
	from Asistencia.tblIncidenciaEmpleado ie
		join @dtEmpleados e on e.IDEmpleado = ie.IDEmpleado		
		LEFT JOIN [RH].[tblAreaEmpleado] cca WITH(NOLOCK) ON cca.IDEmpleado = ie.IDEmpleado AND cca.FechaIni<= @FechaFin  and cca.FechaFin >= @FechaFin        
		LEFT JOIN RH.tblDepartamentoEmpleado tde ON tde.IDEmpleado = e.IDEmpleado AND tde.FechaIni<= @FechaFin  and tde.FechaFin >= @FechaFin        
		left join RH.tblCatDepartamentos d on d.IDDepartamento = tde.IDDepartamento
		LEFT JOIN RH.tblCentroCostoEmpleado cce ON cce.IDEmpleado = e.IDEmpleado AND cce.FechaIni<= @FechaFin  and cce.FechaFin >= @FechaFin     
		left join RH.tblCatCentroCosto cc on cc.IDCentroCosto = cce.IDCentroCosto
	where ie.Fecha between @FechaInicio and @FechaFin and ie.IDIncidencia = 'V'
		and (select count(*)
			from @tblSolicitudesVacaciones
			where IDEmpleado = ie.IDEmpleado 
				and ie.Fecha between FechaIni and FechaFin) = 0
		
	--select * from @tblSolicitudesVacaciones

	-- Creamos las variables para el while
	SELECT @Counter = MIN(ID)
	FROM @tblSolicitudesVacaciones
	where IDTipoSolicitud != 999

	WHILE exists(select top 1 1
				from @tblSolicitudesVacaciones
				where ID >= @Counter and  IDTipoSolicitud != 999
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
		WHERE ID = @Counter

		BEGIN TRY
			DELETE
			FROM @tblTempVacaciones

			INSERT INTO @tblTempVacaciones
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,
				null,
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
		WHERE tblS.ID = @Counter

		INSERT INTO @Fechas (Fecha)
		EXEC [App].[spListaFechas] @FechaIniQry, @FechaFinQry

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

		SELECT @Counter = MIN(ID)
		FROM @tblSolicitudesVacaciones
		WHERE ID > @Counter and  IDTipoSolicitud != 999
	END

	update ss
		set ss.Duplicado = case when exists
								(select top 1 IDSolicitud 
								from @tblSolicitudesVacaciones CTE
								where (CTE.IDSolicitud != ss.IDSolicitud and CTE.IDEmpleado != ss.IDEmpleado) and
									ss.IDCentroCosto=CTE.IDCentroCosto 
											AND ss.IDDepartamento = CTE.IDDepartamento
											AND ( (ss.FechaIni BETWEEN CTE.FechaIni AND CTE.FechaFin) OR (ss.FechaFin BETWEEN CTE.FechaIni AND CTE.FechaFin))) then 1 else 0 end
	from @tblSolicitudesVacaciones ss

	--select *
	--from  @tblSolicitudesVacaciones

	INSERT INTO @dtEventos (id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor,[data])
	SELECT 
		IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (IDIncidencia,' - ',NOMBRECOMPLETO,' (',CantidadDias,'/',DiasDisponibles,')'),
		1,
		FechaIni,
		FechaFin,
		'',
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- color
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- backgroundColor #9999ff
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- borderColor
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- textColo
		--,NULL
		(
			select *
			from (
				select 
					case when isnull(Duplicado, 0) = 1 then 1 else 0 end as Duplicado,
					DescripcionTipoSolicitud,
					coalesce(IDIncidencia, '')+coalesce(cast(IDSolicitud as varchar(20)), '') IDSolicitud,
					Departamento,
					CentroCosto
			) info
			for json auto, without_array_wrapper
		) as [data]
		--CONCAT ('{ "Duplicado": ', Duplicado, ', "DescripcionTipoSolicitud": "', DescripcionTipoSolicitud, '", "IDSolicitud" : "', IDIncidencia, IDSolicitud, '"  }')
	FROM @tblSolicitudesVacaciones
	WHERE IDTipoSolicitud = 1 

	UNION

	SELECT IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (IDIncidencia,' - ',NOMBRECOMPLETO),
		1,
		FechaIni,
		FechaFin,
		'',
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- color
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- backgroundColor #9999ff
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- borderColor
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- textColo
		--,NULL
		(
			select *
			from (
				select 
					case when isnull(Duplicado, 0) = 1 then 1 else 0 end as Duplicado,
					DescripcionTipoSolicitud,
					coalesce(IDIncidencia, '')+coalesce(cast(IDSolicitud as varchar(20)), '') IDSolicitud,
					Departamento,
					CentroCosto
			) info
			for json auto, without_array_wrapper
		) as [data]
		--CONCAT ('{ "Duplicado": ', Duplicado, ', "DescripcionTipoSolicitud": "', DescripcionTipoSolicitud, '", "IDSolicitud" : "', IDIncidencia, IDSolicitud, '"  }')
	FROM @tblSolicitudesVacaciones
	WHERE IDTipoSolicitud = 999 

	UNION

	SELECT IDSolicitud,
		IDTipoSolicitud,
		IDEmpleado,
		CONCAT (IDIncidencia, ' - ', NOMBRECOMPLETO,' (', CantidadDias, '/', DiasDisponibles, ')'),
		1,
		FechaIni,
		FechaFin,
		'#000000',
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- color
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- backgroundColor #9999ff
		JSON_VALUE(ConfiguracionEventoCalendario, '$.BackgroundColor'), -- borderColor
		JSON_VALUE(ConfiguracionEventoCalendario, '$.Color'), -- textColor
		(
			select *
			from (
				select 
					case when isnull(Duplicado, 0) = 1 then 1 else 0 end as Duplicado,
					DescripcionTipoSolicitud,
					coalesce(IDIncidencia, '')+coalesce(cast(IDSolicitud as varchar(20)), '') IDSolicitud,
					Departamento,
					CentroCosto
			) info
			for json auto, without_array_wrapper
		) as [data]
		--CONCAT ('{ "Duplicado": ',Duplicado,', "DescripcionTipoSolicitud": "',DescripcionTipoSolicitud,'", "IDSolicitud" : "',IDIncidencia,IDSolicitud,'"  }' )
	FROM @tblSolicitudesVacaciones
	WHERE IDTipoSolicitud = 2

	UNION

	--SELECT IDSolicitud,
	--	IDTipoSolicitud,
	--	IDEmpleado,
	--	CONCAT (
	--		'Actualización de Datos: ',
	--		NOMBRECOMPLETO
	--		),
	--	1,
	--	FechaCreacion,
	--	FechaCreacion,
	--	'#000000',
	--	'#993399',
	--	NULL,
	--	NULL,
	--	NULL,
	--	NULL
	--FROM @tblActualizacionDatos

	--UNION

	SELECT IDSolicitudPrestamo,
		IDTipoPrestamo,
		IDEmpleado,
		CONCAT ('Préstamo: ',NOMBRECOMPLETO,' (','$ ',FORMAT(MontoPrestamo, 'N2'),')'),
		1,
		FechaCreacion,
		FechaCreacion,
		NULL,
		JSON_VALUE(@DEFAULT_CONFIG_EVENTO_CALENDARIO, '$.Color'), -- color
		JSON_VALUE(@DEFAULT_CONFIG_EVENTO_CALENDARIO, '$.BackgroundColor'), -- backgroundColor #9999ff
		JSON_VALUE(@DEFAULT_CONFIG_EVENTO_CALENDARIO, '$.BackgroundColor'), -- borderColor
		JSON_VALUE(@DEFAULT_CONFIG_EVENTO_CALENDARIO, '$.Color'), -- textColo
		--NULL
		(
			select *
			from (
				select 
					Departamento,
					CentroCosto
			) info
			for json auto, without_array_wrapper
		) as [data]
	FROM @tblSolicitudPrestamo

	SELECT id,
		TipoEvento,
		v.IDEmpleado,
		title,
		allDay,
		[start],
		[end],
		[url],
		color,
		backgroundColor,
		borderColor,
		textColor,
		[data],
        ClaveEmpleado,
		m.NombreCompleto,
		SUBSTRING(coalesce(m.Nombre, ''), 1, 1)+SUBSTRING(coalesce(m.Paterno, coalesce(m.Materno, '')), 1, 1) as Iniciales
	FROM @dtEventos v
    inner join rh.tblEmpleadosMaster m on m.IDEmpleado = v.IDEmpleado
	ORDER BY
		--idempleado
		id,
		TipoEvento ASC,
		IDEmpleado
GO
