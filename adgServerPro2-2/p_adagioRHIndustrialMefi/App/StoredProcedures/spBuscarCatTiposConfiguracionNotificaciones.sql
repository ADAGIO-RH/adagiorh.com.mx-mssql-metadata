USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarCatTiposConfiguracionNotificaciones] 
(
    @IDTipoConfiguracionNotificacion int=null,
    @IDUsuario int 
) as

    select *
    from [App].[tblCatTiposConfiguracionesNotificaciones]
    -- where (IDTipoNotificacion=@IDTipoNotificacion or @IDTipoNotificacion is null or @IDTipoNotificacion ='' )  and   (IsSpecial=@IsSpecial or @IsSpecial is null)
GO
