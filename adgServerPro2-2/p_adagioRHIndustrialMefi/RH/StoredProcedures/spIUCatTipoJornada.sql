USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatTipoJornada]
(
	@IDTipoJornada int = 0
	,@Descripcion varchar(50)
	,@IDSatTipoJornada int,
	@IDUsuario int
)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	

	IF (@IDTipoJornada = 0 or @IDTipoJornada is null)
	BEGIN
	
		INSERT INTO [RH].[tblCatTipoJornada]
				   (
					 [Descripcion]
					 ,[IDSatTipoJornada]
				   )
			 VALUES
				   (
				  @Descripcion
				  ,@IDSatTipoJornada
				   )
		set @IDTipoJornada = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatTipoJornada] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoJornada = @IDTipoJornada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoJornada]','[RH].[spIUCatTipoJornada]','insert',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblCatTipoJornada] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoJornada = @IDTipoJornada

		UPDATE [RH].[tblCatTipoJornada]
		   SET   [Descripcion] = @Descripcion
				,[IDSatTipoJornada] = @IDSatTipoJornada
		 WHERE [IDTipoJornada] = @IDTipoJornada

		select @NewJSON = a.JSON from [RH].[tblCatTipoJornada] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoJornada = @IDTipoJornada
		  
		  EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoJornada]','[RH].[spIUCatTipoJornada]','insert',@NewJSON,@OldJSON


	END
END
GO
