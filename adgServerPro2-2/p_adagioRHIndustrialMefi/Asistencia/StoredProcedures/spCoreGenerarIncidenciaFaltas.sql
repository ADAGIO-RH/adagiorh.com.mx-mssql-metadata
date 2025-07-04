USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias FALTAS de los colaboradores en función de sus checadas,
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
CREATE PROCEDURE Asistencia.spCoreGenerarIncidenciaFaltas(
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
	DECLARE   @ToleranciaFalta time,
            @GeneraFaltasSinAhorario bit;
	
	   select top 1 @ToleranciaFalta			= cast(valor as time) from @dtConfig where IDConfiguracion = 'ToleranciaFalta' 
	   select top 1 @GeneraFaltasSinAhorario	= cast(isnull(valor,0) as bit) from @dtConfig where IDConfiguracion = 'GeneraFaltasSinAhorario' 
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

	
	
	BEGIN--FALTAS POR NO AUSENTISMO --------------------------------------------------
		if object_id('tempdb..#tempEmpleadoAusentismo') is not null drop table #tempEmpleadoAusentismo

		select *
			,isnull((select top 1 1 
						from Asistencia.tblIncidenciaEmpleado ie with(nolock) 
							inner join #tempCatIncidencias i
							   on ie.IDIncidencia = i.IDIncidencia
						where i.EsAusentismo = 1 and ie.IDEmpleado = ve.IDEmpleado
							   and ie.Fecha = ve.Fecha),0) tieneAusentismo
		into #tempEmpleadoAusentismo
		from @dtVigenciaEmpleados VE
		where ve.Vigente = 1

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
			,'F' as IDIncidencia
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
			inner join #tempEmpleadoAusentismo EA
				on EA.Fecha = tve.Fecha
					and ea.tieneAusentismo = 0
					and tve.IDEmpleado = ea.IDEmpleado
			inner join @dtEmpleados e
				on tve.IDEmpleado = e.IDEmpleado
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'F'
			left join Asistencia.TblCatDiasFestivos DF with(nolock)
				on DF.Fecha = tve.Fecha and df.Autorizado = 1
			left join @dtIncidenciasEmpleados ie 
				on ie.Fecha = tve.Fecha  
					and ie.IDEmpleado = e.IDEmpleado  
					and ie.IDIncidencia = 'F'
			left join @dtChecadas c
				on c.FechaOrigen = tve.Fecha
					and c.IDEmpleado = e.IDEmpleado  
					and c.IDTipoChecada not in ('EC','SC')     
			left join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha
					and HE.IDEmpleado = tve.IDEmpleado 
			left join Asistencia.tblCatHorarios H with(nolock) 
				on H.IDHorario = HE.IDHorario
		where tve.Vigente = 1
			and IE.IDIncidencia is null
			and c.IDChecada is null
			and e.RequiereChecar = 1
			and DF.IDDiaFestivo is null
			and 1 = (case 
						when he.IDHorario is not null and h.HoraSalida <= h.HoraEntrada and  (cast(cast( dateadd(day,1,tve.Fecha) as date) as datetime) + cast( h.HoraSalida as datetime)) + cast(@ToleranciaFalta as datetime)  < getdate() THEN 1
						when he.IDHorario is not null and h.HoraSalida > h.HoraEntrada and (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime)) + cast(@ToleranciaFalta as datetime)  < getdate() THEN 1
						when he.IDHorario is null and tve.Fecha < cast(getdate() as date) and @GeneraFaltasSinAhorario = 1 then 1
						else 0 
					end)
		GROUP BY e.IDEmpleado
			   ,tve.Fecha
			   ,I.Autorizar
			   ,HE.IDHorario
	END--FALTAS POR NO AUSENTISMO--------------------------------------------------

END
GO
