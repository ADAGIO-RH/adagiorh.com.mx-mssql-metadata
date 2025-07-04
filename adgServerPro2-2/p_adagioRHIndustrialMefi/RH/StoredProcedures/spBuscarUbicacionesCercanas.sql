USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [RH].[spBuscarUbicacionesCercanas](
	@Latitud  float,
	@Longitud float
) as

	DECLARE @empleadoGeo geography;

	SET @empleadoGeo = geography::Point(@Latitud, @Longitud, 4326)  

	select 
		geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) as Metros,
		geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) / 1000.00 as Kilometros,	
		IDUbicacion
		,Nombre
		,Latitud
		,Longitud
	from RH.tblCatUbicaciones
	where 
		Latitud is not null and 
		Longitud is not null AND
        Activo=1
	order by geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) asc
GO
