USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUCandidato](
		 @IDCandidato int =0 
		,@IDPlaza int
		,@Nombre varchar(50) 
		,@SegundoNombre varchar(50)
		,@Paterno varchar(50)
		,@Materno varchar(50)
		,@Sexo  char(1)
		,@FechaNacimiento date
		,@IDPaisNacimiento int
		,@IDMunicipioNacimiento int
		,@IDEstadoNacimiento int
		,@IDLocalidadNacimiento int
		,@RFC varchar(50)
		,@CURP varchar(50)
		,@NSS varchar(50)
		,@IDAfore int 
		,@IDEstadoCivil int
		,@Estatura decimal(10,2)
		,@Peso decimal(10,2)
		,@Extranjero bit
		,@TipoSangre varchar(10)
		,@SueldoDeseado Decimal(18,2)
		,@CorreoElectronico varchar(50)
		,@Password Varchar(50)
		,@TelefonoCelular varchar(50)
		,@TelefonoFijo varchar(50)
		,@Pasaporte varchar(50)
		,@IDPaisResidencia int
		,@IDEstadoResidencia int
		,@IDMunicipioResidencia int
		,@IDLocalidadResidencia int
		,@IDCodigoPostalResidencia int
		,@IDColoniaResidencia int
		,@CalleResidencia varchar(50)
		,@NumeroExtResidencia varchar(50)
		,@NumeroIntResidencia varchar(50)
		,@IDEmpleado int = null
		,@IDUsuario int = 0 
	)
