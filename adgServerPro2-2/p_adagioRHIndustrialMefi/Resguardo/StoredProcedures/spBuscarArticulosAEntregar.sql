USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spBuscarArticulosAEntregar](
	@IDEmpleado int
	,@IDUsuario int
) as
	
	select 
		h.IDHistorial
		,a.IDArticulo
		,a.IDTipoArticulo
		,cta.Nombre as TipoArticulo
		,a.IDEmpleado
		,h.IDLocker
		,clk.Codigo as Locker
	from [Resguardo].[tblArticulos] a with (nolock)
		join [Resguardo].[tblCatTiposArticulos] cta with (nolock) on a.IDTipoArticulo = cta.IDTipoArticulo
		join [Resguardo].[tblHistorial] h with (nolock)
			on a.IDArticulo = h.IDArticulo and a.IDEmpleado = h.IDEmpleado 
		join [Resguardo].[tblCatLockers] clk with (nolock) on h.IDLocker = clk.IDLocker
	where a.IDEmpleado = @IDEmpleado and isnull(h.Entregado,0) = 0
	
	--and IDArticulo in (
	--	select IDArticulo
	--	from [Resguardo].[tblHistorial] with (nolock)
	--	where IDEmpleado = @IDEmpleado and isnull(Entregado,0) = 0
	--)
GO
