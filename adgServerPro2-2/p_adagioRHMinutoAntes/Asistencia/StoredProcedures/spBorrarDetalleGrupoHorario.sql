USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [Asistencia].[spBorrarDetalleGrupoHorario](
	@IDDetalleGrupoHorario int
) as
begin

    delete from [Asistencia].[tblDetalleGrupoHorario]
    where IDDetalleGrupoHorario=@IDDetalleGrupoHorario
end
GO
