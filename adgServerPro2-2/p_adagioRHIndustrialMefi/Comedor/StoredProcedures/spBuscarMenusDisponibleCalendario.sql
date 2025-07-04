USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
/****************************************************************************************************       
** Descripción  : Buscar los eventos del calendario de comidas     
** Autor   : Denzel Ovando   
** Email   : denzel.ovando@adagio.com.mx      
** FechaCreacion : 2020-10-26      
** Paremetros  :  
       @@Fecha date      
      ,@IDUsuario int      
            

****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd)	Autor			Comentario      
------------------- ------------------- ------------------------------------------------------------      
2021-02-02			Aneudy Abreu	Cambié el query para que busque los menús disponibles de un solo 
									día sin contemplarar la hora.
***************************************************************************************************/      
CREATE proc [Comedor].[spBuscarMenusDisponibleCalendario]--20314,'2018-09-01','2018-09-30',1    
(          
	@Fecha date      
	,@IDUsuario int      
) as      
      
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
		,isnull(cm.MenuDelDia				 ,0) as MenuDelDia		
		,isnull(cm.IDMenuOriginal			 ,0) as IDMenuOriginal			
		,isnull(cm.FechaHora				 ,getdate()) as FechaHora	
		,cm.IdsRestaurantes
	from [Comedor].[tblCatMenus] cm with (nolock)
		join [Comedor].[tblCatTiposMenus] ctm with (nolock) on cm.IDTipoMenu = ctm.IDTipoMenu and 
			isnull([ctm].[Disponible],0) = 1 
			--and @HoraHoy between isnull(ctm.HoraDisponibilidadInicio, cast(getdate() as time)) and isnull(ctm.HoraDisponibilidadFin, cast(getdate() as time))
	where 
		 ISNULL(ctm.Disponible, 0) = 1
		AND ISNULL(cm.Disponible, 0) = 1
		AND 
		(
			(
				(ISNULL(cm.DisponibilidadPorFecha, 0) = 0 AND ISNULL(cm.HistorialDisponibilidad, 0) = 0)
				--AND
				--(CAST(@Fecha AS TIME) BETWEEN 
				--		ISNULL(tm.HoraDisponibilidadInicio, CAST('00:00:00' AS TIME))
				--		AND ISNULL(tm.HoraDisponibilidadFin, CAST('23:59:59' AS TIME)))
			)
			OR 
			(
				ISNULL(cm.DisponibilidadPorFecha, 0) = 1
				AND CAST(@Fecha AS DATE) BETWEEN cm.FechaDisponibilidadInicio AND cm.FechaDisponibilidadFin
				--AND (
				--	CAST(@Fecha AS TIME) BETWEEN 
				--		ISNULL(tm.HoraDisponibilidadInicio, CAST('00:00:00' AS TIME))
				--		AND ISNULL(tm.HoraDisponibilidadFin, CAST('23:59:59' AS TIME))
				--)
			)
			OR (
				ISNULL(cm.HistorialDisponibilidad, 0) = 1
				AND EXISTS (
					SELECT 1
					FROM Comedor.tblHistorialDisponibilidadMenu hdm
					WHERE
						hdm.IDMenu = cm.IDMenu
						AND hdm.Activo = 1
						AND CAST(@Fecha AS DATE) BETWEEN hdm.FechaInicio AND hdm.FechaFin
						--AND (
						--	CAST(@FechaHoraHoy AS TIME) BETWEEN 
						--		ISNULL(hdm.HoraInicio, CAST('00:00:00' AS TIME))
						--		AND ISNULL(hdm.HoraFin, CAST('23:59:59' AS TIME))
						--)
				)
			)
		);

	
	--(@Fecha between
	--		(isnull(cm.FechaDisponibilidadInicio, cast(getdate() as date))) and
	--		(isnull(cm.FechaDisponibilidadFin, cast(getdate() as date)))
	--		or 
	--		isnull(cm.DisponibilidadPorFecha,0) = 0
	--		)
	--	and isnull([cm].[Disponible],0) = 1
GO
