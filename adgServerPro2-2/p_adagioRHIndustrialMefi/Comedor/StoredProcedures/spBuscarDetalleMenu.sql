USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[Comedor].[spBuscarDetalleMenu] @IDMenu=4
--GO


CREATE proc [Comedor].[spBuscarDetalleMenu](@IDDetalleMenu int = 0
										   ,@IDMenu        int = 0
										   )
as
	 select 
			[Dm].[IDDetalleMenu]
		   ,[Dm].[IDMenu]
		   ,[Dm].[IDArticulo]
		   ,a.Nombre as Articulo
			--,isnull(a.PrecioCosto				 ,0.00) as PrecioCosto				
			,isnull(a.PrecioEmpleado			 ,0.00) as PrecioEmpleado			
			--,isnull(a.PrecioPublico			 ,0.00) as PrecioPublico
		   ,[Dm].[Cantidad]
		   ,[Dm].[PrecioExtra]
		   ,isnull([Dm].[FechaHora],getdate()) as [Fechahora]
		   ,OpcionesArticulo = (
				select 
					op.IDOpcionArticulo	
					,op.IDArticulo			
					,op.Nombre				
					,isnull(op.PrecioExtra,0) as PrecioExtra
					,isnull(op.Disponible,0) as Disponible		
				from Comedor.tblOpcionesArticulo op
				where op.IDArticulo = [A].IDArticulo AND isnull(op.[Disponible],0) = 1
				for json auto 
			)
	  from [Comedor].[tblDetalleMenu] [Dm] with(nolock)
		join [Comedor].[tblCatArticulos] a on a.IDArticulo = dm.IDArticulo
	  where([Dm].[IDDetalleMenu] = isnull(@IDDetalleMenu,0)
			or isnull(@IDDetalleMenu,0) = 0)
		   and ([Dm].[IDMenu] = isnull(@IDMenu,0)
				or isnull(@IDMenu,0) = 0)
		   and (
			isnull(@IDDetalleMenu,0) + isnull(@IDMenu,0) > 0);
GO
