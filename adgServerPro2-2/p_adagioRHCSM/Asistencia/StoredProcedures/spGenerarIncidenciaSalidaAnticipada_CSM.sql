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
CREATE   PROCEDURE [Asistencia].[spGenerarIncidenciaSalidaAnticipada_CSM](
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

	
	DECLARE @ToleranciaSalida time,
			@IDUsuarioAdmin int;

	select top 1 @ToleranciaSalida			= cast('00:01:00' as time)

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias with(nolock)



	if(@IDUsuario is null)
	BEGIN    
		select top 1 @IDUsuarioAdmin = valor from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'IDUsuarioAdmin' 
	END ELSE
	BEGIN
		set @IDUsuarioAdmin = @IDUsuario
	END
	
	BEGIN--SALIDA ANTICIPADA----------------------------------------  

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
				 ,'SA' as IDIncidencia
				 ,tve.Fecha as Fecha 
				 , '00:00:00.000'  as TiempoSugerido
				 , '00:00:00.000'  as TiempoAutorizado
				 ,@IDUsuarioAdmin as CreadoPorIDUsuario
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN 1 else 0 end as Autorizado
				 ,CASE WHEN isnull(I.Autorizar,0) = 0 THEN @IDUsuarioAdmin else null end as AutorizadoPor
				 ,case when isnull(I.Autorizar,0) = 1 THEN getdate() else null end as FechaHoraAutorizacion
				 ,getdate() as FechaHoraCreacion
				 ,HE.IDHorario
				 ,MIN(c.Fecha) 
				 ,MAX(c.Fecha) 
                 --,Asistencia.fnTimeDiffWithDatetimes(MAX(c.Fecha),(cast(tve.Fecha as datetime) + cast(h.HoraSalida as datetime)))
				 --,case when  CAST(max(c.Fecha) as date ) < cast(GETDATE() as date) then 1 else 0 end checada
                 --,cast(GETDATE() as date)
				 --,(cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraEntrada as datetime)) as f
		from @dtVigenciaEmpleados tve
			inner join @dtEmpleados e
				on tve.IDEmpleado = e.IDEmpleado
			inner join @dtHorariosEmpleados HE
				on HE.Fecha = tve.Fecha and HE.IDEmpleado = TVE.IDEmpleado
			inner join Asistencia.tblCatHorarios H with(nolock)
				on H.IDHorario = HE.IDHorario
			inner join #tempCatIncidencias I
				on I.IDIncidencia = 'SA'
			left join Asistencia.tblIncidenciaEmpleado ie with(nolock)  
				on ie.Fecha = tve.Fecha  
				  and ie.IDEmpleado = e.IDEmpleado  
				  and ie.IDIncidencia = 'SA'
		   left join @dtChecadas c
				on c.FechaOrigen = tve.Fecha and c.IDEmpleado = e.IDEmpleado  
				and c.IDTipoChecada not in ('EC','SC','ET')  
		where tve.Vigente = 1
			   and IE.IDIncidencia is null
			   and c.IDChecada is not null
			   and e.RequiereChecar = 1
               
		GROUP BY e.IDEmpleado
			   ,tve.Fecha
			   ,h.HoraSalida
			   ,I.Autorizar
			   ,h.HoraSalida
			   ,HE.IDHorario
		Having  MAX(c.Fecha) < (cast(cast(tve.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
			and Asistencia.fnTimeDiffWithDatetimes(MAX(c.Fecha),(cast(tve.Fecha as datetime) + cast(h.HoraSalida as datetime))) > cast( @ToleranciaSalida as time)
            and cast (MAX(c.Fecha) as date) < cast (GETDATE() as date)
	
    END--SALIDA ANTICIPADA----------------------------------------  


END
GO
