USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIUCatTiposDenuncias]
(
	 @IDTipoDenuncia INT = 0
	,@Descripcion VARCHAR(500)
	,@Disponible BIT
	,@IDUsuario INT
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		    @NewJSON Varchar(Max);

	set @Descripcion = UPPER(@Descripcion)

	IF(ISNULL(@IDTipoDenuncia,0) = 0)
	BEGIN

		INSERT INTO [Norma35].[tblCatTiposDenuncias]
				   ([Descripcion]
				   ,[Disponible])
			 VALUES
				   (@Descripcion
				   ,@Disponible)

		SET @IDTipoDenuncia = @@IDENTITY

		select @NewJSON = a.JSON from [Norma35].[tblCatTiposDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenuncia = @IDTipoDenuncia

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblCatTiposDenuncias]','[Norma35].[spIUCatTiposDenuncias]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [Norma35].[tblCatTiposDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenuncia = @IDTipoDenuncia


		UPDATE [Norma35].[tblCatTiposDenuncias]
		   SET [Descripcion]  = @Descripcion
			  ,[Disponible]   = @Disponible
		 WHERE IDTipoDenuncia = @IDTipoDenuncia

		select @NewJSON = a.JSON from [Norma35].[tblCatTiposDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDenuncia = @IDTipoDenuncia

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblCatTiposDenuncias]','[Norma35].[spIUCatTiposDenuncias]','UPDATE',@NewJSON,@OldJSON		


	END

	EXEC [Norma35].[spBuscarCatTiposDenuncias]  @IDTipoDenuncia = @IDTipoDenuncia, @IDUsuario = @IDUsuario
END;
GO
