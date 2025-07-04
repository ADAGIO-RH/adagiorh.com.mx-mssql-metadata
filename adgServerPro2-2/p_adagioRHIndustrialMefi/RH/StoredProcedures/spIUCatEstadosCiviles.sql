USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatEstadosCiviles]
(
	@IDEstadoCivil int = 0,
	@Codigo varchar(20),
	@Descripcion Varchar(50),
	@IDUsuario int
)
AS
BEGIN
	SET @Codigo = UPPER(@Codigo)
	SET @Descripcion = UPPER(@Descripcion)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDEstadoCivil = 0 OR @IDEstadoCivil Is null)
	BEGIN
		INSERT INTO [RH].[tblCatEstadosCiviles]
				   ([Codigo]
				   ,[Descripcion])
			 VALUES
				   (@Codigo
				   ,@Descripcion)
		set @IDEstadoCivil = @@IDENTITY



		SELECT 
				IDEstadoCivil
				,Codigo
				,Descripcion
		FROM [RH].[tblCatEstadosCiviles]
		WHERE IDEstadoCivil = @IDEstadoCivil

			

		select @NewJSON = a.JSON from [RH].[tblCatEstadosCiviles] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEstadoCivil = @IDEstadoCivil

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatEstadosCiviles]','[RH].[spIUCatEstadosCiviles]','INSERT',@NewJSON,''



	END
	ELSE
	BEGIN

	
		select @OldJSON = a.JSON from [RH].[tblCatEstadosCiviles] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEstadoCivil = @IDEstadoCivil

		

		UPDATE [RH].[tblCatEstadosCiviles]
		   SET [Codigo] = @Codigo
			  ,[Descripcion] = @Descripcion
		 WHERE IDEstadoCivil= @IDEstadoCivil

		 
		select @NewJSON = a.JSON from [RH].[tblCatEstadosCiviles] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEstadoCivil = @IDEstadoCivil


		 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatEstadosCiviles]','[RH].[spIUCatEstadosCiviles]','UPDATE',@NewJSON,@OldJSON

		 SELECT 
				IDEstadoCivil
				,Codigo
				,Descripcion
		FROM [RH].[tblCatEstadosCiviles]
		WHERE IDEstadoCivil = @IDEstadoCivil

	END
END
GO
