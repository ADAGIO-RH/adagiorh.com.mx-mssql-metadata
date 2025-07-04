USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

      
/****************************************************************************************************       
** Descripción  : Buscar los eventos del calendario      
** Autor   : Aneudy Abreu      
** Email   : aneudy.abreu@adagio.com.mx      
** FechaCreacion : 2018-05-16      
** Paremetros  :  @IDEmpleado int      
      ,@FechaInicio date      
      ,@FechaFin date      
      ,@IDUsuario int      
            
** Notas: Tipos de eventos:       
    0 - No Vigente  
   
	1 - Incidencias      
	2 - Ausentismos      
	3 - Horarios      
	4 - Checadas  
	5 - Papeletas  

	6 - Festivos programados 
  
	exec [Asistencia].[spBuscarEventosCalendario] 1279,'2019-05-27','2019-07-08',1    
   
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd)	Autor				Comentario      
------------------- ------------------- ------------------------------------------------------------      
2019-05-15			Aneudy Abreu		Se agregaron eventos para los días que el colaborador no estuvo vigente.  
2024-06-11			Aneudy Abreu		Se agrega asignación de Idioma a la variable @IDIdioma
***************************************************************************************************/      
CREATE proc [Asistencia].[spBuscarEventosCalendario]--550,'2023-08-28','2023-10-09',5062    
(      
	@IDEmpleado int      
	,@FechaInicio date      
	,@FechaFin date      
	,@IDUsuario int      
) as      
      
	declare       
		@dtEventos [Asistencia].[dtEventoCalendario]  
		,@Fechas [App].[dtFechas]  
		,@dtEmpleados RH.dtEmpleados  
		,@CALENDARIO0001 bit = 0
        ,@IDIdioma VARCHAR(250)
	;      
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if exists(
        select top 1 1 
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes with (nolock)	
			join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0001')
	begin
		set @CALENDARIO0001 = 1
	end;

      
	insert @dtEmpleados(IDEmpleado)  
	values (@IDEmpleado)  
  
	insert into @Fechas(Fecha)  
	exec [App].[spListaFechas] @FechaIni = @FechaInicio, @FechaFin = @FechaFin  
  
	if object_id('tempdb..#TempIncidencias') is not null drop table #TempIncidencias;      
	if object_id('tempdb..#TempAusentismos') is not null drop table #TempAusentismos;      
	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;      
	if object_id('tempdb..#tempChecada') is not null drop table #tempChecada;      
	if object_id('tempdb..#tempDiasNoVigentes') is not null drop table #tempDiasNoVigentes;      
	if object_id('tempdb..#tempPapeletas') is not null drop table #tempPapeletas;      
      
	create table #TempIncidencias(      
		IDIncidenciaEmpleado int       
		,IDEmpleado int       
		,IDIncidencia varchar(10)      
		,Incidencia varchar(255)      
		,Fecha date      
		,TiempoSugerido time      
		,TiempoAutorizado time      
		,Comentario nvarchar(max)      
		,ComentarioTextoPlano nvarchar(max)      
		,CreadoPorIDUsuario int      
		,CreadoPorUsuario varchar(600)      
		,Autorizado bit      
		,AutorizadoPor int      
		,AutorizadoPorUsuario varchar(600)      
		,FechaHoraAutorizacion datetime      
		,FechaHoraCreacion datetime       
		,IDIncapacidadEmpleado int       
		,allDay Bit      
		,Color varchar(20)      
		,EsAusentismo bit  
	);      
	create table #TempAusentismos(      
		IDIncidenciaEmpleado int       
		,IDEmpleado int       
		,IDIncidencia varchar(10)      
		,Incidencia varchar(255)      
		,Fecha date      
		,TiempoSugerido time      
		,TiempoAutorizado time      
		,Comentario nvarchar(max)      
		,ComentarioTextoPlano nvarchar(max)      
		,CreadoPorIDUsuario int      
		,CreadoPorUsuario varchar(600)      
		,Autorizado bit      
		,AutorizadoPor int      
		,AutorizadoPorUsuario varchar(600)      
		,FechaHoraAutorizacion datetime      
		,FechaHoraCreacion datetime       
		,IDIncapacidadEmpleado int       
		,allDay Bit      
		,Color varchar(20)      
		,EsAusentismo bit  
	);     
	create table #tempHorarios(      
		IDHorarioEmpleado int      
		,IDEmpleado    int      
		,IDHorario     int      
		,CodigoHorario    varchar(100)      
		,Horario     varchar(255)      
		,HoraEntrada    time      
		,HoraSalida    time      
		,Fecha     datetime      
		,Dia      varchar(20)       
		,FechaHoraRegistro datetime      
	);    
	create table #tempChecada(      
		IDChecada int      
		,Fecha     datetime     
		,FechaOrigen     date     
		,IDLector     int      
		,Lector    varchar(100)      
		,IDEmpleado    int      
		,IDTipoChecada varchar(20)      
		,TipoChecada    varchar(100)      
		,IDUsuario    int      
		,Cuenta varchar(20)      
		,Comentario varchar(500)      
		,IDZonaHoraria int    
		,ZonaHoraria varchar(500)      
		,Automatica bit    
		,FechaReg     datetime     
	);     
	create table #tempDiasNoVigentes (  
		IDEmpleado int  
		,Fecha date  
		,Vigente bit  
	);  
	create table #tempPapeletas (  
		IDPapeleta int  
		,IDEmpleado int  
		,ClaveEmpleado varchar(20)  
		,NombreCompleto varchar(50)  
		,IDIncidencia varchar(20)  
		,Incidencia varchar(255) 
		,EsAusentismo bit 
		,FechaInicio date  
		,FechaFin  date  
		,TiempoAutorizado time  
		,TiempoSugerido   time  
		,Dias varchar(20)  
		,Duracion int  
		,IDClasificacionIncapacidad int  
		,ClasificacionIncapacidad varchar(255)  
		,IDTipoIncapacidad   int  
		,TipoIncapacidad   varchar(255)  
		,IDTipoLesion    int  
		,TipoLesion     varchar(255)  
		,IDTipoRiesgoIncapacidad int  
		,TipoRiesgoIncapacidad  varchar(255)  
		,Numero varchar(20)  
		,PagoSubsidioEmpresa   bit  
		,Permanente      bit  
		,DiasDescanso varchar(20)  
		,Fecha date  
		,Comentario     nvarchar(max)  
		,ComentarioTextoPlano nvarchar(max)  
		,Autorizado bit  
		,PapeletaAutorizada bit  
		,FechaHora datetime  
		,IDUsuario int  
		,IDIncidenciaEmpleado int
	);  
      
    insert into #TempAusentismos      
    exec [Asistencia].[spBuscarIncidenciasAusentismosEmpleadoFecha]      
		 @IDEmpleado	= @IDEmpleado       
		,@FechaInicio	= @FechaInicio           
		,@FechaFin		= @FechaFin       
		,@IDUsuario		= @IDUsuario       
		,@Tipo			= 1     

    insert into #TempIncidencias      
    exec [Asistencia].[spBuscarIncidenciasAusentismosEmpleadoFecha]      
		@IDEmpleado		= @IDEmpleado      
		,@FechaInicio	= @FechaInicio          
		,@FechaFin		= @FechaFin      
		,@IDUsuario		= @IDUsuario      
		,@Tipo			= 0    
		
    insert into #tempHorarios      
    exec [Asistencia].[spBuscarHorariosEmpleados]      
		 @IDEmpleado	= @IDEmpleado      
		,@FechaInicio   = @FechaInicio      
		,@FechaFin		= @FechaFin      
		,@IDUsuario		= @IDUsuario      
  
	insert into #tempChecada      
	exec [Asistencia].[spBuscarChecadasEmpleadoFechaCalendario]      
		@IDEmpleado		= @IDEmpleado      
		,@FechaInicio   = @FechaInicio      
		,@FechaFin		= @FechaFin      
		,@IDUsuario		= @IDUsuario      
  
	insert into #tempPapeletas      
	exec [Asistencia].[spBuscarPapeletas]      
		 @IDEmpleado	= @IDEmpleado      
		,@FechaInicio   = @FechaInicio      
		,@FechaFin		= @FechaFin      
		,@IDUsuario		= @IDUsuario   
		
  
	insert into #tempDiasNoVigentes(IDEmpleado,Fecha,Vigente)  
	exec RH.spBuscarListaFechasVigenciaEmpleado @dtEmpleados,@Fechas,@IDUsuario  
   
    insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)      
    select IDIncidenciaEmpleado,2,IDEmpleado,Incidencia + CASE WHEN isnull(Autorizado,0) = 1 THEN ' - AUT.' ELSE '' END,allDay,Fecha,Fecha,null, Color, null, null, null      
    from #TempAusentismos      
      
    insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)      
    select IDIncidenciaEmpleado,1,IDEmpleado,Incidencia + CASE WHEN isnull(Autorizado,0) = 1 THEN ' - AUT.' ELSE '' END,allDay,Fecha,Fecha,null, Color, null, null, null      
    from #TempIncidencias      
      
    insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)      
    select IDHorarioEmpleado,3,IDEmpleado,CodigoHorario,1,CAST(Fecha AS DATETIME) ,CAST(Fecha AS DATETIME),null,'#000e55',null,NULL,null from #tempHorarios      
    --select IDHorarioEmpleado,3,IDEmpleado,CodigoHorario,0,CAST(Fecha AS DATETIME) + CAST(HoraEntrada AS DATETIME),CAST(Fecha AS DATETIME) + CAST(HoraSalida AS DATETIME),null,'#000e55',null,NULL,null from #tempHorarios      
      
    insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)      
    select IDChecada,4,IDEmpleado,'Chd: '+isnull(IDTipoChecada,'SH')+'- '+format(Fecha, 'HH:mm' ) ,1,CAST(FechaOrigen AS DATETIME),CAST(FechaOrigen AS DATETIME),null,case when IDTipoChecada in ('EC','SC') THEN '#b2b1b5' else '#7b72b6' end,null,NULL,null from #tempChecada      
  
	insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor,data)      
    select IDPapeleta,5,IDEmpleado,'Papeleta: ['+IDIncidencia+']' + CASE WHEN isnull(Autorizado,0) = 1 THEN ' - AUT.' ELSE '' END,1,CAST(Fecha AS DATETIME),
    -- DATEADD(day, DATEDIFF(day, 0, FechaFin), '06:00:00'),
      CAST(FechaFin AS DATETIME)  ,
      null,'#388a8a',null,NULL,null,case when isnull(EsAusentismo,CAST(0 as bit)) = 1 then 'true' else 'false' end 
	from #tempPapeletas  

	if (@CALENDARIO0001 = 1)
	BEGIN
		insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor,data)      
		select IDDiaFestivo,6,@IDEmpleado,('[DF] '+coalesce(p.Codigo,'')+' - '+ coalesce(JSON_VALUE(DF.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,'')),1,CAST(Fecha AS DATETIME),CAST(Fecha AS DATETIME),null,'#000',null,NULL,null,null
		from Asistencia.TblCatDiasFestivos DF
			left join Sat.tblCatPaises p with(nolock)
			on DF.IDPais = p.IDPais
		WHERE Autorizado = 1 and Fecha between @FechaInicio and @FechaFin
	END;  

	insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)      
    select 0,0,IDEmpleado,'NO VIGENTE',1,Fecha,Fecha,null,'red',null,NULL,null from #tempDiasNoVigentes where isnull(Vigente,0) = 0  
    
	select       
		id      
		,TipoEvento      
		,IDEmpleado      
		,title      
		,allDay      
		,start      
		,[end]      
		,url      
		,color      
		,backgroundColor      
		,borderColor      
		,textColor 
		,[data]  
	from @dtEventos  
	order by TipoEvento asc
GO
