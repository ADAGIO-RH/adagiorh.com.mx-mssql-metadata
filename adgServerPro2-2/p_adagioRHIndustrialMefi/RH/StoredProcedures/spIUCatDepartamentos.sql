USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatDepartamentos]
(
	@IDDepartamento int = 0
	,@Codigo varchar(20)
	,@Descripcion varchar(50)
	,@CuentaContable Varchar(25)
	,@IDEmpleado int
	,@JefeDepartamento Varchar(100)
	,@IDUsuario int 
    ,@Traduccion nvarchar(max)
)
AS
BEGIN

	SET @Codigo				= UPPER(@Codigo			)
	SET @Descripcion 		= UPPER(@Descripcion 	)
	SET @CuentaContable 	= UPPER(@CuentaContable )
	SET @JefeDepartamento 	= UPPER(@JefeDepartamento)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDDepartamento = 0 OR @IDDepartamento Is null)
	BEGIN

	IF EXISTS(Select Top 1 1 from RH.[tblCatDepartamentos] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatDepartamentos]
				   (
					 [Codigo]
					,[Descripcion]
					,[CuentaContable]
					,[IDEmpleado]
					,[JefeDepartamento]
                    ,[Traduccion]
				   )
			 VALUES
				   (
				     @Codigo
					,@Descripcion
					,@CuentaContable
					,case when @IDEmpleado = 0 then null else @IDEmpleado end
					,@JefeDepartamento
                    ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
				   )

		Set @IDDepartamento = @@IDENTITY
		

		SELECT 
			IDDepartamento
			,Codigo
			,Descripcion
			,CuentaContable
			,isnull(IDEmpleado,0) as IDEmpleado
			,JefeDepartamento
            ,[Traduccion]
		FROM [RH].[tblCatDepartamentos]
		WHERE IDDepartamento = @IDDepartamento

		select @NewJSON = (SELECT IDDepartamento
                                ,Codigo
                                ,CuentaContable
                                ,JefeDepartamento                                                 
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDepartamentos]
                            WHERE IDDepartamento = @IDDepartamento FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDepartamentos]','[RH].[spIUCatDepartamentos]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	IF EXISTS(Select Top 1 1 from RH.[tblCatDepartamentos] where Codigo = @Codigo and IDDepartamento <> @IDDepartamento)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = (SELECT IDDepartamento
                                ,Codigo
                                ,CuentaContable
                                ,JefeDepartamento                                                 
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDepartamentos]
                            WHERE IDDepartamento = @IDDepartamento FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		UPDATE [RH].[tblCatDepartamentos]
		   SET [Codigo] = @Codigo,
				[Descripcion] = @Descripcion,
				[CuentaContable] = @CuentaContable,
				[IDEmpleado] = case when @IDEmpleado = 0 then null else @IDEmpleado end,
				[JefeDepartamento] = @JefeDepartamento,
                [Traduccion] = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		 WHERE IDDepartamento = @IDDepartamento

		 	SELECT 
			IDDepartamento
			,Codigo
			,Descripcion
			,CuentaContable
			,isnull(IDEmpleado,0) as IDEmpleado
			,JefeDepartamento
            ,Traduccion
		FROM [RH].[tblCatDepartamentos]
		WHERE IDDepartamento = @IDDepartamento

		select @NewJSON = (SELECT IDDepartamento
                                ,Codigo
                                ,CuentaContable
                                ,JefeDepartamento                                                 
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDepartamentos]
                            WHERE IDDepartamento = @IDDepartamento FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDepartamentos]','[RH].[spIUCatDepartamentos]','UPDATE',@NewJSON,@OldJSON
	END

	 EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Departamentos'  
	 ,@ID = @IDDepartamento   
	 ,@Descripcion = @Descripcion
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
	
END
GO
