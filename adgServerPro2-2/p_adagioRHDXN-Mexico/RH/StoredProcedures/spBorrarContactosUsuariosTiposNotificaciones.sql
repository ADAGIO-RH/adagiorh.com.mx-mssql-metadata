USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [RH].[spBorrarContactosUsuariosTiposNotificaciones] 
(
    @IDContactoEmpleadoTipoNotificacion	int  = null
) as

    delete from RH.tblContactosEmpleadosTiposNotificaciones
    where IDContactoEmpleadoTipoNotificacion=@IDContactoEmpleadoTipoNotificacion;
GO
