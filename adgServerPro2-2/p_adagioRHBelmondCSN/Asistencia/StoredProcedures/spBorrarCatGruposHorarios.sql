USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Asistencia].[spBorrarCatGruposHorarios]  
(  
  @IDGrupoHorario int
 ,@IDUsuario int
) as  
BEGIN  
   DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatGruposHorarios] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDGrupoHorario = @IDGrupoHorario

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatGruposHorarios]','[Asistencia].[spBorrarCatGruposHorarios]','DELETE','',@OldJSON
		

	delete Asistencia.tblDetalleGrupoHorario
	where IDGrupoHorario = @IDGrupoHorario

	delete [Asistencia].[tblCatGruposHorarios]  
	where IDGrupoHorario = @IDGrupoHorario
END;
GO
