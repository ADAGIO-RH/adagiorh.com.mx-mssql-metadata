USE [p_adagioRHIndustrialMefi]
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
	@IDUsuario int,
    @Traduccion nvarchar(max)
)
AS
BEGIN
	 select @Codigo = UPPER(@Codigo)
	 , @Descripcion = UPPER(@Descripcion)
	 , @CuentaContable = UPPER(@CuentaContable)
	 , @JefeArea = UPPER(@JefeArea);
	 	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	IF(isnull(@IDArea, 0) = 0)
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
				   ,[Traduccion]
				   )
			 VALUES
				   (@Codigo
				   ,@Descripcion
				   ,@CuentaContable
				   ,case when @IDEmpleado = 0 then null else @IDEmpleado end
				   ,@JefeArea
				   ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)
		set @IDArea = @@IDENTITY

		select @NewJSON = (SELECT IDArea
                                ,Codigo
                                ,CuentaContable
                                ,JefeArea
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatArea]
                            WHERE IDArea = @IDArea FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spIUCatArea]','INSERT',@NewJSON,''

		SELECT 
				IDArea
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,[JefeArea]
				,[Traduccion]
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
		
		select @OldJSON = (SELECT IDArea
                                ,Codigo
                                ,CuentaContable
                                ,JefeArea
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatArea]
                            WHERE IDArea = @IDArea FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		

		UPDATE [RH].[tblCatArea]
		   SET [Codigo] = @Codigo
			  ,[Descripcion] = @Descripcion
			  ,[CuentaContable] = @CuentaContable
			  ,[IDEmpleado]=case when @IDEmpleado = 0 then null else @IDEmpleado end
			  ,[JefeArea] = @JefeArea
			  ,[Traduccion] = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		 WHERE IDArea= @IDArea

		 	select @NewJSON = (SELECT IDArea
                                ,Codigo
                                ,CuentaContable
                                ,JefeArea
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatArea]
                            WHERE IDArea = @IDArea FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spIUCatArea]','UPDATE',@NewJSON,@OldJSON

		 	SELECT 
				IDArea
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,[JefeArea]
				,Traduccion
		FROM [RH].[tblCatArea]
		WHERE IDArea = @IDArea

	END
END
GO