AS  
BEGIN  

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@FechaAplicacion date = getdate(),
		@IDDocumentoTrabajoPasaporte INT,
		@IDUsuarioAdmin int,
		@IDTipoContactoEmail int,
		@IDTipoContactoTelefonoFijo int,
		@IDTipoContactoCelular int,
		@ErrorMessage varchar(max)
	;
	select @IDUsuarioAdmin=cast(Valor as int)  from App.tblConfiguracionesGenerales where IDConfiguracion='IDUsuarioAdmin'
	select 
		@IDTipoContactoEmail=3
		,@IDTipoContactoTelefonoFijo=2
		,@IDTipoContactoCelular=1

	set @IDUsuario = CASE WHEN isnull(@IDUsuario,0) = 0 THEN @IDUsuarioAdmin ELSE @IDUsuario END

	SELECT @IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM [Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE [Descripcion] = 'PASAPORTE'

	IF(@IDCandidato = 0)  
	BEGIN  

		if ((isnull(@CorreoElectronico, '') != '') and exists(select top 1 1 
															from [Reclutamiento].[tblCandidatos]
															where Email = @CorreoElectronico))
		begin
			set @ErrorMessage=FORMATMESSAGE('El email [%s] ya existe, recupera tu contraseña para poder ingresar.', @CorreoElectronico);

			THROW 50001, @ErrorMessage, 1
			return
		end

		/*Datos De Candidato*/
		INSERT INTO [Reclutamiento].[tblCandidatos]([Nombre],[SegundoNombre],[Paterno],[Materno],[Sexo],[FechaNacimiento],[IDPaisNacimiento],[IDEstadoNacimiento],[IDMunicipioNacimiento],[IDLocalidadNacimiento],[RFC],[CURP],[NSS],[IDAFORE],[IDEstadoCivil],[Estatura],[Peso],[TipoSangre],[Extranjero],[Email],[Password],[IDEmpleado])
		VALUES ( 
			UPPER(@Nombre) 
			,UPPER(@SegundoNombre)
			,UPPER(@Paterno)
			,UPPER(@Materno)
			,@Sexo 
			,@FechaNacimiento 
			,@IDPaisNacimiento 
			,@IDEstadoNacimiento
			,@IDMunicipioNacimiento
			,@IDLocalidadNacimiento 
			,UPPER(@RFC)
			,UPPER(@CURP)
			,UPPER(@NSS)
			,@IDAfore  
			,@IDEstadoCivil 
			,UPPER(@Estatura)
			,UPPER(@Peso)
			,UPPER(@TipoSangre)
			,@Extranjero 
			,@CorreoElectronico
			,@Password
			,CASE WHEN ISNULL(@IDEmpleado,0) = 0 THEN NULL ELSE @IDEmpleado END
		)

		SET @IDCandidato = @@IDENTITY  

		/*Datos De Vacante Deseada*/
		IF(ISNULL(@IDPlaza,0) > 0)
		BEGIN
			EXEC [Reclutamiento].[spUICandidatoPlaza]
				@IDCandidatoPlaza = 0,
				@IDCandidato = @IDCandidato,
				@IDPlaza = @IDPlaza,
				@IDProceso= null,
				@SueldoDeseado= @SueldoDeseado,
				@IDUsuario = @IDUsuario
		END

		/*Correo Electronico*/
        
		if(@CorreoElectronico is not null)
		BEGIN
			INSERT INTO [Reclutamiento].[tblContactoCandidato]([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
			VALUES(@IDCandidato,@IDTipoContactoEmail,@CorreoElectronico,0)
		END

		/*Telefono Fijo*/
		if(@TelefonoFijo is not null)
		BEGIN
			INSERT INTO [Reclutamiento].[tblContactoCandidato]([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
			VALUES(@IDCandidato,@IDTipoContactoTelefonoFijo,UPPER(@TelefonoFijo),0)
		END

		/*Telefono Celular*/
		if(@TelefonoCelular is not null)
		BEGIN
			INSERT INTO [Reclutamiento].[tblContactoCandidato]([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
			VALUES(@IDCandidato,@IDTipoContactoCelular,UPPER(@TelefonoCelular),0)
		END

		/*Pasaporte*/
		if(@Pasaporte is not null)
		BEGIN
			INSERT INTO [Reclutamiento].[tblDocumentosTrabajoCandidato]([IDDocumentoTrabajo],[IDCandidato],[Validacion])
			VALUES(@IDDocumentoTrabajoPasaporte,@IDCandidato,UPPER(@Pasaporte))
		END
 
		/*Direccion del candidato*/
		INSERT INTO [Reclutamiento].[tblDireccionResidenciaCandidato]([IDCandidato],[IDPais],[IDEstado],[IDMunicipio],[IDLocalidad],[IDCodigoPostal],[IDColonia],[Calle],[NumExt],[NumInt])
		VALUES (
			@IDCandidato
			,@IDPaisResidencia 
			,@IDEstadoResidencia 
			,@IDMunicipioResidencia 
			,@IDLocalidadResidencia 
			,@IDCodigoPostalResidencia 
			,@IDColoniaResidencia 
			,UPPER(@CalleResidencia)
			,UPPER(@NumeroExtResidencia)
			,UPPER(@NumeroIntResidencia)
		)

	  	/*select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','INSERT',@NewJSON,''*/
	END  
	ELSE  
	BEGIN  
		if ((isnull(@CorreoElectronico, '') != '') and exists(select top 1 1 
															from [Reclutamiento].[tblCandidatos]
															where Email = @CorreoElectronico and IDCandidato != @IDCandidato))
		begin
			set @ErrorMessage=FORMATMESSAGE('El email [%s] ya existe, recupera tu contraseña para poder ingresar.', @CorreoElectronico);

			THROW 50001, @ErrorMessage, 1
			return
		end

		/*Datos De Candidato*/
		UPDATE [Reclutamiento].[tblCandidatos]
		   SET [Nombre] = UPPER(@Nombre) 
			  ,[SegundoNombre] = UPPER(@SegundoNombre)
			  ,[Paterno] = UPPER(@Paterno)
			  ,[Materno] = UPPER(@Materno)
			  ,[Sexo] = @Sexo
			  ,[FechaNacimiento] = @FechaNacimiento 
			  ,[IDPaisNacimiento] = @IDPaisNacimiento 
			  ,[IDEstadoNacimiento] = @IDEstadoNacimiento
			  ,[IDMunicipioNacimiento] = @IDMunicipioNacimiento
			  ,[IDLocalidadNacimiento] = @IDLocalidadNacimiento 
			  ,[RFC] = UPPER(@RFC)
			  ,[CURP] = UPPER(@CURP)
			  ,[NSS] = UPPER(@NSS)
			  ,[IDAFORE] = @IDAfore  
			  ,[IDEstadoCivil] = @IDEstadoCivil 
			  ,[Estatura] = UPPER(@Estatura)
			  ,[Peso] = UPPER(@Peso)
			  ,[TipoSangre] = UPPER(@TipoSangre)
			  ,[Extranjero] = @Extranjero
			  ,[Email] = @CorreoElectronico
		 WHERE [IDCandidato] = @IDCandidato

		/*Correo Electronico*/
            MERGE INTO [Reclutamiento].[tblContactoCandidato] AS target
                USING (SELECT @IDCandidato AS IDCandidato, @IDTipoContactoEmail AS IDTipoContacto) AS source
                ON (target.[IDCandidato] = source.IDCandidato AND target.[IDTipoContacto] = source.IDTipoContacto)
                WHEN MATCHED THEN
                    UPDATE SET target.[Value] = @CorreoElectronico
                WHEN NOT MATCHED THEN
                    INSERT ([IDCandidato], [IDTipoContacto], [Value],[Predeterminado])
                    VALUES (source.IDCandidato, source.IDTipoContacto, @CorreoElectronico,0);
		-- UPDATE [Reclutamiento].[tblContactoCandidato]
		-- 	SET [Value] = @CorreoElectronico
		-- WHERE [IDCandidato] = @IDCandidato AND [IDTipoContacto] = @IDTipoContactoEmail

		/*Telefono Fijo*/        
              MERGE INTO [Reclutamiento].[tblContactoCandidato] AS target
                USING (SELECT @IDCandidato AS IDCandidato, @IDTipoContactoTelefonoFijo AS IDTipoContacto) AS source
                ON (target.[IDCandidato] = source.IDCandidato AND target.[IDTipoContacto] = source.IDTipoContacto)
                WHEN MATCHED THEN
                    UPDATE SET target.[Value] = UPPER(@TelefonoFijo)
                WHEN NOT MATCHED THEN
                    INSERT ([IDCandidato], [IDTipoContacto], [Value],[Predeterminado])
                    VALUES (source.IDCandidato, source.IDTipoContacto, UPPER(@TelefonoFijo),0);
		-- UPDATE [Reclutamiento].[tblContactoCandidato]
		-- 	SET [Value] = UPPER(@TelefonoFijo)
		-- WHERE [IDCandidato] = @IDCandidato AND [IDTipoContacto] = @IDTipoContactoTelefonoFijo

		/*Telefono Celular*/
              MERGE INTO [Reclutamiento].[tblContactoCandidato] AS target
                USING (SELECT @IDCandidato AS IDCandidato, @IDTipoContactoCelular AS IDTipoContacto) AS source
                ON (target.[IDCandidato] = source.IDCandidato AND target.[IDTipoContacto] = source.IDTipoContacto)
                WHEN MATCHED THEN
                    UPDATE SET target.[Value] = UPPER(@TelefonoCelular)
                WHEN NOT MATCHED THEN
                    INSERT ([IDCandidato], [IDTipoContacto], [Value],[Predeterminado])
                    VALUES (source.IDCandidato, source.IDTipoContacto, UPPER(@TelefonoCelular),0);

		-- UPDATE [Reclutamiento].[tblContactoCandidato]
		-- 	SET [Value] = UPPER(@TelefonoCelular)
		-- WHERE [IDCandidato] = @IDCandidato AND [IDTipoContacto] = @IDTipoContactoCelular

		/*Pasaporte*/
		UPDATE [Reclutamiento].[tblDocumentosTrabajoCandidato]
			SET [IDDocumentoTrabajo] = @IDDocumentoTrabajoPasaporte
				,[Validacion] = UPPER(@Pasaporte)
		WHERE [IDCandidato] = @IDCandidato

		/*Direccion del candidato*/

         MERGE INTO [Reclutamiento].[tblDireccionResidenciaCandidato] AS target
                USING (SELECT @IDCandidato AS IDCandidato) AS source
                ON (target.[IDCandidato] = source.IDCandidato )
                WHEN MATCHED THEN
                    UPDATE SET 
                    target.[IDPais] = @IDPaisResidencia
                    ,target.[IDEstado] = @IDEstadoResidencia
                    ,target.[IDMunicipio] = @IDMunicipioResidencia
                    ,target.[IDLocalidad] = @IDLocalidadResidencia
                    ,target.[IDCodigoPostal] = @IDCodigoPostalResidencia
                    ,target.[IDColonia] = @IDColoniaResidencia
                    ,target.[Calle] = UPPER(@CalleResidencia)
                    ,target.[NumExt] = UPPER(@NumeroExtResidencia)
                    ,target.[NumInt] = UPPER(@NumeroIntResidencia)
                WHEN NOT MATCHED THEN
                	INSERT  ([IDCandidato],[IDPais],[IDEstado],[IDMunicipio],[IDLocalidad],[IDCodigoPostal],[IDColonia],[Calle],[NumExt],[NumInt])
                    VALUES (
                        @IDCandidato
                        ,@IDPaisResidencia 
                        ,@IDEstadoResidencia 
                        ,@IDMunicipioResidencia 
                        ,@IDLocalidadResidencia 
                        ,@IDCodigoPostalResidencia 
                        ,@IDColoniaResidencia 
                        ,UPPER(@CalleResidencia)
                        ,UPPER(@NumeroExtResidencia)
                        ,UPPER(@NumeroIntResidencia)
                    );       

		-- UPDATE [Reclutamiento].[tblDireccionResidenciaCandidato]
		-- 	SET [IDPais] = @IDPaisResidencia
		-- 		,[IDEstado] = @IDEstadoResidencia
		-- 		,[IDMunicipio] = @IDMunicipioResidencia
		-- 		,[IDLocalidad] = @IDLocalidadResidencia
		-- 		,[IDCodigoPostal] = @IDCodigoPostalResidencia
		-- 		,[IDColonia] = @IDColoniaResidencia
		-- 		,[Calle] = UPPER(@CalleResidencia)
		-- 		,[NumExt] = UPPER(@NumeroExtResidencia)
		-- 		,[NumInt] = UPPER(@NumeroIntResidencia)
		-- WHERE [IDCandidato] = @IDCandidato

		select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato

		--EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','UPDATE',@NewJSON,''
	END  

	exec [Reclutamiento].[spBuscarCandidatos] @IDCandidato = @IDCandidato,@IDUsuario = @IDUsuario
END
GO
