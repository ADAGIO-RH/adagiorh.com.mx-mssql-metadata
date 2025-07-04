USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spRegistrarDesktopChecada] --1,'015058',null,null,'America/Mexico_City'
(      
	@IDLector int = 0,      
	@ClaveEmpleado Varchar(20),
	@Latitud float = null,
	@Longitud float = null,
	@dtLectorZonaHoraria varchar(100) = 'America/Mexico_City'
)      
AS      
BEGIN      
	SET DATEFORMAT ymd;   
      
	DECLARE 
		@dtUTC DATETIME = getutcdate(),      
		@dtFechaZonaHoraria datetime,      
		@IDZonaHoraria int,      
		@IDChecada int = 0,      
		@Valida bit = 1,      
		@FechaOrigen Date,      
		@TipoChecada varchar(5),      
		@Mensaje varchar(1000),    
		@IDEmpleado int ,
		@dtEmpleados [RH].[dtEmpleados] ,
		@RequiereChecar bit,  
		@PermiteChecar bit,
		@EsRepetida bit= 0 ,
		@Lector	varchar(100),
		@CodigoLector	varchar(100),
		@Comida bit = 0,
		@UltimaChecada datetime,              
		@TiempoEntreChecada int,  
		@MensajeValidacion varchar(1000),
		@IDTipoLector	varchar(100)
	;

	if (isnull(@IDLector, 0) = 0) 
	begin
		select top 1 
			@IDLector = IDLector,
			@IDTipoLector = l.IDTipoLector
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
	begin
		select
			@IDTipoLector = l.IDTipoLector
		from [Asistencia].[tblLectores] l with (nolock) 
		where IDLector = @IDLector
	end

	select 
		@Lector = Lector, 
		@CodigoLector = CodigoLector, 
		@Comida = isnull(Comida,0),

		/*
			Se determina que ZonaHoraria utilizar ya que cuando se registra asistencia desde el Login la ZonaHoraria viene
			por parámetros y cuando es en otro tipo de lector se toma la zona horaria asignada al lector en la tabla de Lectores.
		*/
		@dtLectorZonaHoraria = case when @IDTipoLector != 'LectorLogin' then z.[Name] else @dtLectorZonaHoraria end 
	from Asistencia.tblLectores l with (nolock)	
		left join Tzdb.Zones z on z.Id = l.IDZonaHoraria
	where IDLector = @IDLector

	select @IDZonaHoraria = case when isnull(z.Id,0) = 0 then null 
							else 
						z.Id end
	from Tzdb.Zones z
	where z.[Name] = @dtLectorZonaHoraria

	insert into @dtEmpleados
	select top 1 * from RH.tblEmpleadosMaster with (nolock) where ClaveEmpleado = @ClaveEmpleado

	if exists(select top 1 1 from @dtEmpleados where ClaveEmpleado = @ClaveEmpleado)    
	begin    
		select top 1 @IDEmpleado = IDEmpleado from @dtEmpleados where ClaveEmpleado = @ClaveEmpleado    
	end    
	else    
	BEGIN    
		set @IDEmpleado = 0    
	end    
    
	if(@IDEmpleado <> 0)    
	BEGIN    
		set @dtFechaZonaHoraria = case 
									when isnull(@dtLectorZonaHoraria, '') = '' then getdate()
									else Tzdb.UtcToLocal(@dtUTC,@dtLectorZonaHoraria) end
  
		IF(@Comida = 1)
		BEGIN
			select top 1 @UltimaChecada = fecha               
			from Comedor.tblComidasConsumidas with(nolock)              
			where IDEmpleado = @IDEmpleado and cast(Fecha as date) = cast(@dtFechaZonaHoraria as date)              
			order by Fecha desc    
              
			select top 1 @TiempoEntreChecada = cast(valor as int) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoEntreChecadas'              
              
			if(DATEADD(MINUTE,@TiempoEntreChecada,@UltimaChecada) >= @dtFechaZonaHoraria)              
			BEGIN              
				set @EsRepetida = 1;              
				set @MensajeValidacion = 'COMIDA REPETIDA. Última comida registrada a las '+ cast(@UltimaChecada as varchar)+'.';                
			END              
			ELSE              
			BEGIN              
				insert into Comedor.tblComidasConsumidas(IDEmpleado,Fecha,IDLector)      
				select @IDEmpleado,@dtFechaZonaHoraria as Fecha,@IDLector  
				
				set @MensajeValidacion = 'COMIDA registrada correctamente';              
			END         
				
			Select       
				0 as IDChecada,      
				getdate() as Fecha,      
				getdate() as FechaOrigen,      
				@IDLector as IDLector,      
				@Lector as Lector,      
				e.IDEmpleado as IDEmpleado,      
				e.ClaveEmpleado as ClaveEmpleado,      
				e.NOMBRECOMPLETO as NombreCompleto,      
				e.Departamento as Departamento,      
				e.Puesto as Puesto,       
				0 as IDUsuario,      
				'' as Comentario,      
				'CO' as IDTipoChecada,      
				'COMIDA' as TipoChecada,      
				0 as IDZonaHoraria,      
				'' as ZonaHoraria,      
				getdate() as FechaReg,      
				cast(1 as bit) as Valida,      
				@MensajeValidacion as MensajeChecada      
			from RH.tblEmpleadosMaster e with (nolock)
			where e.IDEmpleado = @IDEmpleado

			EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'COMIDA registrada correctamente' 
		END
		
		select  @FechaOrigen = t.FechaOrigen,      
				@TipoChecada = t.TipoChecada      
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@dtFechaZonaHoraria) t      
      
		--select @IDEmpleado,@FechaOrigen,@TipoChecada,@IDLector, @dtFechaZonaHoraria      
		select top 1 @RequiereChecar = RequiereChecar, @PermiteChecar = PermiteChecar from @dtEmpleados where IDEmpleado = @IDEmpleado
     
		if(@RequiereChecar = 1) 
		begin
				exec [Asistencia].[spValidarChecada]     
					@IDEmpleado				= @IDEmpleado,      
					@dtEmpleados2			= @dtEmpleados,
					@FechaOrigen			= @FechaOrigen,      
					@Tipochecada			= @TipoChecada,      
					@IDLector				= @IDLector,      
					@dtFechaZonaHoraria		= @dtFechaZonaHoraria,      
					@outChecadaValida		= @Valida output,      
					@outMensajeValidacion	= @Mensaje output,
					@outEsRepetida			= @EsRepetida output   
		end
		else
		begin
			set @Valida = 1
			set @Mensaje = ''
		end

		--select @Valida, @Mensaje  
		if ((@Valida = 1) and (@EsRepetida = 0))
		BEGIN      
			insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,IDZonaHoraria,Automatica,FechaReg,FechaOriginal, Latitud,Longitud)      
			select @dtFechaZonaHoraria as Fecha      
					,@FechaOrigen      
					,@IDLector      
					,@IDEmpleado      
					,@TipoChecada      
					,@IDZonaHoraria      
					,cast(1 as bit)      
					,@dtUTC      
					,@dtFechaZonaHoraria
					,@Latitud
					,@Longitud
					
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
				tc.TipoChecada,      
				isnull(c.IDZonaHoraria,0) as IDZonaHoraria,      
				z.Name as ZonaHoraria,      
				c.FechaReg,      
				@Valida as Valida,      
				cast('Checada Registrada Satisfactoriamente. Tipo Checada: ' + JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'TipoChecada')) as varchar(1000))  as MensajeChecada      
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
		ELSE      
		BEGIN      
			Select       
				0 as IDChecada,      
				@dtFechaZonaHoraria  as Fecha,      
				@FechaOrigen as FechaOrigen,      
				isnull(l.IDLector,0) as IDLector,      
				'Lector' as Lector,      
				isnull(m.IDEmpleado,0) as IDEmpleado,      
				isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,      
				m.NOMBRECOMPLETO as NombreCompleto,      
				m.Departamento as Departamento,      
				m.Puesto as Puesto,       
				0 as IDUsuario,      
				'' as Comentario,      
				'' as IDTipoChecada,      
				'' as TipoChecada,      
				isnull(@IDZonaHoraria,0) as IDZonaHoraria,      
				@dtLectorZonaHoraria as ZonaHoraria,      
				@dtUTC as FechaReg,      
				@Valida as Valida,      
				@Mensaje as MensajeChecada      
			FROM Asistencia.tblLectores l with (nolock)       
				cross apply RH.tblEmpleadosMaster m with (nolock)       
			WHERE l.IDLector = @IDLector      
				and M.IDEmpleado = @IDEmpleado      
      
			EXEC Asistencia.spIBitacoraChecadas 
				 @IDEmpleado = @IDEmpleado	
				,@Fecha		 = @dtUTC		
				,@IDLector	 = @IDLector	
				,@Mensaje	 = @Mensaje	
				,@Latitud	 = @Latitud	
				,@Longitud	 = @Longitud	
		END      
	END    
	else     
	begin    
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

		EXEC Asistencia.spIBitacoraChecadas 
			@IDEmpleado = @IDEmpleado	
			,@Fecha		 = @dtUTC		
			,@IDLector	 = @IDLector	
			,@Mensaje	 = 'Empleado no existente en la base de datos.'	
			,@Latitud	 = @Latitud	
			,@Longitud	 = @Longitud
	end    
  
	select Mensaje          
	from Asistencia.tblMensajesEmpleados with (nolock)          
	where IDEmpleado = @IDEmpleado and  @dtUTC between FechaInicio and FechaFin       
END
GO
