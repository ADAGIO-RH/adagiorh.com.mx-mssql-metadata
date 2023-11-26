USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc App.spReenviarNotificacion(
	@IDEnviarNotificacionA int
) as

	update app.tblEnviarNotificacionA
		set Enviado = 0
			,FechaHoraEnvio = null
	where IDEnviarNotificacionA = @IDEnviarNotificacionA
GO
