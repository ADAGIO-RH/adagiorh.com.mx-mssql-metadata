USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIRazonesSociales]  
(  
@IDRazonSocial int = 0  
,@RazonSocial Varchar(MAX)  
,@RFC Varchar(MAX)  
,@IDCodigoPostal int =null  
,@IDEstado int =null  
,@IDMunicipio int =null  
,@IDColonia int =null  
,@IDPais int =null  
,@Calle  Varchar(MAX)=  null  
,@Exterior Varchar(20)= null  
,@Interior Varchar(20) =null  
,@IDRegimenFiscal int =null  
,@IDOrigenRecurso int =null  
,@IDCliente int =null  
,@Comision decimal(18,4) =null  
,@IDUsuario int  
)  
AS  
BEGIN  
  
set @RazonSocial = UPPER(@RazonSocial)  
set @RFC = UPPER(@RFC)  
set @Calle = UPPER(@Calle)  
set @Exterior = UPPER(@Exterior)  
set @Interior = UPPER(@Interior)  

 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
  
 IF(@IDRazonSocial = 0 or @IDRazonSocial is null)  
 BEGIN  
  
	  IF EXISTS(Select Top 1 1 from RH.[tblCatRazonesSociales] where RFC = @RFC)  
	  BEGIN  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
	   RETURN 0;  
	  END  
  
	  INSERT INTO [RH].[tblCatRazonesSociales](  
	  RazonSocial  
	  ,RFC  
	  ,IDCodigoPostal  
	  ,IDEstado  
	  ,IDMunicipio  
	  ,IDColonia  
	  ,IDPais  
	  ,Calle  
	  ,Exterior  
	  ,Interior  
	  ,IDRegimenFiscal  
	  ,IDOrigenRecurso  
	  ,IDCliente  
	  ,Comision)  
	  VALUES(  
	  @RazonSocial  
	  ,@RFC  
	  ,@IDCodigoPostal  
	  ,@IDEstado  
	  ,@IDMunicipio  
	  ,@IDColonia  
	  ,@IDPais  
	  ,@Calle  
	  ,@Exterior  
	  ,@Interior  
	  ,@IDRegimenFiscal  
	  ,@IDOrigenRecurso  
	  ,@IDCliente  
	  ,@Comision)  

	  set @IDRazonSocial = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblCatRazonesSociales] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDRazonSocial = @IDRazonSocial

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRazonesSociales]','[RH].[spUIRazonesSociales]','INSERT',@NewJSON,''
		   


 END  
 ELSE  
 BEGIN  
  
    
	  IF EXISTS(Select Top 1 1 from RH.[tblCatRazonesSociales] where RFC = @RFC and IDRazonSocial <> @IDRazonSocial)  
	  BEGIN  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
	   RETURN 0;  
	  END  
		
		select @OldJSON = a.JSON from [RH].[tblCatRazonesSociales] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDRazonSocial = @IDRazonSocial

	  UPDATE [RH].[tblCatRazonesSociales]  
	   SET RazonSocial = @RazonSocial  
		,RFC = @RFC  
		,IDCodigoPostal = @IDCodigoPostal  
		,IDEstado = @IDEstado  
		,IDMunicipio = @IDMunicipio  
		,IDColonia = @IDColonia  
		,IDPais = @IDPais  
		,Calle = @Calle  
		,Exterior = @Exterior  
		,Interior = @Interior  
		,IDRegimenFiscal = @IDRegimenFiscal  
		,IDOrigenRecurso = @IDOrigenRecurso  
		,IDCliente = @IDCliente  
		,Comision = @Comision  
	  WHERE IDRazonSocial = @IDRazonSocial  

	  	select @NewJSON = a.JSON from [RH].[tblCatRazonesSociales] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDRazonSocial = @IDRazonSocial

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRazonesSociales]','[RH].[spUIRazonesSociales]','UPDATE',@NewJSON,@OldJSON
		   

 END  
END
GO
