USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias COMEDOR de los colaboradores en función de sus checadas,
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
CREATE   PROCEDURE [Asistencia].[spGenerarIncidenciaComedor_ANS](
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
			@IDUsuarioAdmin int,
			@GenerarIncidencias_CM   bit
			;
	
	
	select top 1 @GenerarIncidencias_CM  = ISNULL(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'CM'
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
	if object_id('tempdb..#tempComidas') is not null drop table #tempComidas

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)

    select c.*
	INTO #tempComidas
	from Comedor.tblComidasConsumidas c with (nolock)
		join @dtVigenciaEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and cast(c.Fecha as date) = tempEmp.Fecha and tempEmp.Vigente = 1
	


	
		IF (@GenerarIncidencias_CM = 1)
	BEGIN--COMEDOR----------------------------------------  
		--- SEMANALES -----------------------------------

		--select 'COMIDA', @GenerarIncidencias_CM
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
				Select distinct e.IDEmpleado
						,'CM' as IDIncidencia
						,tve.Fecha as Fecha 
						,'00:00:00.000' as TiempoSugerido
						,'00:00:00.000' as TiempoAutorizado
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
						--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
						--,MIN(c.Fecha) checada
						--,H.HoraEntrada
				from @dtVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'CM'
					inner join #tempComidas c
						on cast(c.Fecha as date) = tve.Fecha and c.IDEmpleado = e.IDEmpleado 
					left join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
					left join @dtIncidenciasEmpleados descanso  
						on descanso.Fecha = tve.Fecha  
							and descanso.IDEmpleado = e.IDEmpleado  
							and descanso.IDIncidencia = 'D'
					left join @dtIncidenciasEmpleados ie 
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'CM'
							 
					left join @dtHorariosEmpleados HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
					left join Asistencia.tblCatHorarios h with(nolock)
						on he.IDHorario = h.IDHorario
				 where tve.Vigente = 1
					   and IE.IDIncidencia is null
					   and c.IDComidaConsumida is not null
					   and e.RequiereChecar = 1
					   and descanso.IDIncidenciaEmpleado is null
					   and df.IDDiaFestivo is null
					   and e.TipoNomina = 'SEMANAL'
					   and c.Fecha between (cast(cast(tve.Fecha as date) as datetime) + cast('05:00:00.000' /*h.HoraEntrada*/ as datetime)) and (cast(cast(tve.Fecha as date) as datetime) + cast( '13:29:00.000' as datetime))
				GROUP BY e.IDEmpleado
					   ,tve.Fecha
					   ,I.Autorizar
					   ,HE.IDHorario
					   --,c.Fecha
					   --,tve.Fecha
					   
				
			--- SEMANALES -----------------------------------
			--- CATORCENALES -----------------------------------
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
						,HorarioAD
				)
				Select distinct e.IDEmpleado
						,'CM' as IDIncidencia
						,tve.Fecha as Fecha 
						,'00:00:00.000' as TiempoSugerido
						,'00:00:00.000' as TiempoAutorizado
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						,'C' + cast(ROW_NUMBER()OVER(Partition by cast(C.fecha as date) order by c.fecha) as varchar(10)) HorarioAD
						--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime))
						--,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
						--,MIN(c.Fecha) checada
						--,H.HoraEntrada
				from @dtVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'CM'
					inner join #tempComidas c
						on cast(c.Fecha as date) = tve.Fecha and c.IDEmpleado = e.IDEmpleado 
					left join @dtIncidenciasEmpleados ie   
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'CM'
							 
					left join @dtHorariosEmpleados HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
					left join Asistencia.tblCatHorarios h with(nolock)
						on he.IDHorario = h.IDHorario

					
					     
				 where tve.Vigente = 1
					   and IE.IDIncidencia is null
					   and c.IDComidaConsumida is not null
					  -- and e.RequiereChecar = 1
					   and e.TipoNomina = 'CATORCENAL'
					   
				GROUP BY e.IDEmpleado
					   ,tve.Fecha
					   ,I.Autorizar
					   ,HE.IDHorario
					   ,c.Fecha
				
			--- CATORCENALES -----------------------------------

	END--COMEDOR----------------------------------------  


END
GO
