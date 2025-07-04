USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Asistencia].[spBuscarDetalleGrupoHorario](
    @IDGrupoHorario int =  null
)as
begin
    select dgh.IDDetalleGrupoHorario
		,dgh.IDGrupoHorario
		,dgh.IDHorario
		,ch.IDTurno
		,ct.Descripcion as Turno
		,ch.Codigo as CodigoHorario
		,ch.Descripcion as DescripcionHorario
    from [Asistencia].[tblDetalleGrupoHorario] dgh
	   join [Asistencia].[tblCatHorarios] ch on dgh.IDHorario = ch.IDHorario
	   join [Asistencia].[tblCatTurnos] ct on ch.IDTurno = ct.IDTurno
    where dgh.IDGrupoHorario = @IDGrupoHorario
end
GO
