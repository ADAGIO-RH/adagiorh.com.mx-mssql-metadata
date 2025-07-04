USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatRegPatronal]
(
	@IDRegPatronal	int = 0	 	
	,@RegistroPatronal varchar(20)				 
	,@RazonSocial varchar(max)		 
	,@ActividadEconomica varchar(max)
	,@IDClaseRiesgo int = null
	,@IDCodigoPostal int = null	 
	,@IDEstado	int	= null	  
	,@IDMunicipio	int	  = null
	,@IDColonia	int	= null	  
	,@IDPais	int	= null	 
	,@Calle		varchar(max) = null		 
	,@Exterior	varchar(20)	= null 	 
	,@Interior	varchar(20)	= null	 
	,@Telefono	varchar(20)	= null	 
	,@ConvenioSubsidios	 bit = null
	,@DelegacionIMSS	varchar(100)  = null
	,@SubDelegacionIMSS	 varchar(100) = null
	,@FechaAfiliacion	Varchar(50)	 = null
	,@RepresentanteLegal varchar(50) = null
	,@OcupacionRepLegal varchar(50) = null
	,@IDUsuario int
)
AS
BEGIN

	SET @RegistroPatronal	 = UPPER(@RegistroPatronal	)	 
	SET @RazonSocial		 = UPPER(@RazonSocial		)
	SET @ActividadEconomica  = UPPER(@ActividadEconomica)
	SET @Calle				 = UPPER(@Calle				)	 
	SET @Exterior			 = UPPER(@Exterior			)	 
	SET @Interior			 = UPPER(@Interior			) 
	SET @Telefono			 = UPPER(@Telefono			) 
	SET @DelegacionIMSS		 = UPPER(@DelegacionIMSS		)
	SET @SubDelegacionIMSS	 = UPPER(@SubDelegacionIMSS	)
	SET @FechaAfiliacion	 = UPPER(@FechaAfiliacion	)
	SET @RepresentanteLegal  = UPPER(@RepresentanteLegal)
	SET @OcupacionRepLegal   = UPPER(@OcupacionRepLegal )

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)



	IF (@IDRegPatronal = 0 or @IDRegPatronal is null)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.tblCatRegPatronal where RegistroPatronal = @RegistroPatronal)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
	
		INSERT INTO [RH].[tblCatRegPatronal]
				   (
					 [RegistroPatronal]
					,[RazonSocial]
					,[ActividadEconomica]
					,[IDCodigoPostal]
					,[IDEstado]
					,[IDMunicipio]
					,[IDColonia]
					,[IDPais]
					,[Calle]
					,[Exterior]
					,[Interior]
					,[Telefono]
					,[ConvenioSubsidios]
					,[DelegacionIMSS]
					,[SubDelegacionIMSS]
					,[FechaAfiliacion]
					,[IDClaseRiesgo]
					,[RepresentanteLegal]
					,[OcupacionRepLegal]
				   )
			 VALUES
				   (
				    @RegistroPatronal
					,@RazonSocial
					,@ActividadEconomica
					,CASE WHEN @IDCodigoPostal	= 0 THEN NULL ELSE @IDCodigoPostal	 END
					,CASE WHEN @IDEstado		= 0	THEN NULL ELSE @IDEstado		 END
					,CASE WHEN @IDMunicipio		= 0 THEN NULL ELSE @IDMunicipio		 END
					,CASE WHEN @IDColonia		= 0	THEN NULL ELSE @IDColonia		 END
					,CASE WHEN @IDPais			= 0	THEN NULL ELSE @IDPais			 END
					,@Calle
					,@Exterior
					,@Interior
					,@Telefono
					,@ConvenioSubsidios
					,@DelegacionIMSS
					,@SubDelegacionIMSS
					,@FechaAfiliacion
					,CASE WHEN @IDClaseRiesgo			= 0	THEN NULL ELSE @IDClaseRiesgo			 END
					,@RepresentanteLegal
					,@OcupacionRepLegal
				   )

			set @IDRegPatronal = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegPatronal = @IDRegPatronal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRegPatronal]','[RH].[spIUCatRegPatronal]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.tblCatRegPatronal where RegistroPatronal = @RegistroPatronal and IDRegPatronal <> @IDRegPatronal)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		select @OldJSON = a.JSON from [RH].[tblCatRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegPatronal = @IDRegPatronal

		UPDATE [RH].[tblCatRegPatronal]
		   SET  [RegistroPatronal] = @RegistroPatronal
				,[RazonSocial] = @RazonSocial
				,[ActividadEconomica] = @ActividadEconomica
				,[IDCodigoPostal]	= CASE WHEN @IDCodigoPostal	= 0 THEN NULL ELSE @IDCodigoPostal	 END
				,[IDEstado]			= CASE WHEN @IDEstado		= 0	THEN NULL ELSE @IDEstado		 END
				,[IDMunicipio]		= CASE WHEN @IDMunicipio		= 0 THEN NULL ELSE @IDMunicipio		 END
				,[IDColonia]		= CASE WHEN @IDColonia		= 0	THEN NULL ELSE @IDColonia		 END
				,[IDPais]			= CASE WHEN @IDPais			= 0	THEN NULL ELSE @IDPais			 END
				,[Calle] = @Calle
				,[Exterior] = @Exterior
				,[Interior] = @Interior
				,[Telefono] = @Telefono
				,[ConvenioSubsidios] = @ConvenioSubsidios
				,[DelegacionIMSS] = @DelegacionIMSS
				,[SubDelegacionIMSS] = @SubDelegacionIMSS
				,[FechaAfiliacion] = @FechaAfiliacion
				,[IDClaseRiesgo] = CASE WHEN @IDClaseRiesgo			= 0	THEN NULL ELSE @IDClaseRiesgo			 END
				,[RepresentanteLegal] = @RepresentanteLegal
				,[OcupacionRepLegal] = @OcupacionRepLegal
		 WHERE [IDRegPatronal] = @IDRegPatronal

		 select @NewJSON = a.JSON from [RH].[tblCatRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegPatronal = @IDRegPatronal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRegPatronal]','[RH].[spIUCatRegPatronal]','UPDATE',@NewJSON,@OldJSON


	END

	  EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'RegPatronales'  
	 ,@ID = @IDRegPatronal   
	 ,@Descripcion = @RazonSocial
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
