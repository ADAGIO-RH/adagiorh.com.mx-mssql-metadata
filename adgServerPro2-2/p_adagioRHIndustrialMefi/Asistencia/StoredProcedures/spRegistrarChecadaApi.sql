USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [Asistencia].[spRegistrarChecadaApi]
(      
	@ClaveEmpleado varchar(20),  
	@FechaHora Datetime ,    
	@IDLector int = 0
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
		@IDEmpleado int,	  
		@EsComedor bit = 0,
		@Comida bit = 0,
		@TiempoEntreChecadas int ,
		@EsRepetida bit= 0 ,
		@dtEmpleados [RH].[dtEmpleados]
		--@IDLector int
	;
	 declare @TempClaveEmpleado table (
			ClaveEmpleado varchar(20)
		);


	select @IDUsuario = cast(Valor as int)
	from  App.tblConfiguracionesGenerales with (nolock)
	where [IDConfiguracion] ='IDUsuarioAdmin'

  
   IF(isnull(@IDLector,0) = 0)
   BEGIN
		select top 1 @IDLector = IDLector
		from Asistencia.tblLectores with (nolock)
		where IDTipoLector = 'WebApi'

		select @IDEmpleado = IDEmpleado
		from RH.tblEmpleados with (nolock)
		where ClaveEmpleado = @ClaveEmpleado
   END
   ELSE 
   BEGIN
		select @IDClienteLector = IDCliente, @EsComedor = isnull(EsComedor,0), @Comida = isnull(Comida,0)
		from Asistencia.tblLectores with (nolock)
		where IDLector = @IDLector

		
		insert @TempClaveEmpleado
		exec [RH].[spGenerarClaveEmpleado]
			 @IDCliente = @IDClienteLector,  
			 @MAXClaveID  = @ClaveEmpleado,  
			 @IDUsuario = @IDUsuario

		select top 1 @ClaveEmpleado = ClaveEmpleado
		from @TempClaveEmpleado

		select @IDEmpleado = IDEmpleado
		from RH.tblEmpleados with (nolock)
		where ClaveEmpleado = @ClaveEmpleado

   END

	if (isnull(@IDEmpleado, 0) = 0)
	begin
		set @Mensaje = FORMATMESSAGE('La clave [%s] no fue encontrada o no pertenece al cliente.', @ClaveEmpleado);
		raiserror(@Mensaje, 16, 1)
		return
	end

	select top 1 @TiempoEntreChecadas = cast(valor as int) from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas' 


	exec Asistencia.spBKLectoresZK @IDLector = @IDLector,@IDEmpleado = @IDEmpleado,@Checada = @FechaHora,@FechaHora = @dtUTC
             
	if(isnull(@IDEmpleado,0) <> 0 and exists(select top 1 1 from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado))    
	BEGIN   
		select  @FechaOrigen = t.FechaOrigen,      
				@TipoChecada = t.TipoChecada      
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@FechaHora) t      

		if not exists( select top 1 1 from Asistencia.tblChecadas with (nolock) where IDEmpleado = @IDEmpleado and Fecha = @FechaHora )  
		BEGIN  
			insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,FechaReg, FechaOriginal,Comentario)      
			select @FechaHora as Fecha      
				,@FechaOrigen      
				,case when @IDLector = 0 then null else @IDLector end      
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
	END  
	ELSE  
	BEGIN  
		EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'Empleado no existe.' 
	END    
END
GO
