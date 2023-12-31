USE [q_adagioRHTuning]
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

			exec [Asistencia].[spBuscarEventosCalendarioDuplicados] '2022-04-01','2022-05-06', 1  
  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor  Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Asistencia].[spBuscarEventosCalendarioDuplicados](
	@FechaInicio date  --= '2022-04-25'
	,@FechaFin	date   --= '2022-06-05'
	,@IDUsuario int-- = 1
) as

	declare 
		@dtEventos [Asistencia].[dtEventoCalendario] 
		,@tblFechasMaster [App].[dtFechas] 
		,@dtEmpleados RH.dtEmpleados 
		,@Fechas [App].[dtFechas]
		
		,@IDEmpleadoUsuario int = 0
		,@DiasDisponibles int = 0
		,@CALENDARIO0001 bit = 0
		,@EsSupervisor bit = 0
		
		,@Counter INT  
		,@MaxId INT
		,@IDEmpleado int
		,@FechaIniQry date
		,@FechaFinQry date
		,@IDDepartamento int
		,@IDArea int
		,@Duplicado bit 
		,@DiasDescansoTrabajador varchar(4000)
		,@IDTipoSolicitud int
	;

	if(OBJECT_ID('tempdb..#templistaSolicitudesRN') is not null) drop table #templistaSolicitudesRN

	declare @tblSolicitudesVacaciones as table(
		 IDSolicitud int
		,IDEmpleado int
		,NOMBRECOMPLETO varchar(4000)
		,IDTipoSolicitud int
		,DescripcionTipoSolicitud varchar(4000)
		,IDEstatusSolicitud int
		,DescripcionEstatusSolicitud varchar(4000)
		,IDIncidencia varchar(4000)
		,FechaIni date
		,FechaFin date
		,CantidadDias int
		,FechaCreacion date
		,ComentarioEmpleado varchar(4000)
		,CantidadMonto decimal(18,4)
		,IDUsuarioAutoriza int
		,DiasDescanso varchar(4000)
		,IDDetalleFiltrosEmpleadosUsuarios int
		,IDUsuario int
		,Filtro varchar(4000)
		,ValorFiltro varchar(4000)
		,IDCatFiltroUsuario int
		,IDDepartamento int
		,IDArea int
		,Duplicado bit
		,DiasDisponibles int
	)
	declare @tblSolicitudPrestamo as table(
		IDSolicitudPrestamo int
		,IDEmpleado int
		,NOMBRECOMPLETO varchar(4000)
		,IDTipoPrestamo int
		,MontoPrestamo decimal(18,2)	
		,FechaCreacion date	
		,IDEstatusSolicitudPrestamo int
	)
	declare @tblTempVacaciones as table(
		Anio int
		,FechaIni date
		,FechaFin date
		,Dias int
		,DiasTomados int
		,DiasVencidos int
		,DiasDisponibles decimal(18,2)
		,TipoPrestacion varchar(500)
	)
	declare @tblFechasSolicitud as table(
		 IDSolicitud int
		,IDEmpleado int
		,Fecha date
		,IDArea int
		,IDDepartamento int
		,RN bit NOT NULL DEFAULT 0
	)
	declare @tblActualizacionDatos as table (
		IDSolicitud int
		,NOMBRECOMPLETO varchar(4000)
		,IDEmpleado int
		,IDTipoSolicitud int
		,FechaCreacion date
		,IDEstatusSolicitud int
		,IDIncidencia varchar(4000)
	)
	declare @DiasDescanso as table (Dia int)
	declare @tblDuplicadosArea as table(Fecha date, IDArea int, Cantidad int)
	declare @tblDuplicadosDepartamento as table(Fecha date, IDDepartamento int, Cantidad int)

	select
		@IDEmpleadoUsuario = IDEmpleado,
		@EsSupervisor = Supervisor
	from Seguridad.tblUsuarios
	where IDUsuario = @IDUsuario

	if (isnull(@EsSupervisor, 0) = 1)
	begin
		insert @dtEmpleados(IDEmpleado, ClaveEmpleado, NOMBRECOMPLETO)
		select em.IDEmpleado, ClaveEmpleado, NOMBRECOMPLETO
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario	
		where em.Vigente = 1
			and em.IDEmpleado <> @IDEmpleadoUsuario
	end

	-- Subordinados
	insert @dtEmpleados(IDEmpleado, ClaveEmpleado, NOMBRECOMPLETO)
	select em.IDEmpleado, ClaveEmpleado, NOMBRECOMPLETO
	from [RH].[tblEmpleadosMaster] em with (nolock)
		join RH.tblJefesEmpleados dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDJefe = @IDEmpleadoUsuario
	where em.Vigente = 1 and em.IDEmpleado <> @IDEmpleadoUsuario
	
	if exists(select top 1 1 
		from Seguridad.tblPermisosEspecialesUsuarios pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where cpe.Codigo = 'CALENDARIO0001')
	begin
		set @CALENDARIO0001 = 1
	end;

-- Insertamos las fechas en la tabla master

