USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spBuscarPapeletaVacacionesAvilabXN]--1,14,1 
(
	 @IDPapeleta	int 
	,@IDEmpleado	int = 0
	,@IDUsuario		int
) as

  SET NOCOUNT ON;
     IF 1=0 BEGIN
     SET FMTONLY OFF
  END


	/*DECLARE  
		@IDIdioma varchar(225),
		@msgDescripcion varchar(500)
	;*/
 
	DECLARE 
         @IDIdioma varchar(225)
        ,@msgDescripcion varchar(500)
        ,@Festivos [App].[dtFechasFull]
        ,@Fechas [App].[dtFechasFull]
        ,@SumarDiasDescanso int = 0
        ,@SumarDiasFestivos int = 0
        ,@FechaInicio       date
        ,@FechaFin          date 
        ,@DiasDescanso              varchar(20)
        ,@i int = 1
        ,@IDIncidencia varchar(10)
		,@IDTipoPrestacion int 
		,@fechafinprestacion date = getdate()
		,@AniosAntiguedad float = 0  
		,@FechaAntiguedad date  
		,@IDHorario int 

    ;

		 set @IDEmpleado= (select IDEmpleado from Asistencia.tblPapeletas where IDPapeleta=@IDPapeleta)

	select @IDTipoPrestacion = pe.IDTipoPrestacion 
		  ,@FechaAntiguedad	= isnull(e.FechaAntiguedad,getdate())
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN [RH].[tblPrestacionesEmpleado] pe with (nolock) ON pe.IDEmpleado = e.IDEmpleado   
			and pe.FechaIni<= @fechafinprestacion and pe.FechaFin >= @fechafinprestacion       
	where e.IDEmpleado = @IDEmpleado

	SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,getdate()) / 365.2425  
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 THEN 1 ELSE CAST(CEILING(@AniosAntiguedad) as int) END

	select
		@FechaInicio = Fecha,
		@DiasDescanso = DiasDescanso,
		@Fechafin = dateadd(day,Duracion,Fecha),
		@IDIncidencia = IDIncidencia
	from Asistencia.tblPapeletas P
		where (p.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
			and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)

	select @IDHorario = HE.IDHorario 
	from Asistencia.tblHorariosEmpleados HE
	where HE.IDEmpleado = @IDEmpleado and HE.Fecha = @FechaInicio 
    
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
       
	 if object_id('tempdb..#TempLista2') is not null drop table #TempLista;

	Declare @tblVacaciones [Asistencia].[dtSaldosDeVacaciones]

	--declare @tblTempVacaciones as table(
	--				Anio int
	--				,FechaIni date
	--				,FechaFin date
	--				,Dias int
	--				,DiasTomados int
	--				,DiasVencidos int
	--				,DiasDisponibles decimal(18,2)
	--				,prestacion varchar(max)
	--				,fechainiP date
	--				,fechafinP date
	--)

	declare
		@FechaFinVaca date
	;

	set @FechaFinVaca  = (select FechaFin from Asistencia.tblPapeletas where IDPapeleta = @IDpapeleta)

	if object_id('tempdb..#tempCTEDos') is not null drop table #tempCTEDos;  
	select e.*
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(0 as float)  as DiasPorAniosPrestacion
	INTO #tempCTEDos  
	from rh.tblEmpleados e
		where IDEmpleado = @idempleado



	insert into @tblVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = null,@FechaBaja= @fechafinvaca,@IDUsuario= @idusuario

	update cte 
			set 
				DiasDisponibles=   ISNULL((Select SUM(isnull(DiasDisponibles,0)) FROM @tblVacaciones) ,0)
		FROM #tempCTEDos cte
			 where IDEmpleado = @idempleado 

		--dd=0

