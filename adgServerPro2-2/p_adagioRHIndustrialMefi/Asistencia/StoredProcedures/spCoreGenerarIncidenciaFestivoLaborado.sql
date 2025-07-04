USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias FESTIVO LABORADO de los colaboradores en función de sus checadas,
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
CREATE PROCEDURE Asistencia.spCoreGenerarIncidenciaFestivoLaborado(
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
	DECLARE @AjustarJornadaMinHorarioFL   bit,
		@FestivoLaboradoJornadaMinima time;
	
	select top 1 @AjustarJornadaMinHorarioFL	= cast(isnull(valor,0) as bit) from @dtConfig where IDConfiguracion = 'AjustarJornadaMinHorarioFL' 
	select top 1 @FestivoLaboradoJornadaMinima = cast(valor as time)	from @dtConfig where IDConfiguracion = 'FestivoLaboradoJornadaMinima' 
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	BEGIN--FESTIVO LABORADO----------------------------------------  
		IF(@AjustarJornadaMinHorarioFL = 0)
		BEGIN-- AJUSTAR TIEMPO DE FESTIVO LABORADO AL TIEMPO DE LA CONFIGURACION JORNADA MINIMA -----------------
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
						,'DF' as IDIncidencia
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
					inner join Nomina.tblCatTipoNomina TN with(nolock)
						on E.IDTipoNomina = TN.IDTipoNomina
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DF'
					inner join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
						and DF.IDPais = TN.IDPais
					left join @dtIncidenciasEmpleados ie   
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'DF'
					left join @dtHorariosEmpleados HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
					left join @dtChecadas c
						on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado 
					and c.IDTipoChecada not in ('EC','SC')       
				 where tve.Vigente = 1
					   and IE.IDIncidencia is null
					   and c.IDChecada is not null
					   and e.RequiereChecar = 1
					   and e.PagarFestivoLaborado = 1
				GROUP BY e.IDEmpleado
					   ,tve.Fecha
					   ,I.Autorizar
					   ,HE.IDHorario
				HAVING
					 Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) > cast(@FestivoLaboradoJornadaMinima as time)
		END
		ELSE
		BEGIN -- AJUSTAR TIEMPO DE FESTIVO LABORADO AL HORARIO DEL COLABORADOR -----------------
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
						,'DF' as IDIncidencia
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
					inner join Nomina.tblCatTipoNomina TN with(nolock)
						on E.IDTipoNomina = TN.IDTipoNomina
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DF'
					inner join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
						and DF.IDPais = TN.IDPais
					left join @dtIncidenciasEmpleados ie   
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'DF'
					left join @dtChecadas c
						on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado  
						and c.IDTipoChecada not in ('EC','SC')   
					left join @dtHorariosEmpleados HE
						on e.IDEmpleado = he.IDEmpleado and tve.Fecha = HE.Fecha
					left join Asistencia.tblCatHorarios H with(nolock)
						on H.IDHorario = HE.IDHorario 
				 where tve.Vigente = 1
					   and IE.IDIncidencia is null
					   and c.IDChecada is not null
					   and e.RequiereChecar = 1
					   and e.PagarFestivoLaborado = 1
					   and he.IDHorario is not null
					    
				GROUP BY e.IDEmpleado
					   ,tve.Fecha
					   ,I.Autorizar
					    , h.HoraSalida
					   , h.JornadaLaboral
					   ,HE.IDHorario
				HAVING MAX(c.Fecha) >= (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
				AND	 Asistencia.fnTimeDiffWithDatetimes(min(c.Fecha),max(c.Fecha)) >= cast(H.JornadaLaboral as time)
		END
	END--FESTIVO LABORADO----------------------------------------  


END
GO
