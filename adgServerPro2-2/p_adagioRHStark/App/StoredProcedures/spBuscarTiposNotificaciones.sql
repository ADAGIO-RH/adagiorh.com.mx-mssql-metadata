USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarTiposNotificaciones] 
(
    @IDTipoNotificacion	varchar(50) = null
) as

    select *
    from [App].[tblTiposNotificaciones]
    where (IDTipoNotificacion=@IDTipoNotificacion or @IDTipoNotificacion is null)
GO
