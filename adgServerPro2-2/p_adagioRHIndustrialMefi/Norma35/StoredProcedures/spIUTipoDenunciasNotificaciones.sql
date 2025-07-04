USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIUTipoDenunciasNotificaciones]
(
	 @IDTipoDenunciasNotificacion INT = 0
	,@IDTipoDenuncia int
	,@IDUsuario int
	,@EmailAsignado varchar(255)
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		    @NewJSON Varchar(Max);

	IF(ISNULL(@IDTipoDenunciasNotificacion,0) = 0)
	BEGIN
		INSERT INTO [Norma35].[tblTipoDenunciasNotificaciones]
           ([IDTipoDenuncia]
           ,[IDUsuario]
           ,[EmailAsignado])
		VALUES
           (@IDTipoDenuncia
           ,@IDUsuario
           ,@EmailAsignado)

		SET  @IDTipoDenunciasNotificacion = @@IDENTITY

		select @NewJSON = a.JSON from [Norma35].[tblTipoDenunciasNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenunciasNotificacion = @IDTipoDenunciasNotificacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblTipoDenunciasNotificaciones]','[Norma35].[spIUTipoDenunciasNotificaciones]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	
		select @OldJSON = a.JSON from [Norma35].[tblTipoDenunciasNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenunciasNotificacion = @IDTipoDenunciasNotificacion

		UPDATE [Norma35].[tblTipoDenunciasNotificaciones]
		SET [IDTipoDenuncia] = @IDTipoDenuncia
			,[IDUsuario] = @IDUsuario
			,[EmailAsignado] = @EmailAsignado
		WHERE [IDTipoDenunciasNotificacion] = @IDTipoDenunciasNotificacion
		
		select @NewJSON = a.JSON from [Norma35].[tblTipoDenunciasNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenunciasNotificacion = @IDTipoDenunciasNotificacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblTipoDenunciasNotificaciones]','[Norma35].[spIUTipoDenunciasNotificaciones]','UPDATE',@NewJSON,@OldJSON		

	END

END;
GO
