USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc Comunicacion.spDeleteNotificacionBirthday(
	@IDNotificacionBirthday int,
	@IDUsuario int
) as

	delete Comunicacion.tblNotificacionBirthday
	where IDNotificacionBirthday = @IDNotificacionBirthday
GO
