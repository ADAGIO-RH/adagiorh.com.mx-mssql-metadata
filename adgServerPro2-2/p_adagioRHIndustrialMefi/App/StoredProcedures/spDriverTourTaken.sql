USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spDriverTourTaken(
	@IDDriverTour varchar(255),
	@IDUsuario int
) as

	insert App.tblDriversToursTaken(IDDriverTour, IDUsuario)
	values(@IDDriverTour, @IDUsuario)
GO
