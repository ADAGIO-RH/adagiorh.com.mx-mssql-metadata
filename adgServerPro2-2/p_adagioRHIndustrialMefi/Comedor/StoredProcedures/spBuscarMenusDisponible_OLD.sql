USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create    proc [Comedor].[spBuscarMenusDisponible_OLD] (
	@IDMenu int = 0,
	@IDTipoMenu int = 0,
	@IDRestaurante int,
	@IDUsuario int = 1
) as
	declare 
		@FechaHoy date = getdate(),
		@HoraHoy time = getdate()
	;

	select
		 cm.IDMenu
		,cm.IDTipoMenu
		,ctm.Nombre as TipoMenu
		,ctm.Descripcion as DescripcionTipoMenu
		,cm.Nombre
		,cm.Descripcion
		--,isnull(cm.PrecioCosto				 ,0.00) as PrecioCosto				
		,isnull(cm.PrecioEmpleado			 ,0.00) as PrecioEmpleado			
		--,isnull(cm.PrecioPublico			 ,0.00) as PrecioPublico			
		,isnull(cm.DisponibilidadPorFecha	 ,0) as DisponibilidadPorFecha	
		,isnull(cm.FechaDisponibilidadInicio ,'1990-01-01') as FechaDisponibilidadInicio
		,isnull(cm.FechaDisponibilidadFin	 ,'2100-12-31') as FechaDisponibilidadFin	
		,isnull(cm.Disponible				 ,1) as Disponible				
		,isnull(cm.MenuPedido				 ,0) as MenuPedido				
		,isnull(cm.IDMenuOriginal			 ,0) as IDMenuOriginal			
		,isnull(cm.FechaHora				 ,getdate()) as FechaHora				
	from [Comedor].[tblCatMenus] cm with (nolock)
		join [Comedor].[tblCatTiposMenus] ctm with (nolock) on cm.IDTipoMenu = ctm.IDTipoMenu 
			and isnull([ctm].[Disponible],0) = 1 
			and @HoraHoy between isnull(ctm.HoraDisponibilidadInicio, cast(getdate() as time)) and isnull(ctm.HoraDisponibilidadFin, cast(getdate() as time))
	where (cm.IDMenu = @IDMenu or isnull(@IDMenu,0) = 0)
		and (cm.IDTipoMenu = @IDTipoMenu or isnull(@IDTipoMenu,0) = 0)
		and isnull(cm.MenuPedido,0) = 0
		and (@IDRestaurante in (select cast(item as int) from App.Split(cm.IdsRestaurantes, ',')) or isnull(@IDRestaurante, 0) = 0)
		and isnull([cm].[Disponible],0) = 1

		and (
				(
					@FechaHoy between isnull(cm.FechaDisponibilidadInicio, cast(getdate() as date))
						and isnull(cm.FechaDisponibilidadFin, cast(getdate() as date))
					or 
						isnull(cm.DisponibilidadPorFecha,0) = 0
				)
		
		
		)

		/*
		and (@FechaHoy between
			(isnull(cm.FechaDisponibilidadInicio, cast(getdate() as date))) and
			(isnull(cm.FechaDisponibilidadFin, cast(getdate() as date)))
			or 
			isnull(cm.DisponibilidadPorFecha,0) = 0
			)
		*/
GO
