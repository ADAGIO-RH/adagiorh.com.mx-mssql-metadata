USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarMensajesHoy](
	@IDRestaurante int
)
as
	declare @tiposMensajes as table (
		[value] varchar(10),
		[text] varchar(100),
		[icon] varchar(100)
	)

	insert @tiposMensajes([value], [text], [icon])
	exec Comedor.spBuscarTiposMensajes

	--select * from @resp

	select
		 m.IDMensaje
		,m.Mensaje
		,m.FechaIni
		,m.FechaFin
		,m.IdsRestaurantes
		,m.IDUsuario
		,isnull(m.FechaHoraCreacion,getdate()) as FechaHoraCreacion
		,m.TipoMensaje
		,tm.icon
	from Comedor.tblMensajes m with (nolock)
		join @tiposMensajes tm on tm.[value] = m.TipoMensaje
	where cast(getdate() as date) between FechaIni and FechaFin
		and (@IDRestaurante in (select cast(item as int) from App.Split(m.IdsRestaurantes, ',')))
GO
