USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [RH].[spValidarGeolocalizacion]
(
	@Latitud  float =0,
	@Longitud float=0,
    @IDEmpleado int
)
as BEGIN
    DECLARE @empleadoGeo GEOGRAPHY;
    DECLARE @configuracion NVARCHAR(MAX);
    DECLARE @validarGeolocalizacion BIT;
    DECLARE @metrosALaRedonda INT;
    DECLARE @mensaje NVARCHAR(255);

    SELECT @configuracion = Valor 
    FROM app.tblConfiguracionesGenerales where IDConfiguracion='RegistrarAsistenciaEnLogin';

	SET @empleadoGeo = geography::Point(@Latitud, @Longitud, 4326)   

  SET @validarGeolocalizacion = JSON_VALUE(@configuracion, '$.validar_geolocalizacion');
    SET @metrosALaRedonda = JSON_VALUE(@configuracion, '$.metros_a_la_redonda');


    IF @validarGeolocalizacion = 1
    BEGIN
    IF (NOT EXISTS (SELECT 1 FROM rh.tblEmpleadoGeolocalizacion WHERE IDEmpleado = @IDEmpleado AND OmitirGeolocalizacion = 1))
        BEGIN
            WITH Coordenadas as 
            (
                select s.Descripcion as Nombre, s.Latitud, s.Longitud  
				from RH.tblCatSucursales S with(nolock)
				WHERE s.Latitud is not null and s.Longitud is not null
                Union ALL
                select u.Nombre, u.Latitud, u.Longitud
				from RH.tblCatUbicaciones u with(nolock)
				where u.Activo =1
					and u.Latitud is not null and u.Longitud is not null
            )

                    SELECT TOP 1
                      CASE 
                                WHEN geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) <= @metrosALaRedonda
                                THEN cast(1 as bit)--'Dentro del rango'
                                ELSE cast (0 as bit)--'Fuera del rango'
                            END AS Successful,
                        CASE 
                                WHEN geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) <= @metrosALaRedonda
                                THEN 'Dentro del rango'
                                ELSE 'Fuera del rango'
                            END AS Mensaje,
                            @Latitud AS Latitud,
                            @Longitud AS Longitud,
                            geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo) AS DistanciaMetros
                        INTO #TempResp
                        FROM Coordenadas               
                        ORDER BY geography::Point(Latitud, Longitud, 4326).STDistance(@empleadoGeo);

                        select * from #TempResp
                        
                  set @mensaje =  (SELECT TOP 1 Mensaje FROM #TempResp)    

                EXEC Asistencia.spIBitacoraChecadas 
				 @IDEmpleado = @IDEmpleado	
				,@Mensaje	 = @mensaje
				,@Latitud	 = @Latitud	
				,@Longitud	 = @Longitud	

                drop table #TempResp

   
        END
        ELSE
        BEGIN
            SELECT 
                        @Latitud AS Latitud,
                        @Longitud AS Longitud,
                        'La validación de geolocalización está desactivada.' AS Mensaje,                        
                         CAST(1 AS BIT) as Successful;

                EXEC Asistencia.spIBitacoraChecadas 
				 @IDEmpleado = @IDEmpleado	
				,@Mensaje	 =  'La validación de geolocalización está desactivada.'	
				,@Latitud	 = @Latitud	
				,@Longitud	 = @Longitud	

            
        END
          
END
        
END
GO
