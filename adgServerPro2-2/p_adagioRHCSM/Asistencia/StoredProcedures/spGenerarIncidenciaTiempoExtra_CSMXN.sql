USE [p_adagioRHCSM]
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
***************************************************************************************************/
CREATE   PROCEDURE [Asistencia].[spGenerarIncidenciaTiempoExtra_CSMXN](
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

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	DECLARE @TiempoExtraJornadaMinima time, 
            @TiempoExtraAE time,
            @TiempoExtraDS time,
			@TiempoExtraJornadaMinimaSabado time,
			@IDUsuarioAdmin int;
	
	select top 1 @TiempoExtraJornadaMinima	= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraJornadaMinima' 
    select top 1 @TiempoExtraAE				= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraAE' 
    select top 1 @TiempoExtraDS				= cast(valor as time) from @dtConfig where IDConfiguracion = 'TiempoExtraDS' 
	select top 1 @TiempoExtraJornadaMinimaSabado =	cast('05:00:00' as time)  

	if(@IDUsuario is null)
	BEGIN    
		select top 1 @IDUsuarioAdmin = valor from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'IDUsuarioAdmin' 
	END ELSE
	BEGIN
		set @IDUsuarioAdmin = @IDUsuario
	END

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	
	
	BEGIN--TIEMPO EXTRA EN SABADOS   ----------------------------------------  
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
			,case when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time))
						) as time )
				end 
			as TiempoSugerido
			,case when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(MIN(c.Fecha), MAX(c.Fecha)) as time))
						) as time )
				end 
			as TiempoAutorizado
			,@IDUsuarioAdmin as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
			--,MAX(c.Fecha) as Salida
            --,DATENAME(DW, MIN(c.Fecha) )
            --,DATEPART(DW, MIN(c.Fecha) )
			,'SB' as HorarioAD
            ,MAX(he.IDHorario)
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
		from @dtVigenciaEmpleados tve
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado			
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'EX'
                inner join @dtHorariosEmpleados HE
				 on HE.IDEmpleado = TVE.IDEmpleado
				left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
					on ie.Fecha = tve.Fecha  
					  and ie.IDEmpleado = e.IDEmpleado  
					  and ie.IDIncidencia = 'EX'
					  and IE.HorarioAD = 'SB'
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
				   ,I.Autorizar
			Having DATENAME(DW, MIN(c.Fecha) ) = 'Sábado'
				 and  Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoExtraJornadaMinimaSabado as time)
	END--TIEMPO EXTRA EN SABADOS   ----------------------------------------  


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
			,case when min(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) then 
					case when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time))
						) as time )
				end 

			else '00:00:00'
				END as TiempoSugerido
			,case when min(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) then
				 case 
					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(min(cast (c.Fecha as datetime)) ,cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as time))
						) as time )
				 end 

			else '00:00:00'
			END as [TiempoAutorizado]
			,@IDUsuarioAdmin as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
			,'AE' as HorarioAD
			,HE.IDHorario
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
		from @dtVigenciaEmpleados tve
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'EX'
			left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
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
            and cast (MAX(c.Fecha) as date) < cast (GETDATE() as date)
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
			, case when MAX(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)) then 

			case 
					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time))
						) as time )
				 end
			   else '00:00:00'
			END
			as TiempoSugerido
			,case when MAX(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)) then 

			case 
					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)) between 25 and  39 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,30,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))) as time))
						)

					when  datepart(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)) between 39 and  59 then 

						dateadd(
								hour,
									--diferencia en horas = un int =1 
									(datediff(HOUR,0,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))
									,
									--diferencia en minutos = 00:30:00.0000000
									(cast (dateadd(minute,60,(datediff(minute,(cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
									cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)))) as time))
						)

					

					else  cast (dateadd(hour,datepart(hour,cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time)),
						datediff(minute, cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time), cast (Asistencia.fnTimeDiffWithDatetimes(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime),max(c.Fecha)) as time))
						) as time )
				 end
			   else '00:00:00'
			END as TiempoAutorizado
			,@IDUsuarioAdmin as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
			--,MAX(c.Fecha) as Salida
			,'DS' as HorarioAD
			,HE.IDHorario
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
		from @dtVigenciaEmpleados tve
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'EX'
				left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
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
			Having MAX(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
				and Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoExtraJornadaMinima as time)
				and Asistencia.fnTimeDiffWithDatetimes((cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)),max(c.Fecha)) > cast(@TiempoExtraDS as time)
                and cast (MAX(c.Fecha) as date) < cast (GETDATE() as date)
	END--TIEMPO EXTRA DESPUES DE SALIDA   ----------------------------------------

END
GO
