USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [Comedor].[spBuscarDetalleMenuDisponibles](
	@IDDetalleMenu int = 0
	,@IDMenu int = 0
)
as
	DECLARE 
		@FechaHoraHoy DATETIME = GETDATE(),
		@OpcionesArticulosDisponbibles varchar(max)
	;
	
	if (isnull(@IDMenu, 0) = 0)
	begin
		select @IDMenu = IDMenu from Comedor.tblDetalleMenu where IDDetalleMenu = @IDDetalleMenu
	end

	SELECT top 1 @OpcionesArticulosDisponbibles=OpcionesArticulosDisponbibles
	FROM Comedor.tblHistorialDisponibilidadMenu hdm
	WHERE hdm.IDMenu = @IDMenu AND hdm.Activo = 1
		AND CAST(@FechaHoraHoy AS DATE) BETWEEN hdm.FechaInicio AND hdm.FechaFin
		AND (
			CAST(@FechaHoraHoy AS TIME) BETWEEN 
				ISNULL(hdm.HoraInicio, CAST('00:00:00' AS TIME))
				AND ISNULL(hdm.HoraFin, CAST('23:59:59' AS TIME))
		)

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
		,OpcionesArticulo = 
			case when isnull(m.HistorialDisponibilidad, 0) = 0 or coalesce(@OpcionesArticulosDisponbibles, '') = '' or @OpcionesArticulosDisponbibles = '[]' then
				(
					select 
						 op.IDOpcionArticulo	
						,op.IDArticulo			
						,op.Nombre				
						,isnull(op.PrecioExtra,0) as PrecioExtra
						,isnull(op.Disponible,0) as Disponible		
					from Comedor.tblOpcionesArticulo op
					where op.IDArticulo = a.IDArticulo AND isnull(op.[Disponible],0) = 1
					for json auto 
				)
			else 
				(
					select 
						 op2.IDOpcionArticulo	
						,op2.IDArticulo			
						,op2.Nombre				
						,isnull(op2.PrecioExtra,0) as PrecioExtra
						,isnull(op2.Disponible,0) as Disponible		
					from Comedor.tblOpcionesArticulo op2
						left join OPENJSON(@OpcionesArticulosDisponbibles, '$') 
							with (
								IDOpcionArticulo int,
								IDArticulo int,
								Disponible bit
							) cOpciones on cOpciones.IDOpcionArticulo = op2.IDOpcionArticulo and cOpciones.IDArticulo = a.IDArticulo
					where op2.IDArticulo = a.IDArticulo and isnull(op2.Disponible,0)  = 1 and isnull(cOpciones.Disponible,0) = 1
					for json auto
				) 
			end
	from [Comedor].[tblDetalleMenu] [Dm] with(nolock)
		join Comedor.tblCatMenus m on m.IDMenu = Dm.IDMenu
		join [Comedor].[tblCatArticulos] a on a.IDArticulo = dm.IDArticulo
	where ([Dm].[IDDetalleMenu] = isnull(@IDDetalleMenu,0) or isnull(@IDDetalleMenu,0) = 0)
		and ([Dm].[IDMenu] = isnull(@IDMenu,0) or isnull(@IDMenu,0) = 0)
		and (isnull(@IDDetalleMenu,0) + isnull(@IDMenu,0) > 0);
GO
