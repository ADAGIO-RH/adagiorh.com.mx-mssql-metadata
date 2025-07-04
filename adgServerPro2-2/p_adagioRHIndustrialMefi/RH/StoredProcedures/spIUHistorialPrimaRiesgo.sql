USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [RH].[spIUHistorialPrimaRiesgo]  
(  
 @IDHistorialPrimaRiesgo int = 0  
 ,@IDRegPatronal int  
 ,@Anio int  
 ,@Mes Varchar(20)  
 ,@Prima decimal(21, 10)
 ,@IDUsuario int
)  
AS  
BEGIN  

set @Prima = case when @Prima <> 0 THEN @Prima/100.00 else 0 END

 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
  


 IF(@IDHistorialPrimaRiesgo = 0 OR @IDHistorialPrimaRiesgo is null)  
 BEGIN  
	  INSERT INTO RH.tblHistorialPrimaRiesgo(  
		 IDRegPatronal  
		 ,Anio  
		 ,Mes  
		 ,Prima  
		 )  
	  VALUES(  
		  @IDRegPatronal  
		 ,@Anio  
		 ,@Mes  
		 ,@Prima  
	  )  
	  SET @IDHistorialPrimaRiesgo = @@IDENTITY  

  		select @NewJSON = a.JSON from [RH].[tblHistorialPrimaRiesgo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialPrimaRiesgo]','[RH].[spIUHistorialPrimaRiesgo]','INSERT',@NewJSON,''
     
	   SELECT   
		IDHistorialPrimaRiesgo  
		,IDRegPatronal  
		,Anio  
		,Mes  
		,Prima  
	   FROM RH.tblHistorialPrimaRiesgo  
	   WHERE IDRegPatronal = @IDRegPatronal  
	   ORDER BY Anio,Mes  
 END  
 ELSE  
 BEGIN 
 
 	select @OldJSON = a.JSON from [RH].[tblHistorialPrimaRiesgo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo

  
  UPDATE RH.tblHistorialPrimaRiesgo  
   set Anio = @Anio  
    ,Mes = @Mes  
    ,Prima = @Prima  
  Where IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo  
   and @IDRegPatronal = @IDRegPatronal  

   		select @NewJSON = a.JSON from [RH].[tblHistorialPrimaRiesgo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialPrimaRiesgo = @IDHistorialPrimaRiesgo

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialPrimaRiesgo]','[RH].[spIUHistorialPrimaRiesgo]','UPDATE',@NewJSON,@OldJSON
     
  
   SELECT   
    IDHistorialPrimaRiesgo  
    ,IDRegPatronal  
    ,Anio  
    ,Mes  
    ,case when Prima <> 0 THEN Prima * 100 else 0 END  as Prima  
   FROM RH.tblHistorialPrimaRiesgo  
   WHERE IDRegPatronal = @IDRegPatronal  
   ORDER BY Anio,Mes  
 END  
   
END
GO
