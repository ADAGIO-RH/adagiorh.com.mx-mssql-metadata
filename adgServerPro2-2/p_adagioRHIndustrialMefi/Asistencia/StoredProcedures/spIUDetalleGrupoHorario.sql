USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUDetalleGrupoHorario](
	@IDDetalleGrupoHorario int
    ,@IDGrupoHorario int
    ,@IDHorario int
    ,@IDUsuario int
)as
 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
    if exists (select 1 
			 from [Asistencia].[tblDetalleGrupoHorario] with (nolock)
			 where IDGrupoHorario=@IDGrupoHorario and IDHorario=@IDHorario)
    begin
	   exec [App].[spObtenerError] @IDUsuario=@IDUsuario,@CodigoError='0410001'
	   return;
    end;

    insert into  [Asistencia].[tblDetalleGrupoHorario](IDGrupoHorario,IDHorario)
    select @IDGrupoHorario,@IDHorario

	set @IDDetalleGrupoHorario = @@IDENTITY

		  select @NewJSON = a.JSON from [Asistencia].[tblDetalleGrupoHorario] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDetalleGrupoHorario = @IDDetalleGrupoHorario     

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblDetalleGrupoHorario]','[Asistencia].[spIUDetalleGrupoHorario]','INSERT',@NewJSON,''
GO
