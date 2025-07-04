USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spBorrarCatTipoChecada](
	@IDTipoChecada varchar(10)
	,@IDUsuario int
) as

	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatTiposChecadas] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoChecada = @IDTipoChecada

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTiposChecadas]','[Asistencia].[spBorrarCatTipoChecada]','DELETE','',@OldJSON
		

	delete from  Asistencia.tblCatTiposChecadas
	where IDTipoChecada = @IDTipoChecada
GO
