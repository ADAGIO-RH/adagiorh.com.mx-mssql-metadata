USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Comedor.spBuscarConfiguracionesImpresorasComandas(
	@IDConfiguracionImpresoraComanda int = 0	
) as
	select 
		IDConfiguracionImpresoraComanda
		,NombreImpresora
		,IDRestaurante
		,IDSizePapelImpresionComanda
	from Comedor.tblConfiguracionImpresoraComandas with (nolock)
	where IDConfiguracionImpresoraComanda = @IDConfiguracionImpresoraComanda 
		or isnull(@IDConfiguracionImpresoraComanda, 0) = 0
GO
