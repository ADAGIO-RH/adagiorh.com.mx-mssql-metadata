USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spBuscarArticulosARecibir](
	--declare
	@IDEmpleado int --=72
	,@IDUsuario int --= 1
) as
	
	select
		a.IDArticulo
		,a.IDTipoArticulo
		,cta.Nombre as TipoArticulo
		,a.IDEmpleado
	from [Resguardo].[tblArticulos] a with (nolock)
		join [Resguardo].[tblCatTiposArticulos] cta with (nolock) on a.IDTipoArticulo = cta.IDTipoArticulo
	where a.IDEmpleado = @IDEmpleado and a.IDArticulo not in (
		select IDArticulo
		from [Resguardo].[tblHistorial] with (nolock)
		where IDEmpleado = @IDEmpleado 
			and isnull(Entregado,0) = 0
			and isnull(TicketCancelado,0) = 0
	)
GO
