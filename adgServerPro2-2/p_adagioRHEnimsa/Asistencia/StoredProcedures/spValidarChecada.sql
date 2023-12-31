USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spValidarChecada] --1320,'2019-05-05','ET',3,'2019-05-05 10:59:14.010'              
(              
  @IDEmpleado int,    
  @dtEmpleados2 [RH].[dtEmpleados] readonly,          
  @FechaOrigen Date,              
  @Tipochecada Varchar(10),              
  @IDLector int,              
  @dtFechaZonaHoraria datetime,              
  @outChecadaValida bit output,              
  @outMensajeValidacion Varchar(MAX) output ,
  @outEsRepetida bit output              
)              
AS              
BEGIN              
  
	SET DATEFORMAT ymd;            
              
	Declare               
		--@IDEmpleado int,              
		@ClaveEmpleado varchar(20),              
		--@FechaOrigen Date,              
		--@Tipochecada Varchar(10),              
		--@IDLector int,              
		@dtEmpleados [RH].[dtEmpleados],              
		@ChecadaValida bit = 1,              
		@MensajeValidacion Varchar(MAX),              
		--@dtFechaZonaHoraria datetime,              
		@UltimaChecada Datetime,              
		@TiempoEntreChecada int,              
		@tipoContrato varchar(10),              
		@Incidencia varchar(100) ,            
		@Vigente bit = 0      ,
		@EsRepetida bit = 0
	;      
        
	insert @dtEmpleados
	select * from @dtEmpleados2      
        
	if not exists (select top 1 1 
				from @dtEmpleados)
	begin
		insert into @dtEmpleados    
		select * from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado       
	end
              
	select top 1 @ClaveEmpleado = ClaveEmpleado, @Vigente = Vigente from @dtEmpleados where IDEmpleado = @IDEmpleado              

	--=========================================              
	--=======VIGENCIA==========================              
	if(@ChecadaValida = 1)              
	BEGIN              
		--insert into @dtEmpleados              
		--exec [RH].[spBuscarEmpleados] @FechaIni = @FechaOrigen              
		--        ,@Fechafin = @FechaOrigen              
		--        ,@EmpleadoIni = @ClaveEmpleado              
		--        ,@EmpleadoFin = @ClaveEmpleado              
              
		if (@Vigente = 0)              
		BEGIN              
			set @ChecadaValida = 0;              
			set @MensajeValidacion = 'El Colaborador con clave: '+@ClaveEmpleado+' no esta vigente. Favor pasar a Recursos Humanos.';              
		END ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
		END              
	END              
	--=======VIGENCIA==========================              
	--=========================================              
              
	--=========================================              
	--=======HORARIO==========================              
	if(@ChecadaValida = 1)              
	BEGIN              
		if( (select top 1 valor from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ChecadaSinHorario') = '1' )              
		BEGIN              
			if(@Tipochecada = 'SH')              
			BEGIN              
				set @ChecadaValida = 1;              
				set @MensajeValidacion = '';              
			END              
			ELSE              
			BEGIN              
				set @ChecadaValida = 1;              
				set @MensajeValidacion = '';              
			END              
		END              
		ELSE              
		BEGIN              
			if(@Tipochecada = 'SH')              
			BEGIN              
				set @ChecadaValida = 0;              
				set @MensajeValidacion = 'El Colaborador con clave: '+@ClaveEmpleado+' no tiene un horario asignado. Favor pasar a Recursos Humanos.';              
			END              
			ELSE              
			BEGIN              
				set @ChecadaValida = 1;              
				set @MensajeValidacion = '';              
			END              
		END              
	END              
	--=======HORARIO==========================              
	--=========================================              
              
	--=========================================              
	--=======LECTOR===========================              
	if(@ChecadaValida = 1)              
	BEGIN              
		if not exists((select top 1 1 from Asistencia.tblLectoresEmpleados with(nolock) where IDEmpleado = @IDEmpleado))              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion = '';              
		END           
		ELSE              
		BEGIN              
			if not exists(select top 1 1 from Asistencia.tblLectoresEmpleados with(nolock) where IDEmpleado = @IDEmpleado and IDLector = @IDLector)              
			BEGIN     
				set @ChecadaValida = 0;              
				set @MensajeValidacion = 'El Colaborador con clave: '+@ClaveEmpleado+' no puede registrar asistencia en este lector. Favor pasar a Recursos Humanos o ir a una terminal asignada.';              
			END         
			ELSE              
			BEGIN              
				set @ChecadaValida = 1;              
				set @MensajeValidacion = '';              
			END              
		END              
	END              
              
	--=======LECTOR============================              
	--=========================================              
              
	--======REPETICION CHECADA=================              
	if(@ChecadaValida = 1)              
	BEGIN              
		if exists ( select top 1 1 from Asistencia.tblChecadas with(nolock) where IDEmpleado = @IDEmpleado and FechaOrigen = @FechaOrigen)              
		BEGIN            
			select top 1 @UltimaChecada = fecha               
			from Asistencia.tblChecadas  with(nolock)              
			where IDEmpleado = @IDEmpleado               
				and FechaOrigen = @FechaOrigen               
			Order by Fecha desc    
  
			--  select *       
			--from Asistencia.tblChecadas               
			--where IDEmpleado = @IDEmpleado               
			-- and FechaOrigen = @FechaOrigen               
			--Order by Fecha desc             
              
			select top 1 @TiempoEntreChecada = cast(valor as int) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoEntreChecadas'              
              
			--select DATEADD(MINUTE,@TiempoEntreChecada,@UltimaChecada) , @dtFechaZonaHoraria, @UltimaChecada, @TiempoEntreChecada          
			--select DATEADD(MINUTE,@TiempoEntreChecada,@UltimaChecada)
          
			if(DATEADD(MINUTE,@TiempoEntreChecada,@UltimaChecada) >= @dtFechaZonaHoraria)              
			BEGIN              
				set @EsRepetida = 1;              
				set @ChecadaValida = 1;              
				set @MensajeValidacion = 'CHECADA REPETIDA. Ultima checada registrada a las '+ cast(@UltimaChecada as varchar)+'.';                
			END              
			ELSE              
			BEGIN              
				set @ChecadaValida = 1;              
				set @MensajeValidacion ='';              
			END              
		END              
		ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion ='';              
		END              
	END              
--=======REPETICION CHECADA==========================              
--=========================================      
        
 --select * from RH.tblEmpleadosMaster  where ClaveEmpleado = 'OKU0086'        
 --select top 1 tc.Codigo from @dtEmpleados e       
 --  left join sat.tblCatTiposContrato tc      
 --   on tc.IDTipoContrato = e.IDTipoContrato           
 -- where e.IDEmpleado = @IDEmpleado       
  
--=========================================              
--=======CONTRATO==========================             
      
	if ((@ChecadaValida = 1) and (@EsRepetida = 0))	
	BEGIN        
		if ((select cast(valor as bit) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ValidarContratos') = 1)              
		BEGIN           
			print 'valida contrato'         
			if(isnull((select top 1 tc.Codigo 
						from @dtEmpleados e       
							left join sat.tblCatTiposContrato tc with(nolock)      
							on tc.IDTipoContrato = e.IDTipoContrato           
						where e.IDEmpleado = @IDEmpleado ),'') <> '01')              
			BEGIN           
				print 'contrato tiempo'      
				if exists (select top 1 1 from @dtEmpleados where IDEmpleado = @IDEmpleado and @FechaOrigen Between FechaIniContrato and FechaFinContrato)              
				BEGIN          
					print 'contrato si'          
					set @ChecadaValida = 1;              
					set @MensajeValidacion ='';              
				END              
				ELSE              
				BEGIN           
					print 'contrato NO'          
					set @ChecadaValida = 0;              
					set @MensajeValidacion ='El Colaborador con clave: '+@ClaveEmpleado+' no tiene Contrato Vigente. Favor Pasar por Recursos Humanos.';              
				END       
			END ELSE              
			BEGIN        
				set @ChecadaValida = 1;              
				set @MensajeValidacion ='';              
			END              
		END              
		ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion ='';              
		END       
	END      
--=======CONTRATO==========================              
--=========================================              
              
--=========================================              
--=======INCIDENCIA==========================              
	if ((@ChecadaValida = 1)  and (@EsRepetida = 0))
	BEGIN              
		if exists(              
			select top 1 1                
			from Asistencia.tblIncidenciaEmpleado IE with(nolock)              
				Inner join Asistencia.tblCatIncidencias I with(nolock)              
					on IE.IDIncidencia = I.IDIncidencia              
			WHERE IE.IDEmpleado = @IDEmpleado              
				and IE.Fecha = @FechaOrigen              
				and I.PermiteChecar = 0        
				and ((I.Autorizar = 1 and IE.Autorizado = 1) OR (I.Autorizar = 0)))              
		BEGIN              
			select top 1 @Incidencia = I.Descripcion              
			from Asistencia.tblIncidenciaEmpleado IE with(nolock)              
				Inner join Asistencia.tblCatIncidencias I with(nolock)              
					on IE.IDIncidencia = I.IDIncidencia              
			WHERE IE.IDEmpleado = @IDEmpleado              
				and IE.Fecha = @FechaOrigen              
				and I.PermiteChecar = 0              
				and ((I.Autorizar = 1 and IE.Autorizado = 1) OR (I.Autorizar = 0))        
          
             
			set @ChecadaValida = 0;              
			set @MensajeValidacion ='TIENE UNA INCIDENCIA DE '+ UPPER(@Incidencia)+'. Favor verificar con Recursos Humanos.';          
              
		END              
		ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion ='';              
		END              
	END              
--=======INCIDENCIA==========================    
          
--=========================================          
   -- select * from Asistencia.tblCatTiposChecadas        
--=========================================              
--=======TOLERANCIA CHECADA==========================   
           
	if ((@ChecadaValida = 1)  and (@EsRepetida = 0))             
	BEGIN              
		if( @Tipochecada in ('ET') )              
		BEGIN          
        
			DECLARE @EntradaHorario DATETIME,        
				@CodigoHorario Varchar(50)        
          
			select top 1 @EntradaHorario = h.HoraEntrada --convert(varchar,h.HoraEntrada,108)        
					, @CodigoHorario = h.Codigo               
			from Asistencia.tblHorariosEmpleados HE  with(nolock)             
				Inner join Asistencia.tblCatHorarios H  with(nolock)             
					on HE.IDHorario = H.IDHorario              
			WHERE HE.IDEmpleado = @IDEmpleado              
				and HE.Fecha = @FechaOrigen      
	
			--select [Asistencia].[fnTimeDiffWithDatetimes]((cast(@FechaOrigen as datetime) + cast(@EntradaHorario as datetime)),@dtFechaZonaHoraria)
			--, @dtFechaZonaHoraria
         
			if(@CodigoHorario = '06:30-14:30')        
			BEGIN        
				if(( [Asistencia].[fnTimeDiffWithDatetimes]((cast(@FechaOrigen as datetime) + cast(@EntradaHorario as datetime)),@dtFechaZonaHoraria)> cast('00:14:59.000' as Time)))        
				BEGIN       
					set @ChecadaValida = 0;              
					set @MensajeValidacion ='TIEMPO PARA CHECAR EXCEDIDO. Favor verificar con Recursos Humanos.';           
				END        
			END        
			ELSE        
			BEGIN        
				if(([Asistencia].[fnTimeDiffWithDatetimes]((cast(@FechaOrigen as datetime) + cast(@EntradaHorario as datetime)),@dtFechaZonaHoraria)> cast('00:04:59.000' as Time)))        
				BEGIN        
					set @ChecadaValida = 0;              
					set @MensajeValidacion ='TIEMPO PARA CHECAR EXCEDIDO. Favor verificar con Recursos Humanos.';           
				END        
			END             
		END              
		ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion ='';              
		END              
	END              
--=======INCIDENCIA==========================              
--=========================================          
            
	select  @outChecadaValida		= @ChecadaValida       
			,@outMensajeValidacion	= @MensajeValidacion
			,@outEsRepetida			= @EsRepetida      
              
RETURN              
              
END
GO
