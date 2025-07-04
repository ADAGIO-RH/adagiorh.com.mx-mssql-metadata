USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spBuscarConfiguracionImpresorasTicktes(
	@IDConfiguracionImpresoraTicket int
) as
	
	select 
		IDConfiguracionImpresoraTicket
		,NombreImpresora
		,TipoReferencia
		,IDReferencia
		,IDSizePapelImpresionTickets
	from [App].[tblConfiguracionImpresorasTickets]
	where [IDConfiguracionImpresoraTicket] = @IDConfiguracionImpresoraTicket
GO
