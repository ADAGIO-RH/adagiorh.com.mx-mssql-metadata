USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias DESCANSO LABORADO de los colaboradores en función de sus checadas,
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
CREATE PROCEDURE Asistencia.spCoreGenerarIncidenciaDescansoLaborado(
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
	DECLARE @AjustarJornadaMinHorarioDL   bit,
            @TiempoDescansoLaborado  time;
	
	   select top 1 @AjustarJornadaMinHorarioDL	= cast(isnull(valor,0) as bit) from @dtConfig where IDConfiguracion = 'AjustarJornadaMinHorarioDL'
	   select top 1 @TiempoDescansoLaborado = cast(valor as time)			from @dtConfig where IDConfiguracion = 'TiempoDescansoLaborado' 
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	

	BEGIN--DESCANSO LABORADO ---------------------------------------- 
		IF(@AjustarJornadaMinHorarioDL = 0)
		BEGIN -- AJUSTAR TIEMPO DE DESCANSO LABORADO AL TIEMPO DE LA CONFIGURACION JORNADA MINIMA -----------------
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
					,'DL' as IDIncidencia
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
				--,MIN(c.Fecha) checada
				--,H.HoraEntrada
			from @dtVigenciaEmpleados tve
				inner join @dtEmpleados e
					on tve.IDEmpleado = e.IDEmpleado
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'DL'
				inner join @dtIncidenciasEmpleados ieD 
					on ieD.Fecha = tve.Fecha  
						and ieD.IDEmpleado = e.IDEmpleado  
						and ieD.IDIncidencia = 'D'
				left join @dtIncidenciasEmpleados ieDL 
					on ieDL.Fecha = tve.Fecha  
						and ieDL.IDEmpleado = e.IDEmpleado  
						and ieDL.IDIncidencia = 'DL'
				left join @dtHorariosEmpleados HE
					on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
				left join @dtChecadas c 
					on c.FechaOrigen = tve.Fecha
						and c.IDEmpleado = e.IDEmpleado 
						and c.IDTipoChecada not in ('EC','SC')       
				left join Asistencia.TblCatDiasFestivos DF with(nolock)
					on DF.Fecha = tve.Fecha and df.Autorizado = 1
				where tve.Vigente = 1
				and ieDL.IDIncidencia is null
				and ieD.IDIncidencia is not null
				and c.IDChecada is not null
				and e.RequiereChecar = 1
				and e.PagarDescansoLaborado = 1
				and DF.IDDiaFestivo is null
			GROUP BY e.IDEmpleado
					,tve.Fecha
					,I.Autorizar
					,HE.IDHorario
			HAVING Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@TiempoDescansoLaborado as time)
		END
		ELSE
		BEGIN -- AJUSTAR TIEMPO DE DESCANSO LABORADO AL HORARIO DEL COLABORADOR -----------------
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
					,'DL' as IDIncidencia
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
					--,MIN(c.Fecha) checada
					--,H.HoraEntrada
				from @dtVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DL'
					inner join @dtIncidenciasEmpleados ieD 
						on ieD.Fecha = tve.Fecha  
							and ieD.IDEmpleado = e.IDEmpleado  
							and ieD.IDIncidencia = 'D'
					left join @dtIncidenciasEmpleados ieDL   
						on ieDL.Fecha = tve.Fecha  
							and ieDL.IDEmpleado = e.IDEmpleado  
							and ieDL.IDIncidencia = 'DL'
					left join @dtChecadas c
						on c.FechaOrigen = tve.Fecha
							and c.IDEmpleado = e.IDEmpleado   
							and c.IDTipoChecada not in ('EC','SC')   
					left join @dtHorariosEmpleados HE
						on HE.IDEmpleado = e.IDEmpleado
						and tve.Fecha = HE.Fecha
					left join Asistencia.tblCatHorarios H with(nolock)
						on H.IDHorario = HE.IDHorario  
					left join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
					where tve.Vigente = 1
					and ieDL.IDIncidencia is null
					and ieD.IDIncidencia is not null
					and c.IDChecada is not null
					and e.RequiereChecar = 1
					and e.PagarDescansoLaborado = 1
					and HE.IDHorario is not null
					and DF.IDDiaFestivo is null

				GROUP BY e.IDEmpleado
						,tve.Fecha
						,I.Autorizar
						, h.HoraSalida
						, h.JornadaLaboral
						,HE.IDHorario
				HAVING MAX(c.Fecha) >= (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
				AND	 Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) >= cast(H.JornadaLaboral as time)
		END
	END--DESCANSO LABORADO ---------------------------------------- 


END
GO
