USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [RH].[spValidarGeolocalizacion] --@IDEmpleado=17260,  @Latitud= 20.6569472, @Longitud =  -103.333888
(
	@Latitud  float =0,
	@Longitud float=0,
    @IDCliente int =0,
    @IDEmpleado int,
    @SoloValidacion bit=1
)
as BEGIN
      DECLARE @empleadoGeo GEOGRAPHY;
   DECLARE @configuracion NVARCHAR(MAX);
   DECLARE @validarGeolocalizacion BIT;
   DECLARE @metrosALaRedonda INT;
   DECLARE @mensaje NVARCHAR(255);
   DECLARE @RestringirChecada BIT;

DECLARE @ConfiguracionesCliente TABLE (
         IDTipoConfiguracionCliente VARCHAR(MAX) 
	,TipoConfiguracionCliente VARCHAR(MAX)
	,TipoDato VARCHAR(50)
	,IDAplicacion VARCHAR(MAX)
	,Valor VARCHAR(50)
	,Descripcion  VARCHAR(MAX)
	,IDConfiguracionCliente  INT
	,IDCliente  INT
	,Data VARCHAR(MAX)
      
   );

--    INSERT INTO @ConfiguracionesCliente
--    exec [RH].[spBuscarConfiguracionesCliente] @IDCliente = @IDCliente, @IDTipoConfiguracionCliente = 'ControlChecadasSucursalUbicacion';
   
   SELECT @RestringirChecada = ISNULL(Valor,0) From [RH].[tblCatTipoConfiguracionesCliente] cg  
		    Left outer join RH.tblConfiguracionesCliente tcg with (nolock) on cg.IDTipoConfiguracionCliente = tcg.IDTipoConfiguracionCliente  
			and tcg.IDCliente = @IDCliente
    where (cg.IDTipoConfiguracionCliente = 'ControlChecadasSucursalUbicacion');

   SELECT @configuracion = Valor 
   FROM app.tblConfiguracionesGenerales where IDConfiguracion='RegistrarAsistenciaEnLogin';

IF @Latitud IS NOT NULL AND @Longitud IS NOT NULL
    SET @empleadoGeo = geography::Point(@Latitud, @Longitud, 4326);
ELSE
    SET @empleadoGeo = NULL;

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
                   left join Rh.tblSucursalEmpleado SE with(nolock) on S.IDSucursal = SE.IDSucursal
                   WHERE (s.Latitud is not null and s.Longitud is not null)
                   AND ((@RestringirChecada=1 and SE.IDEmpleado = @IDEmpleado) or isnull(@RestringirChecada,0)=0)
                   Union ALL
                   select u.Nombre, u.Latitud, u.Longitud
                   from RH.tblCatUbicaciones u with(nolock)
                   left join RH.tblUbicacionesEmpleados UE  with(nolock) on u.IDUbicacion= UE.IDUbicacion
                   where u.Activo =1
                       and (u.Latitud is not null and u.Longitud is not null)
                       AND ((@RestringirChecada=1 and UE.IDEmpleado = @IDEmpleado) or isnull(@RestringirChecada,0)=0)
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

                if(@SoloValidacion=1)
                BEGIN
                print 'bitacora'
                   EXEC Asistencia.spIBitacoraChecadas 
                   @IDEmpleado = @IDEmpleado	
                   ,@Mensaje	 = @mensaje
                   ,@Latitud	 = @Latitud	
                   ,@Longitud	 = @Longitud	
                END
                   drop table #TempResp

   
       END
       ELSE
       BEGIN
           SELECT 
                        CAST(1 AS BIT) as Successful,
                       'Este empleado tiene la validación de verificación para geolocalización desactivada.' AS Mensaje,       
                        @Latitud AS Latitud,
                        @Longitud AS Longitud,
                        0 as DistanciaMetros

            if(@SoloValidacion=1)
            BEGIN
               EXEC Asistencia.spIBitacoraChecadas 
                @IDEmpleado = @IDEmpleado	
               ,@Mensaje	 =  'Este empleado tiene la validación de verificación para geolocalización desactivada.'	
               ,@Latitud	 = @Latitud	
               ,@Longitud	 = @Longitud	
            END
           
       END        
   END
   ELSE
   BEGIN
   SELECT 
                        CAST(1 AS BIT) as Successful,
                       'La validación de geolocalización está desactivada.' AS Mensaje,       
                        @Latitud AS Latitud,
                        @Longitud AS Longitud,
                        0 as DistanciaMetros
           
        if(@SoloValidacion=1)
        BEGIN
           EXEC Asistencia.spIBitacoraChecadas 
            @IDEmpleado = @IDEmpleado	
           ,@Mensaje	 =  'La validación de geolocalización está desactivada.'	
           ,@Latitud	 = @Latitud	
           ,@Longitud	 = @Longitud
        END	
   END
        
        
END
GO
