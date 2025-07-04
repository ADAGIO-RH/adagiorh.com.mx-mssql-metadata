USE [p_adagioRHIndustrialMefi]
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

    	SELECT 
			IDGrupoHorario
			,Descripcion
            ,ROW_NUMBER()over(ORDER BY IDGrupoHorario)as ROWNUMBER
		FROM [Asistencia].[tblCatGruposHorarios]
		WHERE IDGrupoHorario = @IDGrupoHorario

	select @OldJSON = a.JSON from [Asistencia].[tblCatGruposHorarios] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDGrupoHorario = @IDGrupoHorario

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatGruposHorarios]','[Asistencia].[spBorrarCatGruposHorarios]','DELETE','',@OldJSON
		

	delete Asistencia.tblDetalleGrupoHorario
	where IDGrupoHorario = @IDGrupoHorario

	delete [Asistencia].[tblCatGruposHorarios]  
	where IDGrupoHorario = @IDGrupoHorario
END;
GO
