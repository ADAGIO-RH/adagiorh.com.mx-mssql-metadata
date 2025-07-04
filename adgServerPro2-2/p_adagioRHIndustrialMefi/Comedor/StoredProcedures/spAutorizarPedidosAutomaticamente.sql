USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spAutorizarPedidosAutomaticamente] as
	declare     
		@IDUsuarioAdmin int
	;    
    
	select @IDUsuarioAdmin = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'

	if object_id('tempdb..#tempPedidosAAutorizar') is not null drop table #tempPedidosAAutorizar
	
	select *
	INTO #tempPedidosAAutorizar
	from [Comedor].[tblPedidos] p with (nolock)
	where	isnull([p].[Autorizado],0)	= 0
		and isnull([p].[Cancelada],0)	= 0
		and isnull([p].[DescontadaDeNomina],0) = 0
		and isnull([p].[ComandaImpresa],0) = 1
		and datediff(day, [p].[FechaCreacion], getdate()) > 0


	update #tempPedidosAAutorizar
	 set Autorizado = 1,
		IDUsuarioAutorizo = @IDUsuarioAdmin,
		FechaHoraAutorizacion = getdate(),
		NotaAutorizacion = N'Autorización automática por sistema. El pedido fue solicitado el '
							+CONVERT(VARCHAR(20),isnull(FechaCreacion,getdate()),100)+' a las '+ Format(cast(HoraCreacion as datetime),'HH:mm:ss')+', y se autorizó ' 
							+CONVERT(VARCHAR(20),getdate(),100)
	
	insert [Comedor].[tblPedidosAutorizadosAutomaticamente]
	select *
	from #tempPedidosAAutorizar


	update [p]
		set
			[p].Autorizado				= [tp].Autorizado,			
			[p].IDUsuarioAutorizo		= [tp].IDUsuarioAutorizo,	
			[p].FechaHoraAutorizacion	= [tp].FechaHoraAutorizacion,
			[p].NotaAutorizacion 		= [tp].NotaAutorizacion 
	from [Comedor].[tblPedidos] p
		join #tempPedidosAAutorizar tp on tp.IDPedido = p.IDPedido
GO
