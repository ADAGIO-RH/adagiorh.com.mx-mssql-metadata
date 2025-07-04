USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIDatosExtraClientes]  
(  
 @IDCatDatoExtraCliente int,  
 @IDDatoExtraCliente int = 0,  
 @Valor varchar(255),
 @IDCliente int,  
 @IDUsuario int  
)  
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


	 IF(@IDDatoExtraCliente = 0)  
	 BEGIN  
		  INSERT INTO RH.tblDatosExtraClientes(IDCatDatoExtraCliente,Valor,IDCliente)  
		  VALUES(@IDCatDatoExtraCliente,upper(@Valor),@IDCliente)  
		  SET @IDDatoExtraCliente = @@IDENTITY  

	  		select @NewJSON = a.JSON from [RH].[tblDatosExtraClientes] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDDatoExtraCliente = @IDDatoExtraCliente

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDatosExtraClientes]','[RH].[spUIDatosExtraClientes]','INSERT',@NewJSON,''
	 END  
	 ELSE  
	 BEGIN  
	  		select @OldJSON = a.JSON from [RH].[tblDatosExtraClientes] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDDatoExtraCliente = @IDDatoExtraCliente
			   and IDCatDatoExtraCliente = @IDCatDatoExtraCliente 
			 AND IDCliente = @IDCliente 

			UPDATE RH.[tblDatosExtraClientes]  
			set Valor = upper(@Valor)  
			WHERE IDDatoExtraCliente = @IDDatoExtraCliente  
			and IDCatDatoExtraCliente = @IDCatDatoExtraCliente 
			AND IDCliente = @IDCliente 

			select @NewJSON = a.JSON from [RH].[tblDatosExtraClientes] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDDatoExtraCliente = @IDDatoExtraCliente
				   and b.IDCatDatoExtraCliente = @IDCatDatoExtraCliente 
					AND b.IDCliente = @IDCliente 

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDatosExtraClientes]','[RH].[spUIDatosExtraClientes]','UPDATE',@NewJSON,@OldJSON
	 END  
END
GO
