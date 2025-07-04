USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias TIEMPO EXTRA de los colaboradores en función de sus checadas,
					  Horarios.
** Autor			: Jose Rafael Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2022-09-21
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-10-11			Jose Roman			[BugFix]:Se agrega corrección para tiempos extra de Horario Nocturno DS.
												 Detectaba mal el dia del horario en el caso de nocturnos.
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spCoreGenerarIncidenciaTiempoExtra](
	 @dtConfig as [App].[dtConfiguracionesGenerales] READONLY 
	,@dtEmpleados [RH].[dtEmpleados] READONLY
	,@dtVigenciaEmpleados [App].[dtFechasVigenciaEmpleado] READONLY
	,@dtChecadas [Asistencia].[dtChecadas] READONLY
	,@dtIncidenciasEmpleados [Asistencia].[dtIncidenciaEmpleado] READONLY
	,@dtHorariosEmpleados [Asistencia].[dtHorariosEmpleados] READONLY
	,@IDUsuario int
)
AS
BEGIN
	DECLARE @TiempoExtraJornadaMinima time, 
            @TiempoExtraAE time,
            @TiempoExtraDS time;
	
	select top 1 @TiempoExtraJornadaMinima	= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraJornadaMinima' 
    select top 1 @TiempoExtraAE				= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraAE' 
    select top 1 @TiempoExtraDS				= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraDS' 
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	
	
	BEGIN--TIEMPO EXTRA ANTES DE ENTRADA   ----------------------------------------  
		INSERT INTO Asistencia.tblIncidenciaEmpleado(
			IDEmpleado  
			,IDIncidencia  
			,Fecha  
			,TiempoSugerido  
			,TiempoAutorizado  
			,CreadoPorIDUsuario  
			,Autorizado  
			,AutorizadoPor  
			,FechaHoraAutorizacion  
			,FechaHoraCreacion
			,HorarioAD  
			,IDHorario
			,Entrada
			,Salida

		)
		Select e.IDEmpleado
			,'EX' as IDIncidencia
			,tve.Fecha as Fecha 
			,case when min(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) then Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
				else '00:00:00.000'
				END as TiempoSugerido
			,case when min(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) then Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
				else '00:00:00.000'
				END as TiempoAutorizado
			,@IDUsuario as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuario else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
			,'AE' as HorarioAD
			,HE.IDHorario
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
		from @dtVigenciaEmpleados tve
			inner join @dtEmpleados e 
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'EX'
			left join @dtIncidenciasEmpleados ie 
				on ie.Fecha = tve.Fecha  
				  and ie.IDEmpleado = e.IDEmpleado  
				  and ie.IDIncidencia = 'EX'
				  and IE.HorarioAD = 'AE'
			left join @dtChecadas c
				on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado
				and c.IDTipoChecada not in ('EC','SC')        
		where tve.Vigente = 1
		   and IE.IDIncidencia is null
		   and c.IDChecada is not null
		   and e.RequiereChecar = 1
		   and e.PagarTiempoExtra = 1
		GROUP BY e.IDEmpleado
		   ,tve.Fecha
		   ,h.HoraEntrada
		   ,I.Autorizar
		   ,h.HoraEntrada
		   ,H.TiempoTotal
		   ,HE.IDHorario
		Having min(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
			and Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoExtraJornadaMinima as time)
			and Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))) > cast(@TiempoExtraAE as time)
	END--TIEMPO EXTRA ANTES DE ENTRADA   ----------------------------------------  

	
	BEGIN--TIEMPO EXTRA DESPUES DE SALIDA   ----------------------------------------  
		INSERT INTO Asistencia.tblIncidenciaEmpleado(
			IDEmpleado  
			,IDIncidencia  
			,Fecha  
			,TiempoSugerido  
			,TiempoAutorizado  
			,CreadoPorIDUsuario  
			,Autorizado  
			,AutorizadoPor  
			,FechaHoraAutorizacion  
			,FechaHoraCreacion
			,HorarioAD  
			,IDHorario
			,Entrada
			,Salida
			   )
		Select e.IDEmpleado
			,'EX' as IDIncidencia
			,tve.Fecha as Fecha 
			, case when MAX(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)) then  Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha))
				END
			as TiempoSugerido
			,case when MAX(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)) then  Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha))
				END as TiempoAutorizado
			,@IDUsuario as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuario else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
			--,MAX(c.Fecha) as Salida
			,'DS' as HorarioAD
			,HE.IDHorario
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
		from @dtVigenciaEmpleados tve
			inner join @dtEmpleados e 
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'EX'
				left join @dtIncidenciasEmpleados ie 
					on ie.Fecha = tve.Fecha  
					  and ie.IDEmpleado = e.IDEmpleado  
					  and ie.IDIncidencia = 'EX'
					  and IE.HorarioAD = 'DS'
				left join @dtChecadas c
					on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado
					and c.IDTipoChecada not in ('EC','SC')        
			 where tve.Vigente = 1
				   and IE.IDIncidencia is null
				   and c.IDChecada is not null
				   and e.RequiereChecar = 1
				   and e.PagarTiempoExtra = 1
			GROUP BY e.IDEmpleado
				   ,tve.Fecha
				   ,h.HoraSalida
				   ,I.Autorizar
				   ,h.HoraEntrada
				   ,H.TiempoTotal
				   ,HE.IDHorario
			Having MAX(c.Fecha) > (cast( CASE WHEN H.HoraEntrada < H.HoraSalida THEN cast(tve.Fecha as date) ELSE DATEADD(DAY,1,cast(tve.Fecha as date)) END as datetime) + cast( h.HoraSalida as datetime))
				and Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoExtraJornadaMinima as time)
				and Asistencia.fnTimeDiffWithDatetimes((cast( CASE WHEN H.HoraEntrada < H.HoraSalida THEN cast(tve.Fecha as date) ELSE DATEADD(DAY,1,cast(tve.Fecha as date)) END as datetime) + cast( h.HoraSalida as datetime)),max(c.Fecha)) > cast(@TiempoExtraDS as time)
	END--TIEMPO EXTRA DESPUES DE SALIDA   ----------------------------------------  
	

END
GO
