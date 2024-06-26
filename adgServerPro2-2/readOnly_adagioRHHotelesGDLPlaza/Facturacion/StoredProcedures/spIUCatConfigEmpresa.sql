USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE Facturacion.spIUCatConfigEmpresa  
(  
 @IDConfigEmpresa int = null,  
 @IDEmpresa int,  
 @Usuario Varchar(50),  
 @Password Varchar(50),  
 @PasswordKey Varchar(50),  
 @Token Nvarchar(max)
 --@IDPack int  
)  
AS  
BEGIN  
  
 IF(@IDConfigEmpresa is null or @IDConfigEmpresa = 0)  
 BEGIN  
  insert into Facturacion.tblCatConfigEmpresa(IDEmpresa,Usuario,[Password],PasswordKey,Token)  
  values(@IDEmpresa,@Usuario,@Password,@PasswordKey,@Token)  
  set @IDConfigEmpresa = @@IDENTITY  
 END  
 ELSE  
 BEGIN  
  UPDATE Facturacion.tblCatConfigEmpresa  
   set Usuario = @Usuario,  
    [Password] = @Password,  
    [PasswordKey] = @PasswordKey,
	[Token] = @Token  
  where IDConfigEmpresa = @IDConfigEmpresa  
   and IDEmpresa = @IDEmpresa  
 END  
  
 EXEC Facturacion.spBuscarCatConfigEmpresa @IDConfigEmpresa  
END
GO
