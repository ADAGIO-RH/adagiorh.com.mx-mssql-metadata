USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [App].[spGuardarNotificacion](
    @IDTipoNotificacion	varchar(50)
    ,@Parametros nvarchar(max)
    ,@destinatarios [App].[dtDestinatarios] READONLY
) as  
    declare @IDNotifiacion int = 0

    insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)
    select @IDTipoNotificacion,@Parametros

    select @IDNotifiacion=@@IDENTITY;

    insert into App.tblEnviarNotificacionA(IDNotifiacion,IDMedioNotificacion,Destinatario)
    SELECT @IDNotifiacion as IDNotifiacion,m.IDMedioNotificacion,Valor
    FROM @destinatarios d
	   join [App].[tblMediosNotificaciones] m on d.IDMedioNotificacion=m.IDMedioNotificacion
GO
