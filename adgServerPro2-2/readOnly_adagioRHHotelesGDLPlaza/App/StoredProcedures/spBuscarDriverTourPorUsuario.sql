USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spBuscarDriverTourPorUsuario(
	@IDAplicacion nvarchar(100),
	@Url varchar(500),
	@IDUsuario int
 ) as

	select
		dt.IDDriverTour
		,dt.[Type]
		,dt.IDAplicacion
		,dt.[Url]
		,dt.JSONConfiguration
		,dt.Active
	from App.tblDriversTours dt with (nolock)
		left join App.tblDriversToursTaken dtt with (nolock) on dtt.IDDriverTour = dt.IDDriverTour and dtt.IDUsuario = @IDUsuario
	where dtt.IDUsuario is null 
		and (dt.[Url] = @Url or dt.[Url] is null)
		and dt.Active = 1
GO
