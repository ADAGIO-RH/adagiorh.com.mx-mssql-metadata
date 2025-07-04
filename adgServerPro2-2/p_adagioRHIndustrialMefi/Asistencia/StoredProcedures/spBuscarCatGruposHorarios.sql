USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarCatGruposHorarios]
(
  @IDGrupoHorario int = null
  ,@IDUsuario int
) as
begin
    select IDGrupoHorario,Descripcion,ROW_NUMBER()over(ORDER BY IDGrupoHorario)as ROWNUMBER 
    from [Asistencia].[tblCatGruposHorarios] with (nolock)
    where (IDGrupoHorario= @IDGrupoHorario or isnull(@IDGrupoHorario,0) = 0)
end;
GO
