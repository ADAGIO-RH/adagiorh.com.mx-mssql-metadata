USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spCopiarMenu](
	@IDMenu int,
	@Disponible bit,
	@MenuPedido bit,
	@dtOpcionesSeleccionadas  [Comedor].[dtOpcionesArticulos] readonly,
	@outIDMenu int output
) as
	
	declare 
		@IDMenuNuevo int

	insert [Comedor].[tblCatMenus](IDTipoMenu, Nombre, Descripcion, PrecioCosto, PrecioEmpleado, PrecioPublico,DisponibilidadPorFecha,FechaDisponibilidadInicio,FechaDisponibilidadFin,Disponible,MenuPedido,IDMenuOriginal,FechaHora)
	select IDTipoMenu, Nombre, Descripcion, PrecioCosto, PrecioEmpleado, PrecioPublico,DisponibilidadPorFecha,FechaDisponibilidadInicio,FechaDisponibilidadFin,@Disponible,1 as MenuPedido,@IDMenu as IDMenuOriginal,getdate()
	from [Comedor].[tblCatMenus] 
	where IDMenu = @IDMenu

	set @IDMenuNuevo = @@Identity


	-- En el detalle del menu solo poner la Opcion seleccionada
	insert [Comedor].[tblDetalleMenu](IDMenu, IDArticulo, Cantidad, PrecioExtra)
	select @IDMenuNuevo, IDArticulo, Cantidad, PrecioExtra
	from [Comedor].[tblDetalleMenu]
	where IDMenu = @IDMenu

	select @outIDMenu = @IDMenuNuevo
GO
