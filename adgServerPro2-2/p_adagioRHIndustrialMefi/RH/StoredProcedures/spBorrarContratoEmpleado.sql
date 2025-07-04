USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarContratoEmpleado]  
(  
 @IDContratoEmpleado int,
 @IDUsuario int   
   
)  
AS  
BEGIN  
   
 declare @IDEmpleado int = 0;  
  
 select @IDEmpleado = IDEmpleado from RH.tblContratoEmpleado   
 where IDContratoEmpleado = @IDContratoEmpleado  

 	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblContratoEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDContratoEmpleado = @IDContratoEmpleado  

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContratoEmpleado]','[RH].[spBorrarContratoEmpleado]','DELETE','',@OldJSON

  
 DELETE RH.tblContratoEmpleado   
 where IDContratoEmpleado = @IDContratoEmpleado  
    
  EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado  
END
GO
