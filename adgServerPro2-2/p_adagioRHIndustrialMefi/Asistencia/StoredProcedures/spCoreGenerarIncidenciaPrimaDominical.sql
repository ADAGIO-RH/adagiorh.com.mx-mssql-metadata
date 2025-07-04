USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias PRIMA DOMINICAL de los colaboradores en función de sus checadas,
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
CREATE PROCEDURE Asistencia.spCoreGenerarIncidenciaPrimaDominical(
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
	DECLARE @AjustarJornadaMinHorarioPD   bit,
			@TiempoPrimaDominical  time;
	
	 select top 1 @AjustarJornadaMinHorarioPD	= cast(isnull(valor,0) as bit) from @dtConfig  where IDConfiguracion = 'AjustarJornadaMinHorarioPD' 
	 select top 1 @TiempoPrimaDominical = cast(valor as time)			from @dtConfig where IDConfiguracion = 'TiempoPrimaDominical' 
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	
	BEGIN--PRIMA DOMINICAL ----------------------------------------  
		IF(@AjustarJornadaMinHorarioPD = 0)
		BEGIN -- AJUSTAR TIEMPO DE PRIMA DOMINICAL AL TIEMPO DE LA CONFIGURACION JORNADA MINIMA -----------------
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
						,IDHorario
						,Entrada
						,Salida
					   )
				Select e.IDEmpleado
						,'PD' as IDIncidencia
						,tve.Fecha as Fecha 
						,'00:00:00.000' as TiempoSugerido
						,'00:00:00.000' as TiempoAutorizado
						,@IDUsuario as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuario else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						--,MIN(c.Fecha) checadaIni
						--,MAX(c.Fecha) checadafin
						--,H.HoraEntrada
				from @dtVigenciaEmpleados tve
					inner join @dtEmpleados e 
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'PD'
					left join @dtIncidenciasEmpleados ie 
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'PD'
					left join @dtChecadas c
						on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado
						and c.IDTipoChecada not in ('EC','SC')   
					left join @dtHorariosEmpleados HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
				 where tve.Vigente = 1
					and datepart(weekday,tve.Fecha) = 1 -- DOMINGO
					and IE.IDIncidencia is null
					and c.IDChecada is not null
					and e.RequiereChecar = 1
					and e.PagarPrimaDominical = 1
				GROUP BY e.IDEmpleado
						,tve.Fecha
						,I.Autorizar
						,HE.IDHorario
				having  Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoPrimaDominical as time)
			END
		ELSE
		BEGIN -- AJUSTAR TIEMPO DE PRIMA DOMINICAL AL HORARIO DEL COLABORADOR -----------------
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
					,IDHorario
					,Entrada
					,Salida
					)
			Select e.IDEmpleado
					,'PD' as IDIncidencia
					,tve.Fecha as Fecha 
					,'00:00:00.000' as TiempoSugerido
					,'00:00:00.000' as TiempoAutorizado
					,@IDUsuario as CreadoPorIDUsuario
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuario else null end as AutorizadoPor
					,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
					,getdate() as FechaHoraCreacion
					,HE.IDHorario
					,MIN(c.Fecha) 
					,MAX(c.Fecha)
					--,MIN(c.Fecha) checadaIni
					--,MAX(c.Fecha) checadafin
					--,H.HoraEntrada
			from @dtVigenciaEmpleados tve
				inner join @dtEmpleados e 
					on tve.IDEmpleado = e.IDEmpleado
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'PD'
				left join @dtIncidenciasEmpleados ie 
					on ie.Fecha = tve.Fecha  
						and ie.IDEmpleado = e.IDEmpleado  
						and ie.IDIncidencia = 'PD'
				left join @dtChecadas c
					on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado   
					and c.IDTipoChecada not in ('EC','SC')     
				left join @dtHorariosEmpleados HE
					on HE.IDEmpleado = e.IDEmpleado and HE.Fecha = tve.Fecha
				left join Asistencia.tblCatHorarios H with(nolock)
					on HE.IDHorario = H.IDHorario
			where tve.Vigente = 1
					and datepart(weekday,tve.Fecha) = 1 -- DOMINGO
					and IE.IDIncidencia is null
					and c.IDChecada is not null
					and e.RequiereChecar = 1
					and e.PagarPrimaDominical = 1
					and HE.IDHorario is not null
			GROUP BY e.IDEmpleado
					,tve.Fecha
					,I.Autorizar
					, h.HoraSalida
					, h.JornadaLaboral
					,HE.IDHorario
			having 
				MAX(c.Fecha) >= (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
			AND	 Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) >= cast(H.JornadaLaboral as time)
		END
		
	END--PRIMA DOMINICAL ----------------------------------------  


END
GO
