USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE STPS.spBuscarEventosCapacitacion
(
	@IDProgramacionCursoCapacitacion int 
	,@FechaHoraInicial datetime
	,@FechaHoraFinal datetime
	,@IDUsuario int
)
AS
BEGIN
	DECLARE
	@dtEventos [STPS].[dtEventoCalendarioCapacitacion]  
  ,@Fechas [App].[dtFechas]  
	
	 if object_id('tempdb..#TempSesiones') is not null drop table #TempSesiones; 

	 create table #TempSesiones(
		IDProgramacionCursoCapacitacion int
		,IDCursoCapacitacion int
		,Curso Varchar(150)
		,Color Varchar(20)
		,IDSesion int
		,IDSalaCapacitacion int
		,Sala Varchar(150)
		,FechaHoraInicial Datetime
		,FechaHoraFinal Datetime
	)
	
	insert into #TempSesiones
	Exec STPS.spBuscarSesionesCursosCapacitacion
	@IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion,
	@IDSesion = 0,
	@FechaInicio = @FechaHoraInicial,
	@FechaFin =  @FechaHoraFinal,
	@IDUsuario = @IDUsuario

	insert into @dtEventos(id,IDProgramacionCursoCapacitacion,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor,Sala) 
	Select IDSesion,IDProgramacionCursoCapacitacion,Curso,0,FechaHoraInicial, FechaHoraFinal, null,Color,null,null,null,Sala
	from #TempSesiones

	select 
	[id] 
	,[IDProgramacionCursoCapacitacion] 
	,[title]
	,[allDay] 
	,[start] 
	,[end] 
	,[url] 
	,[color] 
	,[backgroundColor] 
	,[borderColor] 
	,[textColor] 
	,[Sala] 
	from @dtEventos
END
GO
