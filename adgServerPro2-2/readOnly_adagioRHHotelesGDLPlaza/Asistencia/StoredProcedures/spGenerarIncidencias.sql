USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias de los colaboradores en función de sus checadas, descansos y ausentismos.
** Autor			: Jose Rafael Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-11-22			Aneudy Abreu		Se agrega la validación de la configuración para generar o no 
										las incidencias, esto podrá variar por cliente y se pueda modificar
										desde el catálogo de ausentismos.
2022-10-10			Yesenia Leonel		Se agrega validacion para los días Festivos laborados, ya que el 08-10-2022 es festivo sólo para la sucursal de Guadalajara
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spGenerarIncidencias](
	@FechaIni DATE = null, 
	@FechaFin DATE =  null, 
	@EmpleadoIni Varchar(20) = '0',                
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',      
	@IDUsuario int = null
)
AS
BEGIN

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;
	--DECLARE @FechaIni DATE  ; -- dateadd(day,-7,cast(GETDATE() as date))
	--DECLARE @FechaFin DATE  ;--cast(GETDATE() as date),  

	DECLARE @dtFechas app.dtFechas,  
            @dtEmpleados [RH].[dtEmpleados],
            @IDUsuarioAdmin int, 
            @DiasGeneraIncidencia int,
            @ToleranciaFalta time, 
            @ToleranciaRetardo time, 
            @TiempoExtraJornadaMinima time, 
            @TiempoExtraAE time,
            @TiempoExtraDS time,
			@GeneraFaltasSinAhorario bit,

			@GenerarIncidencias_DF  bit,
			@GenerarIncidencias_DL  bit,
			@GenerarIncidencias_EX  bit,
			@GenerarIncidencias_F   bit,
			@GenerarIncidencias_NC  bit,
			@GenerarIncidencias_PD  bit,
			@GenerarIncidencias_R   bit,

			@AjustarJornadaMinHorarioFL   bit,
			@AjustarJornadaMinHorarioPD   bit,
			@AjustarJornadaMinHorarioDL   bit,

			@FestivoLaboradoJornadaMinima time,
			@TiempoPrimaDominical  time,
			@TiempoDescansoLaborado  time;

			
   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);
               
    select top 1 @ToleranciaFalta			= cast(valor as time) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ToleranciaFalta' 
    select top 1 @ToleranciaRetardo			= cast(valor as time) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ToleranciaRetardo' 
    select top 1 @TiempoExtraJornadaMinima	= cast(valor as time) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoExtraJornadaMinima' 
    select top 1 @TiempoExtraAE				= cast(valor as time) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoExtraAE' 
    select top 1 @TiempoExtraDS				= cast(valor as time) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoExtraDS' 
    select top 1 @GeneraFaltasSinAhorario	= cast(isnull(valor,0) as bit) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'GeneraFaltasSinAhorario' 

	select top 1 @GenerarIncidencias_DF = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'DF'
	select top 1 @GenerarIncidencias_DL = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'DL'
	select top 1 @GenerarIncidencias_EX = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'EX'
	select top 1 @GenerarIncidencias_F  = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'F '
	select top 1 @GenerarIncidencias_NC = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'NC'
	select top 1 @GenerarIncidencias_PD = isnull(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'PD'
	select top 1 @GenerarIncidencias_R  = ISNULL(GenerarIncidencias,0) from Asistencia.tblCatIncidencias with(nolock) where IDIncidencia = 'R '
	
    select top 1 @AjustarJornadaMinHorarioFL	= cast(isnull(valor,0) as bit) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'AjustarJornadaMinHorarioFL' 
    select top 1 @AjustarJornadaMinHorarioPD	= cast(isnull(valor,0) as bit) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'AjustarJornadaMinHorarioPD' 
    select top 1 @AjustarJornadaMinHorarioDL	= cast(isnull(valor,0) as bit) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'AjustarJornadaMinHorarioDL' 
	
    select top 1 @TiempoPrimaDominical = cast(valor as time)			from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoPrimaDominical' 
    select top 1 @FestivoLaboradoJornadaMinima = cast(valor as time)	from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'FestivoLaboradoJornadaMinima' 
    select top 1 @TiempoDescansoLaborado = cast(valor as time)			from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'TiempoDescansoLaborado' 


	if(@IDUsuario is null)
	BEGIN    
		select top 1 @IDUsuarioAdmin = valor from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'IDUsuarioAdmin' 
	END ELSE
	BEGIN
		set @IDUsuarioAdmin = @IDUsuario
	END

	select top 1 @DiasGeneraIncidencia = valor from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'DiasGeneraChecadas' 

	if(@FechaIni is null and @FechaFin is null)
	BEGIN
		select @FechaIni = dateadd(day,-@DiasGeneraIncidencia,cast(GETDATE() as date)),
			  @FechaFin = getdate()
	END

---- Inicio AsistenciaConfig
--     ,('TiempoPrimaDominical', '00:00:00.000','Time', 'Tiempo para aplicar Prima Dominical.',4)
--     ,('TiempoExtraJornadaMinima', '05:00:00.000','Time', 'Tiempo de Jornada para aplicar Tiempo Extra.',4)
--     ,('TiempoExtraAE', '00:30:00.000','Time', 'Tiempo para aplicar Tiempo Extra antes de Horario Entrada.',4)
--     ,('TiempoExtraDS', '00:30:00.000','Time', 'Tiempo para aplicar Tiempo Extra despues de Horario Salida.',4)
--     ,('ToleranciaRetardo', '00:10:00.000','Time', 'Tiempo Tolerancia para Generar Retardo.',4)
--     ,('ToleranciaFalta', '04:00:00.000','Time', 'Tiempo Tolerancia para Generar Falta.',4)
--     ,('DiasGeneraChecadas', '10','int', 'Cantidad dias para revisar checadas',4)
---- Fin AsistenciaConfig

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias

	insert into @dtEmpleados    
	Exec [RH].[spBuscarEmpleadosMaster] 
			@FechaIni	= @FechaIni  
			,@FechaFin	= @FechaFin
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin 
			,@IDUsuario		= @IDUsuarioAdmin 

	insert into @dtFechas  
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin  

		select @OldJSON = a.JSON from (Select @FechaIni as FechaIni, @FechaFin as FechaFin, EmpleadoIni = @EmpleadoIni, EmpleadoFin = @EmpleadoFin, IDUsuario = @IDUsuarioAdmin ) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	
	
		EXEC [Auditoria].[spIAuditoria] @IDUsuarioAdmin,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spGenerarIncidencias]','GENERAR INCIDENCIAS','',@OldJSON




	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
  
	create Table #tempVigenciaEmpleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  
  
	insert into #tempVigenciaEmpleados  
	Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1  

	delete  #tempVigenciaEmpleados where Vigente = 0


	/*---------------------Espacio para validar que el 08-10-2022 es festivo solo para las sucursales de Vallarta--------------------------*/


			if object_id('tempdb..#tempVigenciaEmpleadosFestivos') is not null drop table #tempVigenciaEmpleadosFestivos

		create Table #tempVigenciaEmpleadosFestivos (  
			IDEmpleado int null,  
			Fecha Date null,  
			Vigente bit null  
		) 

		insert into #tempVigenciaEmpleadosFestivos
		select ve.*
		from #tempVigenciaEmpleados ve

		delete ve 
		from #tempVigenciaEmpleadosFestivos ve
			inner join rh.tblSucursalEmpleado se
				on se.IDEmpleado = ve.IDEmpleado
		where (se.IDSucursal  in (1,2) and se.FechaFin >= ve.Fecha) and day(ve.Fecha) = 8 and month(ve.fecha) = 10 and day(ve.Fecha) = 12 and month(ve.fecha) = 12


	/*--------------------FIN de Espacio para validar que el 08-10-2022 es festivo solo para las sucursales de Vallarta-----------------------*/

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;    

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join #tempVigenciaEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1
	where c.IDTipoChecada not in ('EC','SC')

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join #tempVigenciaEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1

	select ie.*
	into #tempHorarios
	from Asistencia.tblHorariosEmpleados ie with (nolock)
		join #tempVigenciaEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1


	IF (@GenerarIncidencias_R = 1)
	BEGIN--RETARDO----------------------------------------  

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
				 ,@IDUsuarioAdmin as CreadoPorIDUsuario
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
				 ,case when isnull(I.Autorizar,0) = 1 THEN getdate() else null end as FechaHoraAutorizacion
				 ,getdate() as FechaHoraCreacion
				 ,HE.IDHorario
				 ,MIN(c.Fecha) 
				 ,MAX(c.Fecha) 
				 --,MIN(c.Fecha) checada
				 --,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as f
		from #tempVigenciaEmpleados tve
			inner join @dtEmpleados e
				on tve.IDEmpleado = e.IDEmpleado
			inner join #tempHorarios HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'R'
			left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
				on ie.Fecha = tve.Fecha  
				  and ie.IDEmpleado = e.IDEmpleado  
				  and ie.IDIncidencia = 'R'
		   left join #tempChecadas c
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
	END--RETARDO----------------------------------------  

	IF (@GenerarIncidencias_DF = 1)
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
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						--,MIN(c.Fecha) checada
						--,H.HoraEntrada
				from #tempVigenciaEmpleadosFestivos tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DF'
					inner join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
					left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'DF'
					left join #tempHorarios HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
					left join #tempChecadas c
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
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						--,MIN(c.Fecha) checada
						--,H.HoraEntrada
				from #tempVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DF'
					inner join Asistencia.TblCatDiasFestivos DF with(nolock)
						on DF.Fecha = tve.Fecha and df.Autorizado = 1
					left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'DF'
					left join #tempChecadas c
						on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado  
						and c.IDTipoChecada not in ('EC','SC')   
					left join #tempHorarios HE
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

	IF (@GenerarIncidencias_PD = 1)
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
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
						--,MIN(c.Fecha) checadaIni
						--,MAX(c.Fecha) checadafin
						--,H.HoraEntrada
				from #tempVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'PD'
					left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
						on ie.Fecha = tve.Fecha  
							and ie.IDEmpleado = e.IDEmpleado  
							and ie.IDIncidencia = 'PD'
					left join #tempChecadas c
						on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado
						and c.IDTipoChecada not in ('EC','SC')   
					left join #tempHorarios HE
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
					,@IDUsuarioAdmin as CreadoPorIDUsuario
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
					,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
					,getdate() as FechaHoraCreacion
					,HE.IDHorario
					,MIN(c.Fecha) 
					,MAX(c.Fecha)
					--,MIN(c.Fecha) checadaIni
					--,MAX(c.Fecha) checadafin
					--,H.HoraEntrada
			from #tempVigenciaEmpleados tve
				inner join RH.tblEmpleadosMaster e with(nolock)
					on tve.IDEmpleado = e.IDEmpleado
				inner join #tempCatIncidencias I
					on I.IDIncidencia = 'PD'
				left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
					on ie.Fecha = tve.Fecha  
						and ie.IDEmpleado = e.IDEmpleado  
						and ie.IDIncidencia = 'PD'
				left join #tempChecadas c
					on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado   
					and c.IDTipoChecada not in ('EC','SC')     
				left join #tempHorarios HE
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

	IF (@GenerarIncidencias_EX = 1)
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
		from #tempVigenciaEmpleados tve
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado
			inner join #tempHorarios HE
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
			left join #tempChecadas c
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

	IF (@GenerarIncidencias_EX = 1)
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
		from #tempVigenciaEmpleados tve
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado
			inner join #tempHorarios HE
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
				left join #tempChecadas c
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
		END--TIEMPO EXTRA DESPUES DE SALIDA   ----------------------------------------  

		IF (@GenerarIncidencias_DL = 1)
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
						,@IDUsuarioAdmin as CreadoPorIDUsuario
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
						,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
						,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
						,getdate() as FechaHoraCreacion
						,HE.IDHorario
						,MIN(c.Fecha) 
						,MAX(c.Fecha) 
					--,MIN(c.Fecha) checada
					--,H.HoraEntrada
				from #tempVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DL'
					inner join #tempAusentismosIncidencias ieD with(nolock) 
						on ieD.Fecha = tve.Fecha  
							and ieD.IDEmpleado = e.IDEmpleado  
							and ieD.IDIncidencia = 'D'
					left join Asistencia.tblIncidenciaEmpleado ieDL with(nolock)  
						on ieDL.Fecha = tve.Fecha  
							and ieDL.IDEmpleado = e.IDEmpleado  
							and ieDL.IDIncidencia = 'DL'
					left join #tempHorarios HE
						on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
					left join #tempChecadas c 
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
					,@IDUsuarioAdmin as CreadoPorIDUsuario
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
					,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
					,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
					,getdate() as FechaHoraCreacion
					,HE.IDHorario
					,MIN(c.Fecha) 
					,MAX(c.Fecha) 
					--,MIN(c.Fecha) checada
					--,H.HoraEntrada
				from #tempVigenciaEmpleados tve
					inner join RH.tblEmpleadosMaster e with(nolock)
						on tve.IDEmpleado = e.IDEmpleado
					inner join #tempCatIncidencias I
						on I.IDIncidencia = 'DL'
					inner join #tempAusentismosIncidencias ieD 
						on ieD.Fecha = tve.Fecha  
							and ieD.IDEmpleado = e.IDEmpleado  
							and ieD.IDIncidencia = 'D'
					left join Asistencia.tblIncidenciaEmpleado ieDL with(nolock)  
						on ieDL.Fecha = tve.Fecha  
							and ieDL.IDEmpleado = e.IDEmpleado  
							and ieDL.IDIncidencia = 'DL'
					left join #tempChecadas c
						on c.FechaOrigen = tve.Fecha
							and c.IDEmpleado = e.IDEmpleado   
							and c.IDTipoChecada not in ('EC','SC')   
					left join #tempHorarios HE
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

	IF (@GenerarIncidencias_F = 1)
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
		from #tempVigenciaEmpleados VE
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
			,@IDUsuarioAdmin as CreadoPorIDUsuario
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
			,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
			,case when isnull(I.Autorizar,0) = 0 then getdate() else null end as FechaHoraAutorizacion
			,getdate() as FechaHoraCreacion
			,HE.IDHorario
			,MIN(c.Fecha) 
			,MAX(c.Fecha) 
			--,MIN(c.Fecha) checada
			--,H.HoraEntrada
		from #tempVigenciaEmpleados tve
			inner join #tempEmpleadoAusentismo EA
				on EA.Fecha = tve.Fecha
					and ea.tieneAusentismo = 0
					and tve.IDEmpleado = ea.IDEmpleado
			inner join RH.tblEmpleadosMaster e with(nolock)
				on tve.IDEmpleado = e.IDEmpleado
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'F'
			left join Asistencia.TblCatDiasFestivos DF with(nolock)
				on DF.Fecha = tve.Fecha and df.Autorizado = 1
			left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
				on ie.Fecha = tve.Fecha  
					and ie.IDEmpleado = e.IDEmpleado  
					and ie.IDIncidencia = 'F'
			left join #tempChecadas c
				on c.FechaOrigen = tve.Fecha
					and c.IDEmpleado = e.IDEmpleado  
					and c.IDTipoChecada not in ('EC','SC')     
			left join #tempHorarios HE
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

	BEGIN-- BORRAR FALTAS INCORRECTAS -----------------------------------------------
		exec [Asistencia].[EliminarFaltasIncorrectas] @dtFechas = @dtFechas, @dtEmpleados= @dtEmpleados, @IDUsuario = @IDUsuarioAdmin
	END-- BORRAR FALTAS INCORRECTAS -----------------------------------------------
END
GO
