USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [App].[spNotificacionEnviada](
	@IDEnviarNotificacionA int
) as

	update [App].[tblEnviarNotificacionA]
	set Enviado = 1
		,FechaHoraEnvio = GETDATE()
	where IDEnviarNotificacionA = @IDEnviarNotificacionA
GO
