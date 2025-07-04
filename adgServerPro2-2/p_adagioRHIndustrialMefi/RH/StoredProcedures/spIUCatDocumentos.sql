USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatDocumentos]  
(  
 @IDDocumento int = 0  
 ,@Codigo Varchar(100)
 ,@Descripcion varchar(50)  
 ,@Template Nvarchar(MAX)  
 ,@Plantilla Nvarchar(MAX)  
 ,@EsContrato bit = 0
 ,@EsResponsiva bit = 0
 ,@IDUsuario int
)  
AS  
BEGIN  

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


 IF(@IDDocumento = 0 OR @IDDocumento Is null)  
 BEGIN  
   
  INSERT INTO [RH].[tblCatDocumentos]  
       (  
	   [Codigo]
      ,[Descripcion]  
      ,[Template]  
      ,Plantilla  
	  ,EsContrato
	  ,EsResponsiva
       )  
    VALUES  
       (  
      upper(@Codigo)  
     ,upper(@Descripcion)  
     ,@Template  
     ,@Plantilla  
     ,@EsContrato
	 ,@EsResponsiva
       )  
  set @IDDocumento = @@IDENTITY

  		select @NewJSON = a.JSON from [RH].[tblCatDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumento = @IDDocumento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDocumentos]','[RH].[spIUCatDocumentos]','INSERT',@NewJSON,''

 END  
 ELSE  
 BEGIN  
  
  	select @OldJSON = a.JSON from [RH].[tblCatDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumento = @IDDocumento


  UPDATE [RH].[tblCatDocumentos]  
     SET [Codigo] = upper(@Codigo), 
	 [Descripcion] = upper(@Descripcion),  
    [Template]= case when @Template = '' or @Template is null then [Template] else @Template end,  
    [plantilla]= @Plantilla,
	[EsContrato] = @EsContrato,
	[EsResponsiva] = @EsResponsiva
   WHERE [IDDocumento] = @IDDocumento  
  
  	select @NewJSON = a.JSON from [RH].[tblCatDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumento = @IDDocumento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDocumentos]','[RH].[spIUCatDocumentos]','UPDATE',@NewJSON,@OldJSON

 END  
END
GO
