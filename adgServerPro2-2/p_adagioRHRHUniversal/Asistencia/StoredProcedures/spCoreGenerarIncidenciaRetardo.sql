USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias RETARDO de los colaboradores en función de sus checadas,
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
CREATE PROCEDURE Asistencia.spCoreGenerarIncidenciaRetardo(
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
	DECLARE    @ToleranciaRetardo time;
	
	select top 1 @ToleranciaRetardo	= cast(valor as time) from @dtConfig where IDConfiguracion = 'ToleranciaRetardo' 

	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)


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
				 ,'R' as IDIncidencia
				 ,tve.Fecha as Fecha 
				 ,CASE WHEN  MIN(c.Fecha) > (cast(tve.Fecha as datetime) + cast(h.HoraEntrada as datetime)) then Asistencia.fnTimeDiffWithDatetimes((cast(tve.Fecha as datetime) + cast(h.HoraEntrada as datetime)),MIN(c.Fecha)) 
						ELSE '00:00:00.000' END as TiempoSugerido
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN CASE WHEN  MIN(c.Fecha) > (cast(tve.Fecha as datetime) + cast(h.HoraEntrada as datetime)) then  Asistencia.fnTimeDiffWithDatetimes((cast(tve.Fecha as datetime) + cast(h.HoraEntrada as datetime)),MIN(c.Fecha)) 
																					 else '00:00:00.000' END
						ELSE '00:00:00.000' END as TiempoAutorizado
				 ,@IDUsuario as CreadoPorIDUsuario
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuario else null end as AutorizadoPor
				 ,case when isnull(I.Autorizar,0) = 1 THEN getdate() else null end as FechaHoraAutorizacion
				 ,getdate() as FechaHoraCreacion
				 ,HE.IDHorario
				 ,MIN(c.Fecha) 
				 ,MAX(c.Fecha) 
				 --,MIN(c.Fecha) checada
				 --,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as f
		from @dtVigenciaEmpleados tve
			inner join @dtEmpleados e
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'R'
			left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
				on ie.Fecha = tve.Fecha  
				  and ie.IDEmpleado = e.IDEmpleado  
				  and ie.IDIncidencia = 'R'
		   left join @dtChecadas c
				on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado  
				and c.IDTipoChecada not in ('EC','SC')   
		where tve.Vigente = 1
			   and IE.IDIncidencia is null
			   and c.IDChecada is not null
			   and e.RequiereChecar = 1
		GROUP BY e.IDEmpleado
			   ,tve.Fecha
			   ,h.HoraEntrada
			   ,I.Autorizar
			   ,h.HoraEntrada
			   ,HE.IDHorario
		Having  MIN(c.Fecha) > (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
			and Asistencia.fnTimeDiffWithDatetimes((cast(tve.Fecha as datetime) + cast(h.HoraEntrada as datetime)),MIN(c.Fecha)) > cast(@ToleranciaRetardo as time)


END
GO
