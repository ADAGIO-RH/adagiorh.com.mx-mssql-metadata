USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [Asistencia].[spBorrarCatIncidencia]  
(  
  @IDIncidencia varchar(10)
 ,@IDUsuario int
) as  
BEGIN  

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatIncidencias] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDIncidencia = @IDIncidencia

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatIncidencias]','[Asistencia].[spBorrarCatIncidencia]','DELETE','',@OldJSON
		
  
	delete Asistencia.tblCatIncidencias
	where IDIncidencia = @IDIncidencia

END;
GO
