USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spRegistrarMobilChecadaOffline](      
	@IDLector int = 0,      
	@ClaveEmpleado Varchar(20),
	@Latitud float = null,
	@Longitud float = null,
	@dtLectorZonaHoraria varchar(100) = 'America/Mexico_City',
    @FechaHoraChecada datetime
)      
AS      
BEGIN      
    SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;
	DECLARE 
		@dtUTC DATETIME = getdate(),      		
		@dtFechaZonaHoraria Datetime,      
		@IDZonaHoraria int,      
		@IDChecada int = 0,      
		@Valida bit = 1,      
		@FechaOrigen Date,      
		@TipoChecada Varchar(5),      
		@Mensaje Varchar(max),
		@IDClienteLector int,
		@IDUsuario int,		
		@EsComedor bit = 0,
        @IDEmpleado int ,
		@Comida bit = 0,
		@TiempoEntreChecadas int ,
		@EsRepetida bit= 0 ,
		@dtEmpleados [RH].[dtEmpleados] ,
		@TiempoEntreChecada int,
		@UltimaChecada datetime,
        @IDIdioma varchar(max)
    
	;
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	select @IDUsuario = cast(Valor as int)
	from  App.tblConfiguracionesGenerales with (nolock)
	where [IDConfiguracion] ='IDUsuarioAdmin'
   
	select @IDClienteLector = IDCliente, @EsComedor = isnull(EsComedor,0), @Comida = isnull(Comida,0)
	from Asistencia.tblLectores with (nolock)
	where IDLector = @IDLector

    if (isnull(@IDLector, 0) = 0) 
	begin
		select top 1 
			@IDLector = IDLector			
		from [Asistencia].[tblLectores] l with (nolock)
		where l.IDTipoLector = 'LectorLogin'-- Lector like '%login%'-- and IDTipoLector = 'FACERECOGNITION'

		if (isnull(@IDLector, 0) = 0) 
		begin
			raiserror(
				'No existe lector configurado para registro de asistencia. Contacte con un administrador.',
				16,
				1
			)
			return
		end
	end


	select top 1 @TiempoEntreChecadas = cast(valor as int) from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas' 	
		
	select @IDEmpleado = IDEmpleado
	from RH.tblEmpleados with (nolock)
	where ClaveEmpleado = @ClaveEmpleado

	exec Asistencia.spBKLectoresZK @IDLector = @IDLector,@IDEmpleado = @IDEmpleado,@Checada = @FechaHoraChecada,@FechaHora = @dtUTC
             
	if(isnull(@IDEmpleado,0) <> 0 and exists(select top 1 1 from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado))    
	BEGIN   
		select  @FechaOrigen = t.FechaOrigen,      
				@TipoChecada = t.TipoChecada      
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@FechaHoraChecada) t      
		 		     		            
        select top 1 @UltimaChecada = fecha               
            from Asistencia.tblChecadas  with(nolock)              
            where IDEmpleado = @IDEmpleado               
                and FechaOrigen = @FechaOrigen   
                and Fecha < @FechaHoraChecada
            Order by Fecha desc   

        if not exists( select top 1 1 from Asistencia.tblChecadas with (nolock) where IDEmpleado = @IDEmpleado and Fecha = @FechaHoraChecada )  
        BEGIN                  			   						              
            select top 1 @TiempoEntreChecada = cast(valor as int) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoEntreChecadas'                                  
            if(DATEADD(MINUTE,@TiempoEntreChecada,@UltimaChecada) >= @FechaHoraChecada)              
            BEGIN                                      

                Select       
    			    0 as IDChecada,      
			        getdate()  as Fecha,      
			        getdate() as FechaOrigen,      
			        0 as IDLector,      
    			    'Lector' as Lector,      
			        0 as IDEmpleado,      
			        '00000' as ClaveEmpleado,      
    			    '...' as NombreCompleto,      
    			    '...' as Departamento,      
			        '...' as Puesto,       
			        0 as IDUsuario,      
    			    '' as Comentario,      
    			    '' as IDTipoChecada,      
    			    '' as TipoChecada,      
    			    0 as IDZonaHoraria,      
			        '' as ZonaHoraria,      
    			    getdate() as FechaReg,      
			        cast    (0 as bit) as Valida,      
			        'CHECADA REPETIDA. Ultima checada registrada a las '+ cast(@UltimaChecada as varchar)+'.' as MensajeChecada    
         
                EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@FechaHoraChecada,@IDLector,@Mensaje  
            END              
            ELSE              
            BEGIN              				
                insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,FechaReg, FechaOriginal,Comentario,Latitud,Longitud)      
                select @FechaHoraChecada as Fecha      
                ,@FechaOrigen      
                ,@IDLector      
                ,@IDEmpleado      
                ,@TipoChecada         
                ,@dtUTC      
                ,@FechaHoraChecada
                ,'App Checada Offline',
                @Latitud ,
	            @Longitud

                set @IDChecada = @@IDENTITY             

                	Select       
                        c.IDChecada,      
                        c.Fecha,      
                        c.FechaOrigen,      
                        isnull(c.IDLector,0) as IDLector,      
                        isnull(l.Lector,'NINGUNO') as Lector,      
                        isnull(c.IDEmpleado,0) as IDEmpleado,      
                        isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,      
                        m.NOMBRECOMPLETO as NombreCompleto,      
                        m.Departamento as Departamento,      
                        m.Puesto as Puesto,       
                        isnull(c.IDUsuario,0) as IDUsuario,      
                        c.Comentario,      
                        c.IDTipoChecada,      
                       JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada,      
                        isnull(c.IDZonaHoraria,0) as IDZonaHoraria,      
                        z.Name as ZonaHoraria,      
                        c.FechaReg,      
                        @Valida as Valida,      
                        cast('Checada Registrada Satisfactoriamente. Tipo Checada: ' + tc.TipoChecada as varchar(1000))  as MensajeChecada      
                    from Asistencia.tblChecadas c with (nolock)       
                        inner join Asistencia.tblLectores l with (nolock)       
                            on c.IDLector = l.IDLector      
                        INNER JOIN RH.tblEmpleadosMaster m with (nolock)       
                            on c.IDEmpleado = m.IDEmpleado      
                        Inner join Asistencia.tblCatTiposChecadas tc with (nolock)       
                            on c.IDTipoChecada = tc.IDTipoChecada    
                        left join tzdb.Zones z with (nolock)       
                            on z.Id = c.IDZonaHoraria     
                    where IDChecada = @IDChecada

            END              		              		             	  
        END 
        ELSE BEGIN
        	Select       
			    0 as IDChecada,      
			    getdate()  as Fecha,      
			    getdate() as FechaOrigen,      
			    0 as IDLector,      
			    'Lector' as Lector,      
			    0 as IDEmpleado,      
			    '00000' as ClaveEmpleado,      
    			'...' as NombreCompleto,      
			    '...' as Departamento,      
			    '...' as Puesto,       
			    0 as IDUsuario,      
			    '' as Comentario,      
    			'' as IDTipoChecada,      
			    '' as TipoChecada,      
    			0 as IDZonaHoraria,      
			    '' as ZonaHoraria,      
			    getdate() as FechaReg,      
			    cast(0 as bit) as Valida,      
			    'CHECADA REPETIDA.'as MensajeChecada    
            EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'CHECADA REPETIDA'   
        END

        if (@Valida = 0)
        BEGIN
            EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,@Mensaje      
        END;
        	     
	END  
	ELSE  
	BEGIN  
    	Select       
			0 as IDChecada,      
			getdate()  as Fecha,      
			getdate() as FechaOrigen,      
			0 as IDLector,      
			'Lector' as Lector,      
			0 as IDEmpleado,      
			'00000' as ClaveEmpleado,      
			'...' as NombreCompleto,      
			'...' as Departamento,      
			'...' as Puesto,       
			0 as IDUsuario,      
			'' as Comentario,      
			'' as IDTipoChecada,      
			'' as TipoChecada,      
			0 as IDZonaHoraria,      
			'' as ZonaHoraria,      
			getdate() as FechaReg,      
			cast(0 as bit) as Valida,      
			'Empleado no existente en la base de datos.'as MensajeChecada    

		EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'Empleado no existe.' 
	END    
    
END
GO
