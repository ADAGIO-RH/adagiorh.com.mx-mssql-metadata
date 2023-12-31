USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUCandidato](
							@IDCandidato int = 0
						   ,@Nombre varchar(50)
						   ,@SegundoNombre varchar(50)
						   ,@Paterno varchar(50)
						   ,@Materno varchar(50)
						   ,@Sexo char(1)
						   ,@FechaNacimiento date
						   ,@IDPaisNacimiento int
						   ,@IDEstadoNacimiento int
						   ,@IDMunicipioNacimiento int
						   ,@IDLocalidadNacimiento int
						   ,@RFC varchar(20)
						   ,@CURP varchar(20)
						   ,@NSS varchar(20)
						   ,@AFORE varchar(20)
						   ,@IDEstadoCivil int
						   ,@Estatura decimal(10,2)
						   ,@Peso decimal(10,2)
						   ,@TipoSangre varchar(10)	
						   ,@IDUsuario int  )
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDCandidato = 0)  
 BEGIN  

	  INSERT INTO [Reclutamiento].[tblCandidatos](
            [Nombre]
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
           ,[AFORE]
           ,[IDEstadoCivil]
           ,[Estatura]
           ,[Peso]
           ,[TipoSangre])
     VALUES(
			@Nombre 
			,@SegundoNombre
			,@Paterno 
			,@Materno 
			,@Sexo 
			,@FechaNacimiento 
			,@IDPaisNacimiento 
			,@IDEstadoNacimiento 
			,@IDMunicipioNacimiento 
			,@IDLocalidadNacimiento 
			,@RFC 
			,@CURP 
			,@NSS 
			,@AFORE 
			,@IDEstadoCivil 
			,@Estatura 
			,@Peso 
			,@TipoSangre )

		SET @IDCandidato = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','INSERT',@NewJSON,''

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato 

		UPDATE [Reclutamiento].[tblCandidatos]
		SET 
		   [Nombre] = @Nombre
		  ,[SegundoNombre] = @SegundoNombre
		  ,[Paterno] = @Paterno
		  ,[Materno] = @Materno
		  ,[Sexo] = @Sexo
		  ,[FechaNacimiento] = @FechaNacimiento
		  ,[IDPaisNacimiento] = @IDPaisNacimiento
		  ,[IDEstadoNacimiento] = @IDEstadoNacimiento
		  ,[IDMunicipioNacimiento] = @IDMunicipioNacimiento
		  ,[IDLocalidadNacimiento] = @IDLocalidadNacimiento
		  ,[RFC] = @RFC
		  ,[CURP] = @CURP
		  ,[NSS] = @NSS
		  ,[AFORE] = @AFORE
		  ,[IDEstadoCivil] = @IDEstadoCivil 
		  ,[Estatura] = @Estatura
		  ,[Peso] = @Peso
		  ,[TipoSangre] = @TipoSangre
		   WHERE [IDCandidato] = @IDCandidato

		select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDCandidato] = @IDCandidato
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','UPDATE',@NewJSON,@OldJSON

 END  
END
GO
