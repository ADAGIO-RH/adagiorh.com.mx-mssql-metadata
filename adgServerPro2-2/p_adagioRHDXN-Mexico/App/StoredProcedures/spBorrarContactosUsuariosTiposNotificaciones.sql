USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBorrarContactosUsuariosTiposNotificaciones] 
(
    @IDContactoUsuarioTipoNotificacion	int  = null
) as

    delete from App.tblContactosUsuariosTiposNotificaciones  
    where IDContactoUsuarioTipoNotificacion=@IDContactoUsuarioTipoNotificacion;
GO
