USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarHorariosPorGrupo](
    @IDUsuario int
) as
    select 
	    cgh.IDGrupoHorario
	   ,cgh.Descripcion  as GrupoHorario
	   ,ch.IDHorario
	   ,ch.Codigo
	   ,ch.IDTurno
	   ,ct.Descripcion as Turno
	   ,ch.Descripcion
	   ,ch.HoraEntrada
	   ,ch.HoraSalida
	   ,ch.TiempoTotal
	   ,ch.TiempoDescanso
	   ,ch.JornadaLaboral
    from Asistencia.tblCatGruposHorarios cgh
	   join Asistencia.tblDetalleGrupoHorario dgh on cgh.IDGrupoHorario = dgh.IDGrupoHorario
	   join [Asistencia].[tblCatHorarios] ch on ch.IDHorario = dgh.IDHorario
	   join [Asistencia].[tblCatTurnos] ct with (nolock) on ch.IDTurno = ct.IDTurno
    order by ch.HoraEntrada asc
GO
