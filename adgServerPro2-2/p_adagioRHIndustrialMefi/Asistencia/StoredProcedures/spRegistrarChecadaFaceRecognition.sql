USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [Asistencia].[spRegistrarChecadaFaceRecognition]
(      
	@IDLector int,      
	@ClaveEmpleado varchar(20),  
	@FechaHora Datetime     
)      
AS      
BEGIN      
    SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;
	DECLARE 
		@dtUTC DATETIME = getdate(),      
		@dtLectorZonaHoraria Varchar(100),      
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
		@Comida bit = 0,
		@TiempoEntreChecadas int ,
		@EsRepetida bit= 0 ,
		@dtEmpleados [RH].[dtEmpleados],
		@IDEmpleado int
	;

	select @IDUsuario = cast(Valor as int)
	from  App.tblConfiguracionesGenerales with (nolock)
	where [IDConfiguracion] ='IDUsuarioAdmin'
   
	select @IDClienteLector = IDCliente, @EsComedor = isnull(EsComedor,0), @Comida = isnull(Comida,0)
	from Asistencia.tblLectores with (nolock)
	where IDLector = @IDLector

	select top 1 @TiempoEntreChecadas = cast(valor as int) from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas' 
	--select @EsComedor as EsComedor , @TiempoEntreChecadas as tiempoEntreChecadas, cast(@TiempoEntreChecadas as time)

	select @IDEmpleado = IDEmpleado
	from RH.tblEmpleados with (nolock)
	where ClaveEmpleado = @ClaveEmpleado

	exec Asistencia.spBKLectoresZK @IDLector = @IDLector,@IDEmpleado = @IDEmpleado,@Checada = @FechaHora,@FechaHora = @dtUTC
             
	if(isnull(@IDEmpleado,0) <> 0 and exists(select top 1 1 from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado))    
	BEGIN   
		select  @FechaOrigen = t.FechaOrigen,      
				@TipoChecada = t.TipoChecada      
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@FechaHora) t      
		
		IF(@Comida = 1)
		BEGIN
			insert into Comedor.tblComidasConsumidas(
			IDEmpleado
			,Fecha
			,IDLector
			)      
			select @IDEmpleado
			,@FechaHora as Fecha      
			,@IDLector      
				
			 RETURN 0;
		END
		     

		if(@EsComedor = 0)
		BEGIN
			--select @IDEmpleado,@FechaOrigen,@TipoChecada,@IDLector, @dtFechaZonaHoraria      
		
			--exec Asistencia.spValidarChecada      
			--	@IDEmpleado = @IDEmpleado,    
			--	@dtEmpleados = @dtEmpleados,  
			--	@FechaOrigen = @FechaOrigen,      
			--	@Tipochecada = @TipoChecada,      
			--	@IDLector = @IDLector,      
			--	@dtFechaZonaHoraria = @dtFechaZonaHoraria,      
			--	@outChecadaValida = @Valida output,      
			--	@outMensajeValidacion = @Mensaje output,
			--	@outEsRepetida = @EsRepetida output            
      
			--select @Valida, @Mensaje  
  
			if not exists( select top 1 1 from Asistencia.tblChecadas with (nolock) where IDEmpleado = @IDEmpleado and Fecha = @FechaHora )  
			BEGIN  
				insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,FechaReg, FechaOriginal,Comentario)      
				select @FechaHora as Fecha      
				,@FechaOrigen      
				,@IDLector      
				,@IDEmpleado      
				,@TipoChecada         
				,@dtUTC      
				,@FechaHora
				,case when @Valida = 0 then @Mensaje else null end

				set @IDChecada = @@IDENTITY      
			END  

			if (@Valida = 0)
			BEGIN
				EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,@Mensaje      
			END;
			--if(@Valida = 1)      
			--BEGIN      
			--END      
			--ELSE      
			--BEGIN      
			--	EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,@Mensaje      
			--END 
		
		END
		ELSE
		BEGIN
			if not exists( select top 1 1 from Asistencia.tblChecadas with (nolock) where IDEmpleado = @IDEmpleado and FechaOrigen = cast(@FechaOrigen as date) and IDTipoChecada in ('EC') )  
			BEGIN  
				insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,FechaReg, FechaOriginal,Comentario)      
				select @FechaHora as Fecha      
				,@FechaOrigen      
				,@IDLector      
				,@IDEmpleado      
				,'EC'         
				,@dtUTC      
				,@FechaHora
				,null

				set @IDChecada = @@IDENTITY      
			END 
			ELSE
			BEGIN
				Declare @FechaHoraEC Datetime
				select @FechaHoraEC = min(Fecha) from Asistencia.tblChecadas with (nolock) where IDEmpleado = @IDEmpleado and FechaOrigen = cast(@FechaOrigen as date) and IDTipoChecada in ('EC')
				if(DATEADD(MINUTE,@TiempoEntreChecadas,@FechaHoraEC) <= @FechaHora)
				BEGIN
					insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,FechaReg, FechaOriginal,Comentario)      
					select @FechaHora as Fecha      
						,@FechaOrigen      
						,@IDLector      
						,@IDEmpleado      
						,'SC'         
						,@dtUTC      
						,@FechaHora
						,null
				END
				ELSE
				BEGIN
					EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'Checada de Comida Repetida'     
				END
			END 
		END
	END  
	ELSE  
	BEGIN  
		EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'Empleado no existe.' 
	END    
END
GO
