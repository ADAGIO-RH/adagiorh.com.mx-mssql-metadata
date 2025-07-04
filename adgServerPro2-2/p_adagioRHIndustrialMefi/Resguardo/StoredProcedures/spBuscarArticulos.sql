USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spBuscarArticulos](
	@IDArticulo int = 0
	,@IDEmpleado int = 0
	,@IDUsuario int
)as
begin
	select 
		a.IDArticulo
		,a.IDTipoArticulo
		,cta.Nombre as TipoArticulo
		,a.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as NombreCompleto
	from [Resguardo].[tblArticulos] a with (nolock)
		join [RH].[tblEmpleadosMaster] e with (nolock) on a.IDEmpleado = e.IDEmpleado
		join [Resguardo].[tblCatTiposArticulos] cta with (nolock) on a.IDTipoArticulo = cta.IDTipoArticulo
	where (a.IDArticulo = @IDArticulo or @IDArticulo = 0) and (a.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)

end
GO
