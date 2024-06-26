USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarMediosNotificacion](
    @IDMedioNotificacion varchar(50) = null
) as

    select IDMedioNotificacion, Descripcion
    from [App].[tblMediosNotificaciones]
    where (IDMedioNotificacion = @IDMedioNotificacion or @IDMedioNotificacion is null)
GO
