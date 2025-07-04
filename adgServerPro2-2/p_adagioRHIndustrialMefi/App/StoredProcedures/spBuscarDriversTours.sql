USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc App.spBuscarDriversTours(
	@IDDriverTour varchar(255) = '',
	@IDUsuario int
) as

	select
		IDDriverTour
		,[Type]
		,IDAplicacion
		,[Url]
		,JSONConfiguration
		,Active
	from App.tblDriversTours
	where IDDriverTour = @IDDriverTour or isnull(@IDDriverTour, '') = ''
GO
