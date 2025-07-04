USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBuscarMensajeEmpleados]   -- @IDEmpleado =0  ,@IDLector = 0  
(      
	@IDMensajeEmpleado int = 0,      
	@IDEmpleado int = 0,      
	@Fecha Date = null,    
	@IDLector int = 0      
)      
AS      
BEGIN     
    
	declare 
		@fechaLector Date,    
		@dtUTC Datetime = GETUTCDATE(),    
		@dtLectorZonaHoraria varchar(100),    
		@IDZonaHoraria int,    
		@dtFechaZonaHoraria datetime   
	;

	if object_id('tempdb..#TempMensajes') is not null drop table #TempMensajes

	create table #TempMensajes(	
		[IDMensajeEmpleado] int ,	
		IDEmpleado int,
		FechaInicio date,
		FechaFin date,
		Mensaje varchar(max) COLLATE database_default,
	);
    
	select 
		@dtLectorZonaHoraria = isnull(z.Name,'UTC')     
		,@IDZonaHoraria = isnull(z.Id ,(select top 1 id from tzdb.Zones where Name = 'UTC'))    
	from Asistencia.tblLectores l with(nolock)
		left join Tzdb.Zones z on l.IDZonaHoraria = z.Id    
	where l.IDLector = @IDLector    
    
	if (@Fecha is null)    
	BEGIN    
		set  @dtFechaZonaHoraria = Tzdb.UtcToLocal(@dtUTC,@dtLectorZonaHoraria)    
	END    
     
	IF(ISNULL(@IDMensajeEmpleado,0) <> 0)      
	BEGIN      
		insert into #TempMensajes(IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje)
		Select IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje      
		from Asistencia.tblMensajesEmpleados with (nolock)      
		Where IDMensajeEmpleado = @IDMensajeEmpleado      
	END ELSE IF (isnull(@IDEmpleado,0) <> 0 AND @Fecha is not null)      
	BEGIN    
		insert into #TempMensajes(IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje)
		Select IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje      
		from Asistencia.tblMensajesEmpleados with (nolock)          
		where IDEmpleado = @IDEmpleado and isnull(@Fecha, cast(@dtFechaZonaHoraria as date)) Between FechaInicio and FechaFin    
       
	END ELSE IF (isnull(@IDEmpleado,0) <> 0 AND @Fecha is null)      
	BEGIN    
		insert into #TempMensajes(IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje)
		Select IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje      
		from Asistencia.tblMensajesEmpleados with (nolock)      
		where IDEmpleado = @IDEmpleado    
		--and @dtFechaZonaHoraria between FechaInicio and FechaFin    
	END   
 
	select IDMensajeEmpleado,IDEmpleado,FechaInicio,FechaFin,Mensaje 
	from #TempMensajes
END
GO
