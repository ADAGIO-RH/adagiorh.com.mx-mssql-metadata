USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spPapeletasIncidencias]--1,14,1 
(
	 @IDPapeleta	int 
	,@IDEmpleado	int = 0
	,@IDUsuario		int
) as

  SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	DECLARE 
        @IDIdioma varchar(225),
        @msgDescripcion varchar(500),
        @Festivos [App].[dtFechasFull],
        @Fechas [App].[dtFechasFull]
        ,@SumarDiasDescanso int = 0
        ,@SumarDiasFestivos int = 0
        ,@FechaInicio       date
        ,@FechaFin          date 
        ,@DiasDescanso              varchar(20)
        ,@i int = 1
        ,@IDIncidencia varchar(10)        
        ,@CALENDARIO0007			bit = 0 --El usuario puede modificar su propio calendario de incidencias.
    ;

	SELECT @IDEmpleado = IDEmpleado FROM Asistencia.tblPapeletas WHERE IDPapeleta = @IDPapeleta

    if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	with(nolock)
				join App.tblCatPermisosEspeciales cpe with(nolock) on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0007')
		begin
			set @CALENDARIO0007 = 1
		end;
    
    if (ISNULL(@IDPapeleta,0)=0 AND ISNULL(@IDEmpleado,0)=0)
		begin
			SELECT 	
			0	AS IDPapeleta
			,0	AS IDEmpleado
			,'' AS ClaveEmpleado
			,''	AS NombreCompleto
			,'' AS Departamento
			,'' AS Sucursal
			,'' AS Puesto
			,'NO AUTORIZADO' AS Descripcion 		
			,0	AS IDIncidencia
			,'' AS Incidencia
			,0	AS EsAusentismo
			,'' AS FechaInicio 
			,'' AS FechaFin 
			,'' AS RegresoATrabajo
			,0  AS TiempoAutorizado
			,0	AS TiempoSugerido
			,0	AS Dias
			,0	AS Duracion
			,0	AS IDClasificacionIncapacidad
			,''	AS ClasificacionIncapacidad
			,0	AS IDTipoIncapacidad
			,''	AS TipoIncapacidad
			,0	AS IDTipoLesion
			,''	AS TipoLesion
			,0	AS IDTipoRiesgoIncapacidad
			,'' AS TipoRiesgoIncapacidad
			,0	AS Numero
			,0	AS PagoSubsidioEmpresa 
			,0	AS Permanente 
			,0	AS DiasDescanso
			,'' AS Fecha
			,'' AS Comentario
			,'' AS ComentarioTextoPlano
			,0	AS Autorizado
			,0	AS PapeletaAutorizada
			,'' AS FechaHora
			,0	AS IDUsuario
			,'' AS Municipio
			,'' AS Estado
			,'' AS FechaHoy
			,''as JefeInmediato
			,'' AS FechaAntiguedad
			,'' AS FechaIngreso
			,'' AS EjercicioInicio
			,'' AS EjercicioFin		
			,'' AS item
			,'' AS DiasDeDescanso
			,0	AS  [PERMISO CON GOCE]
			,0	AS  [PERMISO SIN GOCE]
			,0	AS [TIEMPO EXTRA]
			,0	AS  [TIEMPO X TIEMPO]
			,0	AS  [TURNO DOBLE]
			,0	AS  [DESCANSO LABORADO]

			return      
	end

	select
		@FechaInicio = Fecha,
		@DiasDescanso = DiasDescanso,
		@Fechafin = dateadd(day,Duracion-1,Fecha),
		@IDIncidencia = IDIncidencia,
		@IDEmpleado = CASE WHEN (isnull(@IDEmpleado,0) = 0) THEN p.IDEmpleado ELSE @IDEmpleado end
	 from Asistencia.tblPapeletas P
		where (p.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
			and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)


	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
	if object_id('tempdb..#TempLista2') is not null drop table #TempLista;   
	
	IF(@IDIncidencia = 'V')
	BEGIN
		create table #TempLista2(   
			Fecha date   
			,ID varchar(10)   
		) 

		insert into @Fechas(Fecha)
			exec [App].[spListaFechas] @FechaIni = @Fechainicio, @FechaFin = @FechaFin

		select @SumarDiasDescanso=count(*)
			from @Fechas f
			   join (
				  SELECT cast(item AS int) AS item
				  from [App].[Split](@DiasDescanso,',') ) AS dd on f.DiaSemana = cast(dd.item AS int) 
		
		set @i = 1;
		while (@i <= @SumarDiasDescanso)
		begin
			set @FechaFin = dateadd(day,1,@FechaFin)
			if not (DATEPART(DW,@FechaFin) in (
				  SELECT cast(item AS int) AS item
				  from [App].[Split](@DiasDescanso,',') ) )
				begin
					set @i = @i + 1;
				end;
		end;

		delete from @Fechas;

		insert into @Fechas(Fecha) 
			exec [App].[spListaFechas] @FechaIni = @Fechainicio, @FechaFin = @FechaFin
    
		insert @Festivos(Fecha)
		select f.Fecha
			from Asistencia.TblCatDiasFestivos df
				join @Fechas f on df.Fecha = F.Fecha
			where df.Autorizado = 1 and (DATEPART(DW,df.Fecha)) NOT IN (SELECT cast(item AS int) AS item from [App].[Split](@DiasDescanso,',') )

		select @SumarDiasFestivos = COUNT(*)
			from @Festivos
		set @i = 1;
		while (@i <= @SumarDiasFestivos)
		begin
			set @FechaFin = dateadd(day,1,@FechaFin)
			if not (DATEPART(DW,@FechaFin) in (
				  SELECT cast(item AS int) AS item
				  from [App].[Split](@DiasDescanso,',') ) )
				begin
					set @i = @i + 1;
				end;
		end;

		delete from @Fechas;

		insert into @Fechas(Fecha)
			exec [App].[spListaFechas] @FechaIni = @Fechainicio, @FechaFin = @FechaFin
   
		delete fecha
		from @Fechas fecha
			join @Festivos f on fecha.Fecha = f.Fecha

		insert into #TempLista2(Fecha, ID)   
		select Fecha   
		  ,ID = case when DiaSemana in (SELECT cast(item AS int) from [App].[Split](@DiasDescanso,',') ) then 'D' else 'V' end   
			from @Fechas
   
		select @FechaFin=max(Fecha)   
			from @Fechas   
			where DiaSemana not in  (SELECT cast(item AS int) AS item 
										from [App].[Split](@DiasDescanso,',') )
	END


	set @msgDescripcion = 
			case 
				when @IDIdioma = 'esmx' then 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '
				when @IDIdioma = 'enus' then 'THROUGH THE FOLLOWING CONDUCT I AM ALLOWED TO REQUEST PERMISSION TO: '
				else 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: ' end


	if object_id('tempdb..#temporal1') is not null
	DROP TABLE #temporal1;

	select 
		ie.IDEmpleado AS IDEmpleado
		,count(*) AS qty
		,STRING_AGG(ie.Fecha,',') AS DiaDeDescanso
	into #temporal1
	from Asistencia.tblIncidenciaEmpleado ie
		LEFT JOIN Asistencia.tblPapeletas PAPE
			on pape.idempleado = ie.IDEmpleado
	where (ie.Fecha between pape.fecha  and DATEADD(DAY,pape.Duracion,PAPE.Fecha))   and ie.IDIncidencia IN ( 'D','DF')
	group by ie.IDEmpleado

	declare @tblVacaciones [Asistencia].[dtSaldosDeVacaciones]
							

		DELETE FROM @tblVacaciones

		insert into @tblVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 1, @FechaBaja = null, @IDUsuario = 1

	select 
		 p.IDPapeleta
		,p.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO AS NombreCompleto
		,em.Departamento
		,em.Sucursal
		,em.Puesto
		,Descripcion = 
			@msgDescripcion+JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', @IDIdioma, 'Descripcion'))
		,p.IDIncidencia
		,i.Descripcion AS Incidencia
		,isnull(i.EsAusentismo,cast(0 AS bit)) AS EsAusentismo
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
                            else  isnull(p.FechaFin,getdate()) end AS RegresoATrabajo
		,cast(p.TiempoAutorizado AS varchar(5)) AS TiempoAutorizado
		,cast(p.TiempoSugerido	 AS varchar(5)) AS TiempoSugerido
		,p.Dias
		,isnull(p.Duracion,0) AS Duracion
		,isnull(p.IDClasificacionIncapacidad,0)				as IDClasificacionIncapacidad
		,isnull(clasificacion.Nombre,'SIN CLASIFICACIÓN')	as ClasificacionIncapacidad
		,isnull(p.IDTipoIncapacidad,0)						as IDTipoIncapacidad
		,isnull(tipoInca.Descripcion,'SIN TIPO')			as TipoIncapacidad
		,isnull(p.IDTipoLesion,0)							as IDTipoLesion
		,isnull(lesiones.Descripcion,'SIN TIPO DE LESIÓN')	as TipoLesion
		,isnull(p.IDTipoRiesgoIncapacidad,0)				as IDTipoRiesgoIncapacidad
		,isnull(riesgos.Nombre,'SIN RIESGO')				as TipoRiesgoIncapacidad
		,p.Numero
		,isnull(p.PagoSubsidioEmpresa,cast(0 AS bit))	as PagoSubsidioEmpresa 
		,isnull(p.Permanente,cast(0 AS bit))			as Permanente 
		,p.DiasDescanso
		,isnull(p.Fecha,getdate()) AS Fecha
		,p.Comentario
		,p.ComentarioTextoPlano
		,isnull(p.Autorizado,cast(0 AS bit)) AS Autorizado
		,isnull(p.PapeletaAutorizada,cast(0 AS bit)) AS PapeletaAutorizada
		,p.FechaHora
		,p.IDUsuario
		,Municipios.Descripcion AS Municipio
		,estados.NombreEstado AS Estado
		,FORMAT(getdate(),'dd/MM/yyyy') AS FechaHoy
		,ISNULL((SELECT TOP 1 M.NOMBRECOMPLETO FROM RH.tblJefesEmpleados j inner join RH.tblEmpleadosMaster M on J.IDJefe = M.IDEmpleado WHERE J.IDEmpleado = p.IDEmpleado),'SIN JEFE ASIGNADO') AS JefeInmediato
		,em.FechaAntiguedad AS FechaAntiguedad
		,em.FechaIngreso AS FechaIngreso
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
		END AS item
		from  app.Split(p.diasDescanso,',')) descansos) AS DiasDeDescanso
		,CAST(CASE WHEN p.IDIncidencia = 'DL' THEN 1 else 0 END  AS bit ) [DESCANSO LABORADO]
		,CAST(CASE WHEN p.IDIncidencia = 'DF' THEN 1 else 0 END  AS bit ) [DIA FESTIVO TRABAJADO]
		,CAST(CASE WHEN p.IDIncidencia = 'G'  THEN 1 else 0 END AS bit ) [PERMISO CON GOCE]
		,CAST(CASE WHEN p.IDIncidencia = 'P'  THEN 1 else 0 END AS bit ) [PERMISO SIN GOCE]
		,CAST(CASE WHEN p.IDIncidencia = 'PD' THEN 1 else 0 END AS bit ) [PRIMA DOMINICAL TRABAJADA]
		,CAST(CASE WHEN p.IDIncidencia = 'EX' THEN 1 else 0 END AS bit ) [TIEMPO EXTRA]
		,CAST(CASE WHEN p.IDIncidencia = 'V'  THEN 1 else 0 END AS bit ) [VACACIONES]
		,CAST(CASE WHEN p.IDIncidencia NOT IN ( 'V','DL','DF','G','P','PD','EX') THEN 1 else 0 END AS bit ) [OTRO]
		from Asistencia.tblPapeletas p
				join RH.tblEmpleadosMaster em on p.IDEmpleado = em.IDEmpleado
				join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on em.IDEmpleado = dfeu.IDEmpleado and dfeu.IDUsuario = @IDUsuario	
				join Asistencia.tblCatIncidencias i on p.IDIncidencia = i.IDIncidencia
				left join SAT.tblCatTiposIncapacidad AS tipoInca on p.IDTipoIncapacidad = tipoInca.IDTIpoIncapacidad  
				left join IMSS.tblCatClasificacionesIncapacidad clasificacion on p.IDClasificacionIncapacidad = clasificacion.IDClasificacionIncapacidad   
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
			where (p.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
				and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)
GO
