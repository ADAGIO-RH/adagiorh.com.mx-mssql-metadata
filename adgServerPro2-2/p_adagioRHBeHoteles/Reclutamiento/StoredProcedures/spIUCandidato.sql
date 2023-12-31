USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUCandidato](
		 @IDCandidato int =0 
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
		,@VacanteDeseada varchar(50)
		,@SueldoDeseado varchar(50)
		,@CorreoElectronico varchar(50)
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
		,@IDUsuario int = 0 
	)
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

		DECLARE @IDDocumentoTrabajoPasaporte INT;

		SELECT 
			@IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
		FROM 
			[Reclutamiento].[tblCatDocumentosTrabajo]
		WHERE 
			[Descripcion] = 'PASAPORTE'


 IF(@IDCandidato = 0)  
 BEGIN  
	/*Datos De Candidato*/
	INSERT INTO [Reclutamiento].[tblCandidatos]
			   ([Nombre]
			   ,[SegundoNombre]
			   ,[Paterno]
			   ,[Materno]
			   ,[Sexo]
			   ,[FechaNacimiento]
			   ,[IDPaisNacimiento]
			   ,[IDEstadoNacimiento]
			   ,[IDMunicipioNacimiento]
			   ,[IDLocalidadNacimiento]
			   ,[RFC]
			   ,[CURP]
			   ,[NSS]
			   ,[IDAFORE]
			   ,[IDEstadoCivil]
			   ,[Estatura]
			   ,[Peso]
			   ,[TipoSangre]
			   ,[Extranjero])
		 VALUES
			   ( UPPER(@Nombre) 
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
		)

			SET @IDCandidato = @@IDENTITY  

			/*Datos De Vacante Deseada*/
			INSERT INTO [Reclutamiento].[tblCandidatosProceso]
				([IDCandidato],[VacanteDeseada],[SueldoDeseado],[IDEstatusProceso])
			VALUES
				(@IDCandidato
				,UPPER(@VacanteDeseada)
				,UPPER(@SueldoDeseado)
				,1)

			/*Correo Electronico*/
			if(@CorreoElectronico is not null)
			BEGIN
				INSERT INTO [Reclutamiento].[tblContactoCandidato]
					([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
				VALUES
					(@IDCandidato
					,3
					,@CorreoElectronico
					,0)
			END

			/*Telefono Fijo*/
			if(@TelefonoFijo is not null)
			BEGIN
				INSERT INTO [Reclutamiento].[tblContactoCandidato]
					([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
				VALUES
					(@IDCandidato
					,2
					,UPPER(@TelefonoFijo)
					,0)
			END

			/*Telefono Celular*/
			if(@TelefonoCelular is not null)
			BEGIN
				INSERT INTO [Reclutamiento].[tblContactoCandidato]
					([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
				VALUES
					(@IDCandidato
					,1
					,UPPER(@TelefonoCelular),0)
			END

			/*Pasaporte*/

			if(@Pasaporte is not null)
			BEGIN

				INSERT INTO [Reclutamiento].[tblDocumentosTrabajoCandidato]
						   ([IDDocumentoTrabajo]
						   ,[IDCandidato]
						   ,[Validacion])
					 VALUES
						   (@IDDocumentoTrabajoPasaporte
						   ,@IDCandidato
						   ,UPPER(@Pasaporte))

			END
 
			/*Direccion del candidato*/
			INSERT INTO [Reclutamiento].[tblDireccionResidenciaCandidato]
					   ([IDCandidato]
					   ,[IDPais]
					   ,[IDEstado]
					   ,[IDMunicipio]
					   ,[IDLocalidad]
					   ,[IDCodigoPostal]
					   ,[IDColonia]
					   ,[Calle]
					   ,[NumExt]
					   ,[NumInt])
				 VALUES
					   (
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
	 WHERE [IDCandidato] = @IDCandidato


			/*Correo Electronico*/
			UPDATE [Reclutamiento].[tblContactoCandidato]
			   SET [Value] = @CorreoElectronico
			 WHERE [IDCandidato] = @IDCandidato
				  AND [IDTipoContacto] = 3


			/*Telefono Fijo*/
			UPDATE [Reclutamiento].[tblContactoCandidato]
			   SET [Value] = UPPER(@TelefonoFijo)
			 WHERE [IDCandidato] = @IDCandidato
				  AND [IDTipoContacto] = 2


			/*Telefono Celular*/
			UPDATE [Reclutamiento].[tblContactoCandidato]
			   SET [Value] = UPPER(@TelefonoCelular)
			 WHERE [IDCandidato] = @IDCandidato
				  AND [IDTipoContacto] = 1


			/*Pasaporte*/
			UPDATE [Reclutamiento].[tblDocumentosTrabajoCandidato]
			   SET [IDDocumentoTrabajo] = @IDDocumentoTrabajoPasaporte
				  ,[Validacion] = UPPER(@Pasaporte)
			 WHERE [IDCandidato] = @IDCandidato


			/*Direccion del candidato*/

			UPDATE [Reclutamiento].[tblDireccionResidenciaCandidato]
			   SET [IDPais] = @IDPaisResidencia
				  ,[IDEstado] = @IDEstadoResidencia
				  ,[IDMunicipio] = @IDMunicipioResidencia
				  ,[IDLocalidad] = @IDLocalidadResidencia
				  ,[IDCodigoPostal] = @IDCodigoPostalResidencia
				  ,[IDColonia] = @IDColoniaResidencia
				  ,[Calle] = UPPER(@CalleResidencia)
				  ,[NumExt] = UPPER(@NumeroExtResidencia)
				  ,[NumInt] = UPPER(@NumeroIntResidencia)
			  WHERE [IDCandidato] = @IDCandidato


	  	select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato

		--EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','UPDATE',@NewJSON,''

 END  
 
 

	Exec [Reclutamiento].[spBuscarCandidatos] @IDCandidato = @IDCandidato
END
GO
