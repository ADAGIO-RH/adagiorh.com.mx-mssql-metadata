USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarTiposNotificaciones] 
(
    @IDTipoNotificacion	varchar(50) = null,
    @IsSpecial int =null
) as

    select IDTipoNotificacion,Descripcion,Asunto,Nombre,coalesce(IsSpecial,0) [IsSpecial]
    from [App].[tblTiposNotificaciones]
    where (IDTipoNotificacion=@IDTipoNotificacion or @IDTipoNotificacion is null or @IDTipoNotificacion ='' )  and   (IsSpecial=@IsSpecial or @IsSpecial is null)
GO