IF(@IDIncidencia = 'V')
BEGIN
create table #TempLista2(   
        Fecha date   
        ,ID varchar(10)   
) 
insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
        @FechaIni = @Fechainicio
       , @FechaFin = @FechaFin
    ---------------------------Se invirtio el orden de buscar fechas. 1.Descansos 2.Festivos   ----------------------------------------------- JULIO CASTILLO
    -- insert @Festivos(Fecha)
    -- select f.Fecha
    -- from Asistencia.TblCatDiasFestivos df
    --  join @Fechas f on df.Fecha = F.Fecha
    -- where df.Autorizado = 1 and (DATEPART(DW,df.Fecha)) NOT IN (SELECT cast(item as int) as item from [App].[Split](@DiasDescanso,',') )
    -- select @SumarDiasFestivos = COUNT(*)
    -- from @Festivos
    -- set @i = 1;
    -- while (@i <= @SumarDiasFestivos)
    -- begin
    --  set @FechaFin = dateadd(day,1,@FechaFin)
    --  --if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
    --  if not (DATEPART(DW,@FechaFin) in (
    --        SELECT cast(item as int) as item
    --        from [App].[Split](@DiasDescanso,',') ) )
    --  begin
    --      set @i = @i + 1;
    --  end;
    -- end;
    select @SumarDiasDescanso=count(*)
    from @Fechas f
       join (
          SELECT cast(item as int) as item
          from [App].[Split](@DiasDescanso,',') ) as dd on f.DiaSemana = cast(dd.item as int) 
    set @i = 1;
    while (@i <= @SumarDiasDescanso)
    begin
        set @FechaFin = dateadd(day,1,@FechaFin)
        --if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
        if not (DATEPART(DW,@FechaFin) in (
              SELECT cast(item as int) as item
              from [App].[Split](@DiasDescanso,',') ) )
        begin
            set @i = @i + 1;
        end;
    end;
    delete from @Fechas;
    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
        @FechaIni = @Fechainicio
       , @FechaFin = @FechaFin
    -- select @SumarDiasDescanso=count(*)
    -- from @Fechas f
    --    join (
    --    SELECT cast(item as int) as item
    --    from [App].[Split](@DiasDescanso,',') ) as dd on f.DiaSemana = cast(dd.item as int) 
    -- set @i = 1;
    -- while (@i <= @SumarDiasDescanso)
    -- begin
    --  set @FechaFin = dateadd(day,1,@FechaFin)
    --  --if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
    --  if not (DATEPART(DW,@FechaFin) in (
    --        SELECT cast(item as int) as item
    --        from [App].[Split](@DiasDescanso,',') ) )
    --  begin
    --      set @i = @i + 1;
    --  end;
    -- end;
    insert @Festivos(Fecha)
    select f.Fecha
    from Asistencia.TblCatDiasFestivos df
        join @Fechas f on df.Fecha = F.Fecha
    where df.Autorizado = 1 and (DATEPART(DW,df.Fecha)) NOT IN (SELECT cast(item as int) as item from [App].[Split](@DiasDescanso,',') )
    select @SumarDiasFestivos = COUNT(*)
    from @Festivos
    set @i = 1;
    while (@i <= @SumarDiasFestivos)
    begin
        set @FechaFin = dateadd(day,1,@FechaFin)
        --if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
        if not (DATEPART(DW,@FechaFin) in (
              SELECT cast(item as int) as item
              from [App].[Split](@DiasDescanso,',') ) )
        begin
            set @i = @i + 1;
        end;
    end;
    delete from @Fechas;
    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
        @FechaIni = @Fechainicio
       , @FechaFin = @FechaFin
   
    delete fecha
    from @Fechas fecha
        join @Festivos f on fecha.Fecha = f.Fecha
    insert into #TempLista2(Fecha, ID)   
    select Fecha   
      ,ID = case when DiaSemana in (SELECT cast(item as int) from [App].[Split](@DiasDescanso,',') ) then 'D' else 'V' end   
    from @Fechas
   
    select @FechaFin=max(Fecha)   
    from @Fechas   
    where DiaSemana not in  (SELECT cast(item as int) as item   
                            from [App].[Split](@DiasDescanso,',') )
