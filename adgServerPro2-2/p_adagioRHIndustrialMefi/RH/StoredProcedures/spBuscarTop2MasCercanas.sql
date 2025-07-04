USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc RH.spBuscarTop2MasCercanas(
	@Latitud  float,
	@Longitud float
) as

	DECLARE @empleadoGeo geography;

	SET @empleadoGeo = geography::Point(@Latitud, @Longitud, 4326)  

	select 
		top 2
		geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) as Metros,
		geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) / 1000.00 as Kilometros,	
		IDSucursal
		,Codigo
		,Descripcion
		,Latitud
		,Longitud
	from RH.tblCatSucursales
	where 
		Latitud is not null and 
		Longitud is not null
	order by geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) asc
GO
