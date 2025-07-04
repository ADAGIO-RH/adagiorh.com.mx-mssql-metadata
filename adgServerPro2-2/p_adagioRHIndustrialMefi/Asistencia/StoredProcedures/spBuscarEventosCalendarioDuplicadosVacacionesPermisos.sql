USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Asistencia].[spBuscarEventosCalendarioDuplicadosVacacionesPermisos](
	@FechaInicio date 
	,@FechaFin date 
)
as 

	declare @Fechas [App].[dtFechasFull]

-- Insertamos las fechas en la tabla master

-- Declaración de Variables
--Tablas
	declare @tblFechasMaster [App].[dtFechasFull]
	insert into @tblFechasMaster(Fecha)
	exec [App].[spListaFechas]@FechaInicio, @FechaFin	

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
)

declare @tblFechasSolicitud as table(
	 IDSolicitud int
	,IDEmpleado int
	,Fecha date
	,RN bit NOT NULL DEFAULT 0
)

declare @DiasDescanso as table (Dia int)
declare @tblDuplicadosArea as table(Fecha date, IDArea int, Cantidad int)
declare @tblDuplicadosDepartamento as table(Fecha date, IDDepartamento int, Cantidad int)

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
	,IDDetalleFiltrosEmpleadosUsuarios
	,IDUsuario
	,Filtro
	,ValorFiltro
	,IDCatFiltroUsuario
	,IDDepartamento
	,IDArea
	,Duplicado)
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
	,se.FechaFin
	,se.CantidadDias 
	,se.FechaCreacion
	,se.ComentarioEmpleado
	,se.CantidadMonto
	,se.IDUsuarioAutoriza
	,se.DiasDescanso
	,dfeu.IDDetalleFiltrosEmpleadosUsuarios
	,dfeu.IDUsuario
	,dfeu.Filtro
	,dfeu.ValorFiltro
	,dfeu.IDCatFiltroUsuario
	,isnull(tde.IDDepartamento,0) as IDDepartamento
	,isnull(cca.IDArea,0) as IDArea
	,0 as RN
FROM
	Intranet.tblSolicitudesEmpleado AS se 
	INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios AS dfeu ON dfeu.IDEmpleado = se.IDEmpleado AND dfeu.IDUsuario = 1 
	LEFT OUTER JOIN Intranet.tblCatTipoSolicitud AS cts ON se.IDTipoSolicitud = cts.IDTipoSolicitud 
	LEFT OUTER JOIN Intranet.tblCatEstatusSolicitudes AS ces ON se.IDEstatusSolicitud = ces.IDEstatusSolicitud
	left join RH.tblEmpleadosMaster cem on se.IDEmpleado = cem.IDEmpleado
	left join RH.tblCatArea cca on cem.IDArea = cca.IDArea 
	left join RH.tblDepartamentoEmpleado tde  on  tde.IDEmpleado = cem.IDEmpleado
where 
	se.FechaIni >= @FechaInicio and se.FechaFin <= @FechaFin

	DECLARE @Counter INT , @MaxId INT, 
			@IDEmpleado int,
			@FechaIniQry date, @FechaFinQry date,
			@IDDepartamento int, @IDArea int,
			@Duplicado bit, @DiasDescansoTrabajador varchar(4000),
			@IDTipoSolicitud int

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
		
	  insert into @Fechas (Fecha)
	  exec [App].[spListaFechas]@FechaIniQry,@FechaFinQry

	  delete @Fechas
	  where DiaSemana in (select convert(int,value) from  string_split(@DiasDescansoTrabajador, ','))

	  	insert into @tblFechasSolicitud (
								IDSolicitud
								,IDEmpleado
								,Fecha
				)
				select @Counter,@IDEmpleado, Fecha -- @Counter, @IDEmpleado, @IDTipoSolicitud, @IDArea, @IDDepartamento, @CounterFecha
				from @Fechas
	  
			delete from @Fechas

	   SELECT @Counter = min(IDSolicitud)  
		FROM @tblSolicitudesVacaciones  
		where IDSolicitud >@Counter
	END

	if(OBJECT_ID('tempdb..#templistaSolicitudesRN') is not null) drop table #templistaSolicitudesRN

	select m.Fecha, fs.IDEmpleado,fs.IDSolicitud , ROW_NUMBER()OVER(Partition by m.Fecha order by m.fecha asc) as RNN
		into #templistaSolicitudesRN
	from
		@tblFechasMaster m
		left join @tblFechasSolicitud fs
			on m.Fecha = fs.Fecha



	update @tblSolicitudesVacaciones set Duplicado = 1
	where IDSolicitud in (
	select distinct IDSolicitud from #templistaSolicitudesRN
	where isnull(RNN,0) > 1)


	--select IDSolicitud from @tblSolicitudesVacaciones where IDSolicitud in (
	--select distinct IDSolicitud from #templistaSolicitudesRN
	--where isnull(RNN,0) > 1)


	select * from @tblSolicitudesVacaciones

	---select * from  @tblSolicitudesVacaciones order by FechaIni
GO