END

	--select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
	set @msgDescripcion = 
			case 
				when @IDIdioma = 'esmx' then 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '
				when @IDIdioma = 'enus' then 'THROUGH THE FOLLOWING CONDUCT I AM ALLOWED TO REQUEST PERMISSION TO: '
		else 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: ' end


 
		
		
	if object_id('tempdb..#temporal1') is not null
	DROP TABLE #temporal1;

	select 
			 ie.IDEmpleado as IDEmpleado
			,count(*) as qty
			,STRING_AGG(ie.Fecha,',') AS DiaDeDescanso
	into #temporal1
	from Asistencia.tblIncidenciaEmpleado ie
	   LEFT JOIN Asistencia.tblPapeletas PAPE
		on pape.idempleado = ie.IDEmpleado
	where (ie.Fecha between pape.fecha  and DATEADD(DAY,pape.Duracion,PAPE.Fecha))   and ie.IDIncidencia IN ( 'D','DF')
	group by ie.IDEmpleado

	
	select 
		 p.IDPapeleta
		,p.IDEmpleado
		,em.ClaveEmpleado
		,em.regpatronal as Registro_Patronal
		,em.NOMBRECOMPLETO as NombreCompleto
		,em.Departamento
		, case when em.IDRegPatronal=1 then 'LA. DORIA LILIA BARBA GUTIÉRREZ'
			    when em.IDRegPatronal in (2,3) and em.idtiponomina=17 then 'LAE. ALEJANDRA GONZÁLEZ JIMÉNEZ'
			   when em.IDRegPatronal=3 and em.idtiponomina=16 then 'IA. MIRIAM ARACELI LÓPEZ BARBA'
			else '' end as Persona_RH
		,em.Sucursal
		,em.Puesto
		--,Descripcion = 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '+COALESCE(i.Descripcion,'')
		,Descripcion = 
			@msgDescripcion+JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', @IDIdioma, 'Descripcion'))
		,p.IDIncidencia
		,i.Descripcion as Incidencia
		,isnull(i.EsAusentismo,cast(0 as bit)) as EsAusentismo
		,(ctedos.DiasDisponibles ) as DiasDisponibles
		,FechaInicio = case 
							when i.IDIncidencia in ('V','I') then isnull(p.Fecha,getdate()) 
							when i.EsAusentismo = 0 then isnull(p.Fecha,getdate()) 
							else  isnull(p.FechaInicio,getdate())  end
		,FechaFin    = case
                            when i.IDIncidencia in ('V') then isnull(@FechaFin,GETDATE())
                            when i.IDIncidencia in ('I') then DATEADD(DAY,p.Duracion,p.Fecha)
                            when i.EsAusentismo = 0 then isnull(p.Fecha,getdate())
                            else  isnull(p.FechaFin,getdate()) end
		,case
                            when i.IDIncidencia in ('V') then DATEADD(DAY,1,isnull(@FechaFin,GETDATE()))
                            when i.IDIncidencia in ('I') then DATEADD(DAY,p.Duracion,p.Fecha)
                            when i.EsAusentismo = 0 then isnull(p.Fecha,getdate())
                            else  dateadd(day,1, isnull(p.FechaFin,getdate())) end as RegresoATrabajo
		,cast(p.TiempoAutorizado as varchar(5)) as TiempoAutorizado
		,cast(p.TiempoSugerido	 as varchar(5)) as TiempoSugerido
		,isnull(p.Dias,0) as Dias
		,case when i.IDIncidencia in ('V') then  isnull(p.Duracion,0)
		else DATEDIFF(day, p.FechaInicio,p.FechaFin) +1 end
		as Duracion
		,isnull(p.IDClasificacionIncapacidad,0)				as IDClasificacionIncapacidad
		,isnull(clasificacion.Nombre,'SIN CLASIFICACIÓN')	as ClasificacionIncapacidad
		,isnull(p.IDTipoIncapacidad,0)						as IDTipoIncapacidad
		,isnull(tipoInca.Descripcion,'SIN TIPO')			as TipoIncapacidad
		,isnull(p.IDTipoLesion,0)							as IDTipoLesion
		,isnull(lesiones.Descripcion,'SIN TIPO DE LESIÓN')	as TipoLesion
		,isnull(p.IDTipoRiesgoIncapacidad,0)				as IDTipoRiesgoIncapacidad
		,isnull(riesgos.Nombre,'SIN RIESGO')				as TipoRiesgoIncapacidad
		,isnull(p.Numero,0) as Numero
		,isnull(p.PagoSubsidioEmpresa,cast(0 as bit))	as PagoSubsidioEmpresa 
		,isnull(p.Permanente,cast(0 as bit))			as Permanente 
		,p.DiasDescanso
		,isnull(p.Fecha,getdate()) as Fecha
		,isnull(p.Comentario,'') as Comentario
		,isnull(p.ComentarioTextoPlano,'') as ComentarioTextoPlano
		,isnull(p.Autorizado,cast(0 as bit)) as Autorizado
		,isnull(p.PapeletaAutorizada,cast(0 as bit)) as PapeletaAutorizada
		,p.FechaHora
		,p.IDUsuario
		,Municipios.Descripcion as Municipio
		,estados.NombreEstado as Estado
		,FORMAT(getdate(),'dd/MM/yyyy') as FechaHoy
		,ISNULL((SELECT TOP 1 M.NOMBRECOMPLETO FROM RH.tblJefesEmpleados j inner join RH.tblEmpleadosMaster M on J.IDJefe = M.IDEmpleado WHERE J.IDEmpleado = p.IDEmpleado),'SIN JEFE ASIGNADO') as JefeInmediato
		,FORMAT(em.FechaAntiguedad, 'dd/MM/yyyy') as FechaAntiguedad
		,cast(DATEDIFF(day, em.FechaAntiguedad, GETDATE()) / 365.2425  AS int) as Antiguedad
		,em.Area as Area
		,em.FechaIngreso as FechaIngreso		
		,case when DATEPART(YEAR, em.FechaAntiguedad) = DATEPART(YEAR,GETDATE()) then DATEPART(YEAR, em.FechaAntiguedad)
			  when DATEPART(YEAR, em.FechaAntiguedad) < DATEPART(YEAR,GETDATE()) then (DATEPART(YEAR,p.FechaInicio)-1)
			  else (DATEPART(YEAR,p.FechaInicio) -1)
		end as EjercicioInicio
		,case when DATEPART(YEAR, em.FechaAntiguedad) = DATEPART(YEAR,GETDATE()) then DATEPART(YEAR, em.FechaAntiguedad)
			  when DATEPART(YEAR, em.FechaAntiguedad) < DATEPART(YEAR,GETDATE()) then DATEPART(YEAR,p.FechaInicio)
			  else DATEPART(YEAR,p.FechaInicio)
		end as EjercicioFin
		,(SELECT STRING_AGG(item, ', ')
		
FROM
(SELECT 
    CASE item
        WHEN 1 THEN 'DOMINGO'
        WHEN 2 THEN 'LUNES'
        WHEN 3 THEN 'MARTES'
        WHEN 4 THEN 'MIERCOLES'
        WHEN 5 THEN 'JUEVES'
        WHEN 6 THEN 'VIERNES'
        WHEN 7 THEN 'SABADO'
END as item
from  app.Split(p.diasDescanso,',')) descansos) as DiasDeDescanso
		,CAST(CASE WHEN p.IDIncidencia = 'G' THEN 1 else 0 END  as bit ) [PERMISO CON GOCE]
		,CAST(CASE WHEN p.IDIncidencia = 'P' THEN 1 else 0 END  as bit ) [PERMISO SIN GOCE]
		,CAST(CASE WHEN p.IDIncidencia = 'EX' THEN 1 else 0 END as bit ) [TIEMPO EXTRA]
		,CAST(CASE WHEN p.IDIncidencia = 'TT' THEN 1 else 0 END as bit ) [TIEMPO X TIEMPO]
		,CAST(CASE WHEN p.IDIncidencia = 'TD' THEN 1 else 0 END as bit ) [TURNO DOBLE]
		,CAST(CASE WHEN p.IDIncidencia = 'DL' THEN 1 else 0 END as bit ) [DESCANSO LABORADO]
		,CASE WHEN I.GoceSueldo = 1 THEN 'Si' ELSE '' END AS GoceSueldoSi
		,CASE WHEN I.GoceSueldo = 0 THEN 'Si' ELSE '' END AS GoceSueldoNo
