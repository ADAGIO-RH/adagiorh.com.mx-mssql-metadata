USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.[spUCatTipoSolicitud](
	@IDTipoSolicitud int,
	@Intranet bit null,
	@SPValidaciones Varchar(max) null,
	@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	IF(ISNULL(@IDTipoSolicitud,0) > 0 )
	BEGIN
		SELECT @OldJSON = a.JSON from [Intranet].[tblCatTipoSolicitud] b
			CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoSolicitud = @IDTipoSolicitud

		UPDATE [Intranet].[tblCatTipoSolicitud]
			SET Intranet = isnull(@Intranet,0),
				SPValidaciones = UPPER(@SPValidaciones)
		WHERE IDTipoSolicitud = @IDTipoSolicitud

		SELECT @NewJSON = a.JSON from [Intranet].[tblCatTipoSolicitud] b
			CROSS APPLY  (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoSolicitud = @IDTipoSolicitud

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Intranet].[tblCatTipoSolicitud]','Intranet.[spUCatTipoSolicitud]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
