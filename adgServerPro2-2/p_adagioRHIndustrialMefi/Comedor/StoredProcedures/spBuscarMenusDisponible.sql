USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarMenusDisponible] (
	@IDMenu int = 0,
	@IDTipoMenu int = 0,
	@IDRestaurante int,
	@SoloMenusDelDia bit = 0,
	@IDUsuario int
) as
	DECLARE @FechaHoraHoy DATETIME = GETDATE();

	SELECT
		m.IDMenu
		,m.IDTipoMenu
		,tm.Nombre as TipoMenu
		,tm.Descripcion as DescripcionTipoMenu
		,m.Nombre
		,m.Descripcion
		--,isnull(cm.PrecioCosto				 ,0.00) as PrecioCosto				
		,isnull(m.PrecioEmpleado			 ,0.00) as PrecioEmpleado			
		--,isnull(cm.PrecioPublico			 ,0.00) as PrecioPublico			
		,isnull(m.DisponibilidadPorFecha	 ,0) as DisponibilidadPorFecha	
		,isnull(m.FechaDisponibilidadInicio	 ,'1990-01-01') as FechaDisponibilidadInicio
		,isnull(m.FechaDisponibilidadFin	 ,'2100-12-31') as FechaDisponibilidadFin	
		,isnull(m.Disponible				 ,1) as Disponible				
		,isnull(m.MenuPedido				 ,0) as MenuPedido				
		,isnull(m.MenuDelDia				 ,0) as MenuDelDia				
		,isnull(m.IDMenuOriginal			 ,0) as IDMenuOriginal			
		,isnull(m.FechaHora				 ,getdate()) as FechaHora		
	FROM Comedor.tblCatTiposMenus tm
		INNER JOIN Comedor.tblCatMenus m ON tm.IDTipoMenu = m.IDTipoMenu
	WHERE
		-- and isnull(m.MenuPedido,0) = 0
		(m.IDMenu = @IDMenu or isnull(@IDMenu,0) = 0)
		AND (m.IDTipoMenu = @IDTipoMenu or isnull(@IDTipoMenu,0) = 0)
		AND isnull(m.MenuPedido,0) = 0
		AND (m.MenuDelDia = case when ISNULL(@SoloMenusDelDia, 0) = 1 then 1 else m.MenuDelDia end)
		AND (@IDRestaurante in (select cast(item as int) from App.Split(m.IdsRestaurantes, ',')) or isnull(@IDRestaurante, 0) = 0)
		AND ISNULL(tm.Disponible, 0) = 1
		AND ISNULL(m.Disponible, 0) = 1
		AND 
		(
			(
				(ISNULL(m.DisponibilidadPorFecha, 0) = 0 AND ISNULL(m.HistorialDisponibilidad, 0) = 0)
				AND
				(CAST(@FechaHoraHoy AS TIME) BETWEEN 
						ISNULL(tm.HoraDisponibilidadInicio, CAST('00:00:00' AS TIME))
						AND ISNULL(tm.HoraDisponibilidadFin, CAST('23:59:59' AS TIME)))
			)
			OR 
			(
				ISNULL(m.DisponibilidadPorFecha, 0) = 1
				AND CAST(@FechaHoraHoy AS DATE) BETWEEN m.FechaDisponibilidadInicio AND m.FechaDisponibilidadFin
				AND (
					CAST(@FechaHoraHoy AS TIME) BETWEEN 
						ISNULL(tm.HoraDisponibilidadInicio, CAST('00:00:00' AS TIME))
						AND ISNULL(tm.HoraDisponibilidadFin, CAST('23:59:59' AS TIME))
				)
			)
			OR (
				ISNULL(m.HistorialDisponibilidad, 0) = 1
				AND EXISTS (
					SELECT 1
					FROM Comedor.tblHistorialDisponibilidadMenu hdm
					WHERE
						hdm.IDMenu = m.IDMenu
						AND hdm.Activo = 1
						AND CAST(@FechaHoraHoy AS DATE) BETWEEN hdm.FechaInicio AND hdm.FechaFin
						AND (
							CAST(@FechaHoraHoy AS TIME) BETWEEN 
								ISNULL(hdm.HoraInicio, CAST('00:00:00' AS TIME))
								AND ISNULL(hdm.HoraFin, CAST('23:59:59' AS TIME))
						)
				)
			)
		);
GO