,(Select DiasVacaciones From RH.tblCatTiposPrestacionesDetalle Where IDTipoPrestacion = @IDTipoPrestacion And Antiguedad = @AniosAntiguedad) AS DiasVacaciones
,'X' AS PagoPrimaVacacional
,(Select Codigo From Asistencia.tblCatHorarios Where IDHorario = @IDHorario) AS Horario
from Asistencia.tblPapeletas p
		join RH.tblEmpleadosMaster em on p.IDEmpleado = em.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on em.IDEmpleado = dfeu.IDEmpleado and dfeu.IDUsuario = @IDUsuario	
		join Asistencia.tblCatIncidencias i on p.IDIncidencia = i.IDIncidencia
		left join SAT.tblCatTiposIncapacidad as tipoInca on p.IDTipoIncapacidad = tipoInca.IDTIpoIncapacidad  
		left join IMSS.tblCatClasificacionesIncapacidad clasificacion on p.IDClasificacionIncapacidad = clasificacion.IDClasificacionIncapacidad  
		--left join IMSS.tblCatCausasAccidentes causas on p.IDCausaAccidente = causas.IDCausaAccidente  
		left join IMSS.tblCatTiposLesiones lesiones on p.IDTipoLesion = lesiones.IDTipoLesion  
		left join IMSS.tblCatTipoRiesgoIncapacidad riesgos on p.IDTipoRiesgoIncapacidad = riesgos.IDTipoRiesgoIncapacidad  
		left join RH.tblcatsucursales sucursales
			on sucursales.IDSucursal = em.IDSucursal
		left join Sat.tblCatMunicipios Municipios
			on Municipios.IDMunicipio = sucursales.IDMunicipio
		left join Sat.tblCatEstados estados
			on estados.IDEstado = sucursales.IDEstado
		left join #temporal1 descanso
			on descanso.IDEmpleado = p.IDEmpleado
		left join #tempCTEDos ctedos
			on ctedos.idempleado = em.idempleado
			
	where (p.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
		and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)
GO