-- Declaración de Variables
--Tablas
	insert into @tblFechasMaster(Fecha)
	exec [App].[spListaFechas]@FechaInicio, @FechaFin	

	insert into @tblSolicitudPrestamo (
		IDSolicitudPrestamo
		,IDEmpleado
		,NOMBRECOMPLETO
		,IDTipoPrestamo
		,MontoPrestamo	
		,FechaCreacion
		,IDEstatusSolicitudPrestamo
	)
	select 
		IDSolicitudPrestamo,
		tsp.IDEmpleado,
		tem.NOMBRECOMPLETO,
		'6',
		MontoPrestamo,
		FechaCreacion,
		IDEstatusSolicitudPrestamo
	from Intranet.tblSolicitudesPrestamos tsp 
		left join @dtEmpleados tem on tsp.IDEmpleado = tem.IDEmpleado
	where FechaCreacion between @FechaInicio and @FechaFin
		and tsp.IDEstatusSolicitudPrestamo = 1 

	-- Consulta e inserta todas las peticiones en ese rango de fechas
	insert into @tblSolicitudesVacaciones (
		IDSolicitud
		,IDEmpleado
		,NOMBRECOMPLETO
		,IDTipoSolicitud
		,DescripcionTipoSolicitud
		,IDEstatusSolicitud
		,DescripcionEstatusSolicitud
		,IDIncidencia
		,FechaIni
		,FechaFin
		,CantidadDias
		,FechaCreacion
		,ComentarioEmpleado
		,CantidadMonto
		,IDUsuarioAutoriza
		,DiasDescanso
		--,IDDetalleFiltrosEmpleadosUsuarios
		--,IDUsuario
		--,Filtro
		--,ValorFiltro
		--,IDCatFiltroUsuario
		,IDDepartamento
		,IDArea
		,Duplicado
		,DiasDisponibles
	)
	SELECT 
		se.IDSolicitud
		,se.IDEmpleado
		,cem.NOMBRECOMPLETO
		,se.IDTipoSolicitud
		,cts.Descripcion AS DescripcionTipoSolicitud
		,se.IDEstatusSolicitud
		,ces.Descripcion AS DescripcionEstatusSolicitud
		,se.IDIncidencia
		,se.FechaIni
		,isnull(se.FechaFin, se.FechaIni)
		,se.CantidadDias 
		,se.FechaCreacion
		,se.ComentarioEmpleado
		,se.CantidadMonto
		,se.IDUsuarioAutoriza
		,se.DiasDescanso
		--,dfeu.IDDetalleFiltrosEmpleadosUsuarios
		--,dfeu.IDUsuario
		--,dfeu.Filtro
		--,dfeu.ValorFiltro
		--,dfeu.IDCatFiltroUsuario
		,isnull(tde.IDDepartamento,0) as IDDepartamento
		,isnull(cca.IDArea,0) as IDArea
		,0 as RN
		,isnull(se.DiasDisponibles,0)
	FROM Intranet.tblSolicitudesEmpleado AS se 
		inner join @dtEmpleados cem on se.IDEmpleado = cem.IDEmpleado
		LEFT OUTER JOIN Intranet.tblCatTipoSolicitud AS cts ON se.IDTipoSolicitud = cts.IDTipoSolicitud 
		LEFT OUTER JOIN Intranet.tblCatEstatusSolicitudes AS ces ON se.IDEstatusSolicitud = ces.IDEstatusSolicitud
		left join RH.tblCatArea cca on cem.IDArea = cca.IDArea 
		left join RH.tblDepartamentoEmpleado tde on tde.IDEmpleado = cem.IDEmpleado
	where se.IDTipoSolicitud != 3 and
		se.FechaIni BETWEEN @FechaInicio AND @FechaFin 
			OR @FechaInicio BETWEEN se.FechaIni AND se.FechaFin
		and se.IDEstatusSolicitud = 1
	
	insert into @tblActualizacionDatos(
		IDSolicitud
		,NOMBRECOMPLETO
		,IDEmpleado
		,IDTipoSolicitud
		,FechaCreacion
		,IDEstatusSolicitud
		,IDIncidencia
	)
	select 
		IDSolicitud
		,NOMBRECOMPLETO
		,tse.IDEmpleado
		,IDTipoSolicitud
		,FechaCreacion
		,IDEstatusSolicitud
		,IDIncidencia
	 from Intranet.tblSolicitudesEmpleado tse 
		join @dtEmpleados tem on tse.IDEmpleado = tem.IDEmpleado
	where IDTipoSolicitud = 3
		and FechaCreacion between @FechaInicio and @FechaFin
		and tse.IDEstatusSolicitud = 1

	-- Creamos las variables para el while
	SELECT @Counter = min(IDSolicitud) , @MaxId = max(IDSolicitud) 
	FROM @tblSolicitudesVacaciones

	WHILE(@Counter IS NOT NULL
		 AND @Counter <= @MaxId)
	BEGIN
		SELECT
			@IDEmpleado = IDEmpleado,
			@FechaIniQry = FechaIni,
			@FechaFinQry = FechaFin,
			@IDArea = IDArea,
			@IDDepartamento = IDDepartamento,
			@DiasDescansoTrabajador = DiasDescanso,
			@IDTipoSolicitud = IDTipoSolicitud
		FROM @tblSolicitudesVacaciones WHERE IDSolicitud = @Counter
		
		begin try
			delete from @tblTempVacaciones

			insert into @tblTempVacaciones
			exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,1,@FechaIniQry,@IDUsuario

		end try
		begin catch
		end catch

		select @DiasDisponibles = floor(sum(DiasDisponibles)) from @tblTempVacaciones

		update tblS
			set tblS.DiasDisponibles = @DiasDisponibles 
		FROM @tblSolicitudesVacaciones as tblS WHERE tblS.IDSolicitud = @Counter 

		insert into @Fechas (Fecha)
		exec [App].[spListaFechas]@FechaIniQry,@FechaFinQry

		delete @Fechas
		where DiaSemana in (select convert(int, Item) 
		from App.Split(@DiasDescansoTrabajador, ','))

	 	insert into @tblFechasSolicitud (
			IDSolicitud
			,IDEmpleado
			,Fecha
			,IDArea
			,IDDepartamento
		)
		select @Counter,@IDEmpleado, Fecha,@IDArea, @IDDepartamento
		from @Fechas
	 
		delete from @Fechas

		SELECT @Counter = min(IDSolicitud) 
		FROM @tblSolicitudesVacaciones 
		where IDSolicitud > @Counter
	END

	select 
		m.Fecha, 
		fs.IDEmpleado,
		fs.IDSolicitud, 
		ROW_NUMBER()OVER(Partition by m.Fecha, fs.IDArea, fs.IDDepartamento order by m.fecha asc) as RNN
	into #templistaSolicitudesRN
	from @tblFechasMaster m
		left join @tblFechasSolicitud fs on m.Fecha = fs.Fecha

	;WITH CTE(
		IDSolicitud,
		DuplicateCount
	)
	AS (
		SELECT IDSolicitud,
			   ROW_NUMBER() OVER(PARTITION BY IDEmpleado, Fecha ORDER BY IDSolicitud) AS DuplicateCount
		FROM #templistaSolicitudesRN
	)

	delete FROM CTE
	WHERE DuplicateCount > 1;

	update @tblSolicitudesVacaciones 
		set Duplicado = 1
	where IDSolicitud in (
		select distinct IDSolicitud
		from #templistaSolicitudesRN
		where isnull(RNN,0) > 1
	)

	insert into @dtEventos(
		id
		,TipoEvento
		,IDEmpleado
		,title
		,allDay
		,start
		,[end]
		,url
		,color
		,backgroundColor
		,borderColor
		,textColor
		,[data]
	)
	select IDSolicitud, IDTipoSolicitud, IDEmpleado, concat(IDIncidencia, ' - ', NOMBRECOMPLETO, ' (', CantidadDias,'/', DiasDisponibles,')'), 1, FechaIni, FechaFin, '#000000', '#9999ff', null, null, null, 
		concat('{ "Duplicado": ', Duplicado,', "DescripcionTipoSolicitud": "', DescripcionTipoSolicitud, '", "IDSolicitud" : "', IDIncidencia, IDSolicitud, '"  }' ) 
	from @tblSolicitudesVacaciones where @IDTipoSolicitud = 1
	union
	select IDSolicitud, IDTipoSolicitud, IDEmpleado, concat(IDIncidencia, ' - ', NOMBRECOMPLETO, ' (', CantidadDias,'/', DiasDisponibles,')'), 1, FechaIni, FechaFin, '#000000', '#0099ff', null, null, null, 
		concat('{ "Duplicado": ', Duplicado,', "DescripcionTipoSolicitud": "', DescripcionTipoSolicitud, '", "IDSolicitud" : "', IDIncidencia, IDSolicitud, '"  }' )   
	from @tblSolicitudesVacaciones where @IDTipoSolicitud = 2
	union
	select IDSolicitud, IDTipoSolicitud, IDEmpleado, concat('Actualización de Datos: ', NOMBRECOMPLETO), 1, FechaCreacion, FechaCreacion, '#000000', '#993399', null, null, null, null 
	from @tblActualizacionDatos
	union
	select IDSolicitudPrestamo, IDTipoPrestamo, IDEmpleado, concat('Préstamo: ',NOMBRECOMPLETO,' (', '$ ',FORMAT(MontoPrestamo,'N2'),')'), 1, FechaCreacion, FechaCreacion, null, '#9b9b9b','#000000', null, null, null 
	from @tblSolicitudPrestamo

	select 
		id
		,TipoEvento
		,IDEmpleado
		,title
		,allDay
		,[start]
		,[end]
		,[url]
		,color
		,backgroundColor
		,borderColor
		,textColor 
		,[data] 
	from @dtEventos 
	order by id, TipoEvento asc, IDEmpleado
GO
