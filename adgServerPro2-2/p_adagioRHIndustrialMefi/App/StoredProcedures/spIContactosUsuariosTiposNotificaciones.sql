USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spIContactosUsuariosTiposNotificaciones] 
(
    @IDTipoNotificacion	varchar(50)  = null,
    @IDUsuario int =null,
    @IDCliente int =null 
) as

    DECLARE @IDTemplate int;
    declare @Email varchar(100);

    select @Email=Email FROM Seguridad.tblUsuarios where IDUsuario=@IDUsuario;
    if @Email = '' or @Email is null
	begin
		raiserror('El usuario no tiene un correo configurado.',16,1);
		return;
	end;

    select top 1 @IDTemplate=s.IDTemplateNotificacion from tblTemplateNotificaciones s where s.IDTipoNotificacion=@IDTipoNotificacion and s.IDMedioNotificacion='Email';    
    
    select * from  App.tblContactosUsuariosTiposNotificaciones  n where n.IDUsuario=@IDUsuario and n.IDCliente=@IDCliente and IDTemplateNotificacion= @IDTemplate

    if exists (select top 1 1 from  App.tblContactosUsuariosTiposNotificaciones  n where n.IDUsuario=@IDUsuario and n.IDCliente=@IDCliente and IDTemplateNotificacion= @IDTemplate )
	begin
		raiserror('Este usuario ya se encuentra en las configuracion de las notificaciones.',16,1);
		return;
	end;

    insert into App.tblContactosUsuariosTiposNotificaciones  (IDUsuario,IDTipoNotificacion,IDTemplateNotificacion,IDCliente)
    values (@IDUsuario,@IDTipoNotificacion,@IDTemplate,@IDCliente);
GO
