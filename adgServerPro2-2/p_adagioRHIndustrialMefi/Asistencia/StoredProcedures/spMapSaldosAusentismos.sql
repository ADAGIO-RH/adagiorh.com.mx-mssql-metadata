USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spMapSaldosAusentismos](
		@dtSaldosIncidencias [Asistencia].[dtSaldosAusentismos] readonly,
		@IDUsuario int
) as
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
		(2, 'El colaborador no existe', 0),
		(3, 'La fecha inicial no puede ser mayor a la fecha final', 0),
		(4, 'La incidencia no existe', 0),
		(5, 'La incidencia no permite Saldos', 0),
		(6, 'El colaborador no se encuentra vigente', 0)

	select 
		info.*,
		m.Message as Mensaje,
		m.Valid
	from (
		select
			isnull(e.IDEmpleado, 0) as IDEmpleado,
			su.ClaveEmpleado,
			e.NOMBRECOMPLETO as Colaborador,
			su.FechaInicio,
			su.FechaFin, 
			su.IDIncidencia,
			JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia,
			su.Cantidad,
			IDMensaje = case 
							when e.IDEmpleado is null then 2 
							when isnull(e.Vigente, 0) = 0 then 6
							when su.FechaInicio > su.FechaFin then 3
							when i.IDIncidencia is null then 4 
							when isnull(i.AdministrarSaldos, 0 ) = 0 then 5
						else 1 end
		from @dtSaldosIncidencias su
			left join RH.tblEmpleadosMaster e on e.ClaveEmpleado = su.ClaveEmpleado
			left join Asistencia.tblCatIncidencias i on i.IDIncidencia = su.IDIncidencia
	) info join @tempMessages m on m.ID = info.IDMensaje
	order by ClaveEmpleado
GO
