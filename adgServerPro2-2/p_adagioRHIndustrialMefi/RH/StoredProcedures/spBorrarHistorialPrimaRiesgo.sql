USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarHistorialPrimaRiesgo]  
(  
 @IDHistorialPrimaRiesgo int  ,
 @IDUsuario int
)  
AS  
BEGIN  
   
 SELECT   
  IDHistorialPrimaRiesgo  
  ,IDRegPatronal  
  ,Anio  
  ,Mes  
  ,case when Prima <> 0 THEN Prima * 100 else 0 END  as Prima
 FROM RH.tblHistorialPrimaRiesgo  
 WHERE IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo  
  

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblHistorialPrimaRiesgo] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo  
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialPrimaRiesgo]','[RH].[spBorrarHistorialPrimaRiesgo]','DELETE','',@OldJSON



  
 DELETE RH.tblHistorialPrimaRiesgo  
 WHERE IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo  
   
  
END
GO
