USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUEmpresa]  
(  
 @IdEmpresa int = 0  
 ,@NombreComercial varchar(max)  
 ,@RFC varchar(20)  
 ,@IDCodigoPostal int  
 ,@IDEstado int  
 ,@IDMunicipio int  
 ,@IDColonia int  
 ,@IDPais int  
 ,@Calle varchar(max)  
 ,@Exterior varchar(20)  
 ,@Interior varchar(20)  
 ,@RegFonacot varchar(50)  
 ,@RegInfonavit varchar(50)  
 ,@RegSIEM varchar(50)  
 ,@RegEstatal varchar(50)  
 ,@IDRegimenFiscal int = null  
 ,@IDOrigenRecurso int = null  
 ,@PasswordInfonavit varchar(max) = null
 ,@CURP Varchar(18) = null
 ,@IDUsuario int  
)  
AS  
BEGIN  
 SET @NombreComercial = UPPER(@NombreComercial)  
 SET @RFC    = UPPER(@RFC   )  
 SET @Calle   = UPPER(@Calle   )  
 SET @Exterior  = UPPER(@Exterior  )  
 SET @Interior  = UPPER(@Interior  )  
 SET @RegFonacot  = UPPER(@RegFonacot  )  
 SET @RegInfonavit = UPPER(@RegInfonavit )  
 SET @RegSIEM  = UPPER(@RegSIEM  )  
 SET @RegEstatal  = UPPER(@RegEstatal  )  
  
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
  
 IF (@IdEmpresa = 0 or @IdEmpresa is null)  
 BEGIN  
    
  IF EXISTS(Select Top 1 1 from RH.tblEmpresa where RFC = @RFC)  
  BEGIN  
   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
   RETURN 0;  
  END  
  
  INSERT INTO [RH].[tblEmpresa]  
       (  
     [NombreComercial]  
     ,[RFC]  
     ,[IDCodigoPostal]  
     ,[IDEstado]  
     ,[IDMunicipio]  
     ,[IDColonia]  
     ,[IDPais]  
     ,[Calle]  
     ,[Exterior]  
     ,[Interior]  
     ,[RegFonacot]  
     ,[RegInfonavit]  
     ,[RegSIEM]  
     ,[RegEstatal]  
     ,[IDRegimenFiscal]  
     ,[IDOrigenRecurso] 
	 ,[PasswordInfonavit]
	 ,[CURP]
       )  
    VALUES  
       (  
     @NombreComercial  
     ,@RFC  
     ,CASE WHEN @IDCodigoPostal = 0 THEN NULL ELSE @IDCodigoPostal END  
     ,CASE WHEN @IDEstado = 0 THEN NULL ELSE @IDEstado END  
     ,CASE WHEN @IDMunicipio = 0 THEN NULL ELSE @IDMunicipio END  
     ,CASE WHEN @IDColonia = 0 THEN NULL ELSE @IDColonia END  
     ,CASE WHEN @IDPais = 0 THEN NULL ELSE @IDPais END  
     ,@Calle  
     ,@Exterior  
     ,@Interior  
     ,@RegFonacot  
     ,@RegInfonavit  
     ,@RegSIEM  
     ,@RegEstatal  
     ,CASE WHEN @IDRegimenFiscal = 0 THEN NULL ELSE @IDRegimenFiscal END  
     ,CASE WHEN @IDOrigenRecurso = 0 THEN NULL ELSE @IDOrigenRecurso END  
	 ,@PasswordInfonavit
	 ,@CURP
       )  

	   set @IdEmpresa = @@IDENTITY

	   	select @NewJSON = a.JSON from [RH].[tblEmpresa] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IdEmpresa] = @IdEmpresa  

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpresa]','[RH].[spIUEmpresa]','INSERT',@NewJSON,''
  
 END  
 ELSE  
 BEGIN  
  IF EXISTS(Select Top 1 1 from RH.tblEmpresa where RFC = @RFC and IdEmpresa <> @IdEmpresa)  
  BEGIN  
   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
   RETURN 0;  
  END  
  
  select @OldJSON = a.JSON from [RH].[tblEmpresa] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IdEmpresa] = @IdEmpresa  

  UPDATE [RH].[tblEmpresa]  
     SET  [NombreComercial] = @NombreComercial  
     ,[RFC] =@RFC  
     ,[IDCodigoPostal] =CASE WHEN @IDCodigoPostal = 0 THEN NULL ELSE @IDCodigoPostal END  
     ,[IDEstado] =CASE WHEN @IDEstado = 0 THEN NULL ELSE @IDEstado END  
     ,[IDMunicipio] =CASE WHEN @IDMunicipio = 0 THEN NULL ELSE @IDMunicipio END  
     ,[IDColonia] =CASE WHEN @IDColonia = 0 THEN NULL ELSE @IDColonia END  
     ,[IDPais] =CASE WHEN @IDPais = 0 THEN NULL ELSE @IDPais END  
     ,[Calle] =@Calle  
     ,[Exterior] =@Exterior  
     ,[Interior] =@Interior  
     ,[RegFonacot] =@RegFonacot  
     ,[RegInfonavit] =@RegInfonavit  
     ,[RegSIEM] =@RegSIEM  
     ,[RegEstatal] =@RegEstatal  
     ,[IDRegimenFiscal] = CASE WHEN @IDRegimenFiscal = 0 THEN NULL ELSE @IDRegimenFiscal END  
     ,[IDOrigenRecurso] = CASE WHEN @IDOrigenRecurso = 0 THEN NULL ELSE @IDOrigenRecurso END  
	 ,[PasswordInfonavit] = @PasswordInfonavit
	 ,[CURP] = @CURP
   WHERE [IdEmpresa] = @IdEmpresa  

    	select @NewJSON = a.JSON from [RH].[tblEmpresa] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IdEmpresa] = @IdEmpresa  

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpresa]','[RH].[spIUEmpresa]','UPDATE',@NewJSON,@OldJSON
  
 END  
  
 --   EXEC [Seguridad].[spIUFiltrosUsuarios]   
 -- @IDFiltrosUsuarios  = 0    
 -- ,@IDUsuario  = @IDUsuario     
 -- ,@Filtro = 'RazonesSociales'    
 -- ,@ID = @IdEmpresa     
 -- ,@Descripcion = @NombreComercial  
 -- ,@IDUsuarioLogin = @IDUsuario   
  
 --exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario   
END
GO
