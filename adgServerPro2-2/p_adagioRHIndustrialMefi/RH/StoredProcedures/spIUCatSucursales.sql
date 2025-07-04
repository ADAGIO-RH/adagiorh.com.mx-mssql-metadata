USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatSucursales](  
	@IDSucursal int = 0  
	,@Codigo varchar(20)  
	,@Descripcion varchar(50)  
	,@CuentaContable Varchar(20) = null  
	,@IDCodigoPostal int = null  
	,@IDEstado int = null  
	,@IDMunicipio int = null  
	,@IDColonia int = null  
	,@IDPais int = null  
	,@Calle varchar(100) = null  
	,@Exterior varchar(50) = null  
	,@Interior varchar(50) = null  
	,@Telefono varchar(20) = null  
	,@Responsable varchar(100) = null  
	,@Email varchar(100) = null  
	,@ClaveEstablecimiento Varchar(50) = null  
	,@IDEstadoSTPS int = null  
	,@IDMunicipioSTPS int = null  
	,@Latitud float	 null
	,@Longitud float null
	,@Fronterizo bit = 0
	,@IDUsuario int  
)  
AS  
BEGIN  
  	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select 
		@Codigo = UPPER(@Codigo)  
		,@Descripcion = UPPER(@Descripcion )  
		,@Calle = UPPER(@Calle)  
		,@Exterior  = UPPER(@Exterior)  
		,@Interior  = UPPER(@Interior)  
		,@Responsable  = UPPER(@Responsable)  
		,@Email  = lower(@Email)  
		,@ClaveEstablecimiento = UPPER(@ClaveEstablecimiento)  
	;
  
	if (@Codigo is null)   
	begin  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302004'  
		RETURN 0;  
	end;  
  
	if (@Descripcion is null)   
	begin  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302005'  
		RETURN 0;  
	end;  
  
	IF (@IDSucursal = 0 or @IDSucursal is null)  
	BEGIN  
		IF EXISTS(Select Top 1 1 from RH.[tblCatSucursales] where Codigo = @Codigo)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  
  
		INSERT INTO [RH].[tblCatSucursales](  
			[Codigo]  
			,[Descripcion]  
			,[CuentaContable]  
			,[Calle]  
			,[Exterior]  
			,[Interior]  
			,[IDColonia]  
			,[IDMunicipio]  
			,[IDEstado]  
			,[IDPais]  
			,[Telefono]  
			,[Responsable]  
			,[Email]  
			,[IDCodigoPostal]  
			,[ClaveEstablecimiento]  
			,[IDEstadoSTPS]  
			,[IDMunicipioSTPS]  
			,[Latitud]
			,[Longitud]
			,[Fronterizo]
       )  
		VALUES (  
			@Codigo  
			,@Descripcion  
			,@CuentaContable  
			,@Calle  
			,@Exterior  
			,@Interior  
			,CASE WHEN @IDColonia = 0 THEN NULL ELSE @IDColonia END  
			,CASE WHEN @IDMunicipio = 0 THEN NULL ELSE @IDMunicipio END  
			,CASE WHEN @IDEstado = 0 THEN NULL ELSE @IDEstado END  
			,CASE WHEN @IDPais = 0 THEN NULL ELSE @IDPais END  
			,@Telefono 
			,@Responsable  
			,@Email  
			,CASE WHEN @IDCodigoPostal = 0 THEN NULL ELSE @IDCodigoPostal END  
			,@ClaveEstablecimiento   
			,CASE WHEN @IDEstadoSTPS = 0 THEN NULL ELSE @IDEstadoSTPS END  
			,CASE WHEN @IDMunicipioSTPS = 0 THEN NULL ELSE @IDMunicipioSTPS END 
			,@Latitud
			,@Longitud
			,ISNULL(@Fronterizo,0)
       )  
    
		set @IDSucursal = @@identity  

		select @NewJSON = a.JSON from [RH].[tblCatSucursales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSucursal = @IDSucursal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatSucursales]','[RH].[spIUCatSucursales]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  
		IF EXISTS(Select Top 1 1 from RH.[tblCatSucursales] where Codigo = @Codigo and IDSucursal <> @IDSucursal)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  

		select @OldJSON = a.JSON 
		from [RH].[tblCatSucursales] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSucursal = @IDSucursal

		UPDATE [RH].[tblCatSucursales]  
		SET  
			[Codigo] = @Codigo  
			,[Descripcion] = @Descripcion     
			,[CuentaContable] = @CuentaContable  
			,[Calle] = @Calle  
			,[Exterior]		= @Exterior  
			,[Interior]		= @Interior  
			,[IDColonia]	= CASE WHEN @IDColonia = 0 THEN NULL ELSE @IDColonia END  
			,[IDMunicipio]	= CASE WHEN @IDMunicipio = 0 THEN NULL ELSE @IDMunicipio END  
			,[IDEstado]		= CASE WHEN @IDEstado = 0 THEN NULL ELSE @IDEstado END  
			,[IDPais]		= CASE WHEN @IDPais = 0 THEN NULL ELSE @IDPais END  
			,[Telefono] = @Telefono  
			,[Responsable]  = @Responsable
			,[Email] = @Email  
			,[IDCodigoPostal]	= CASE WHEN @IDCodigoPostal = 0 THEN NULL ELSE @IDCodigoPostal END  
			,[ClaveEstablecimiento] = @ClaveEstablecimiento  
			,[IDEstadoSTPS]		= CASE WHEN @IDEstadoSTPS = 0 THEN NULL ELSE @IDEstadoSTPS END  
			,[IDMunicipioSTPS]	= CASE WHEN @IDMunicipioSTPS = 0 THEN NULL ELSE @IDMunicipioSTPS END
			,[Latitud]	= @Latitud
			,[Longitud] = @Longitud
			,[Fronterizo] = ISNULL(@Fronterizo,0)
		WHERE [IDSucursal] = @IDSucursal  
  	
		select @NewJSON = a.JSON from [RH].[tblCatSucursales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSucursal = @IDSucursal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatSucursales]','[RH].[spIUCatSucursales]','UPDATE',@NewJSON,@OldJSON
	END  
  
	exec [RH].[spBuscarCatSucursales] @IDSucursal=@IDSucursal, @IDUsuario=@IDUsuario

	EXEC [Seguridad].[spIUFiltrosUsuarios] 
		 @IDFiltrosUsuarios = 0  
		 ,@IDUsuario = @IDUsuario   
		 ,@Filtro = 'Sucursales'  
		 ,@ID = @IDSucursal   
		 ,@Descripcion = @Descripcion
		 ,@IDUsuarioLogin = @IDUsuario 

	exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
  
END
GO
