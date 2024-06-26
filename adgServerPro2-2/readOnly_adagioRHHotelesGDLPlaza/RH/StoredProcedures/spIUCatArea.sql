USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatArea]
(
	@IDArea int = 0,
	@Codigo varchar(20),
	@Descripcion Varchar(50),
	@CuentaContable Varchar(25),
	@IDEmpleado int = 0,
	@JefeArea varchar(100),
	@IDUsuario int
)
AS
BEGIN
	 select @Codigo = UPPER(@Codigo)
	 , @Descripcion = UPPER(@Descripcion)
	 , @CuentaContable = UPPER(@CuentaContable)
	 , @JefeArea = UPPER(@JefeArea);
	 	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	IF(@IDArea = 0 OR @IDArea Is null)
	BEGIN
		  IF EXISTS(Select Top 1 1 from RH.[tblCatArea] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatArea]
				   ([Codigo]
				   ,[Descripcion]
				   ,[CuentaContable]
				   ,[IDEmpleado]
				   ,[JefeArea]
				   )
			 VALUES
				   (@Codigo
				   ,@Descripcion
				   ,@CuentaContable
				   ,case when @IDEmpleado = 0 then null else @IDEmpleado end
				   ,@JefeArea)
		set @IDArea = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatArea] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDArea=@IDArea;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spIUCatArea]','INSERT',@NewJSON,''

		SELECT 
				IDArea
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,[JefeArea]
		FROM [RH].[tblCatArea]
		WHERE IDArea = @IDArea

	END
	ELSE
	BEGIN
		  IF EXISTS(Select Top 1 1 from RH.[tblCatArea] where Codigo = @Codigo and IDArea <> @IDArea)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		
		select @OldJSON = a.JSON from [RH].[tblCatArea] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDArea=@IDArea;

		

		UPDATE [RH].[tblCatArea]
		   SET [Codigo] = @Codigo
			  ,[Descripcion] = @Descripcion
			  ,[CuentaContable] = @CuentaContable
			  ,[IDEmpleado]=case when @IDEmpleado = 0 then null else @IDEmpleado end
			  ,[JefeArea] = @JefeArea
		 WHERE IDArea= @IDArea

		 	select @NewJSON = a.JSON from [RH].[tblCatArea] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDArea=@IDArea;

		 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spIUCatArea]','UPDATE',@NewJSON,@OldJSON

		 	SELECT 
				IDArea
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,[JefeArea]
		FROM [RH].[tblCatArea]
		WHERE IDArea = @IDArea

	END
END
GO
