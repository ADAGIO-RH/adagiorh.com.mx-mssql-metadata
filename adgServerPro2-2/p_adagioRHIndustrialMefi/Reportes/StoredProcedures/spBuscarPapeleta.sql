USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spBuscarPapeleta] (
	@IDPapeleta		int 
	,@IDEmpleado	int = 0
	,@IDUsuario		int
) as
	DECLARE  
		@IDIdioma varchar(225),
		@msgDescripcion varchar(500),
        @CALENDARIO0007			bit = 0 --El usuario puede modificar su propio calendario de incidencias.
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
	set @msgDescripcion = 
			case 
				when @IDIdioma = 'esmx' then 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '
				when @IDIdioma = 'enus' then 'THROUGH THE FOLLOWING CONDUCT I AM ALLOWED TO REQUEST PERMISSION TO: '
		else 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: ' end


	if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	with(nolock)
				join App.tblCatPermisosEspeciales cpe with(nolock) on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0007')
		begin
			set @CALENDARIO0007 = 1
		end;
    
    	if (ISNULL(@IDPapeleta,0)=0 AND ISNULL(@IDEmpleado,0)=0)
		begin
			
        select 
		 0 as IDPapeleta
		,0 as IDEmpleado
		,'' as ClaveEmpleado
		,'' as NombreCompleto
		,'' as Departamento
		,'' as Sucursal
		,'' as Puesto
		--,Descripcion = 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '+COALESCE(i.Descripcion,'')
		,Descripcion = 'SIN AUTORIZACIÓN'
			
		,0 AS IDIncidencia
		,'' as Incidencia
		,0 as EsAusentismo
		,'' AS FechaInicio
		,'' AS FechaFin   
		,'' as TiempoAutorizado
		,'' as TiempoSugerido
		,0 AS Dias
		,0 as Duracion
		,0				as IDClasificacionIncapacidad
		,''	as ClasificacionIncapacidad
		,0						as IDTipoIncapacidad
		,''		as TipoIncapacidad
		,0 as IDTipoLesion
		,''	as TipoLesion
		,0				as IDTipoRiesgoIncapacidad
		,''				as TipoRiesgoIncapacidad
		,0 AS Numero
		,0	as PagoSubsidioEmpresa 
		,0		as Permanente 
		,0 AS DiasDescanso
		,'' as Fecha
		,'' AS Comentario
		,'' AS ComentarioTextoPlano
		,0 as Autorizado
		,0 as PapeletaAutorizada
		,'' AS FechaHora
		,0 AS IDUsuario

        return
            
		end

	select 
		 p.IDPapeleta
		,p.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO as NombreCompleto
		,em.Departamento
		,em.Sucursal
		,em.Puesto
		--,Descripcion = 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '+COALESCE(i.Descripcion,'')
		,Descripcion = 
			@msgDescripcion+JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', @IDIdioma, 'Descripcion'))
		,p.IDIncidencia
		,i.Descripcion as Incidencia
		,isnull(i.EsAusentismo,cast(0 as bit)) as EsAusentismo
		,FechaInicio = case 
							when i.IDIncidencia in ('V','I') then isnull(p.Fecha,getdate()) 
							when i.EsAusentismo = 0 then isnull(p.Fecha,getdate()) 
							else  isnull(p.FechaInicio,getdate())  end
		,FechaFin    = case 
							when i.IDIncidencia in ('V','I') then DATEADD(DAY,p.Duracion,p.Fecha) 
							when i.EsAusentismo = 0 then isnull(p.Fecha,getdate()) 
							else  isnull(p.FechaFin,getdate()) end
		,cast(p.TiempoAutorizado as varchar(5)) as TiempoAutorizado
		,cast(p.TiempoSugerido	 as varchar(5)) as TiempoSugerido
		,p.Dias
		,isnull(p.Duracion,0) as Duracion
		,isnull(p.IDClasificacionIncapacidad,0)				as IDClasificacionIncapacidad
		,isnull(clasificacion.Nombre,'SIN CLASIFICACIÓN')	as ClasificacionIncapacidad
		,isnull(p.IDTipoIncapacidad,0)						as IDTipoIncapacidad
		,isnull(tipoInca.Descripcion,'SIN TIPO')			as TipoIncapacidad
		,isnull(p.IDTipoLesion,0)							as IDTipoLesion
		,isnull(lesiones.Descripcion,'SIN TIPO DE LESIÓN')	as TipoLesion
		,isnull(p.IDTipoRiesgoIncapacidad,0)				as IDTipoRiesgoIncapacidad
		,isnull(riesgos.Nombre,'SIN RIESGO')				as TipoRiesgoIncapacidad
		,p.Numero
		,isnull(p.PagoSubsidioEmpresa,cast(0 as bit))	as PagoSubsidioEmpresa 
		,isnull(p.Permanente,cast(0 as bit))			as Permanente 
		,p.DiasDescanso
		,isnull(p.Fecha,getdate()) as Fecha
		,p.Comentario
		,p.ComentarioTextoPlano
		,isnull(p.Autorizado,cast(0 as bit)) as Autorizado
		,isnull(p.PapeletaAutorizada,cast(0 as bit)) as PapeletaAutorizada
		,p.FechaHora
		,p.IDUsuario
	from Asistencia.tblPapeletas p
		join RH.tblEmpleadosMaster em on p.IDEmpleado = em.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on em.IDEmpleado = dfeu.IDEmpleado and dfeu.IDUsuario = @IDUsuario	
		join Asistencia.tblCatIncidencias i on p.IDIncidencia = i.IDIncidencia

		left join SAT.tblCatTiposIncapacidad as tipoInca on p.IDTipoIncapacidad = tipoInca.IDTIpoIncapacidad  
		left join IMSS.tblCatClasificacionesIncapacidad clasificacion on p.IDClasificacionIncapacidad = clasificacion.IDClasificacionIncapacidad  
		--left join IMSS.tblCatCausasAccidentes causas on p.IDCausaAccidente = causas.IDCausaAccidente  
		left join IMSS.tblCatTiposLesiones lesiones on p.IDTipoLesion = lesiones.IDTipoLesion  
		left join IMSS.tblCatTipoRiesgoIncapacidad riesgos on p.IDTipoRiesgoIncapacidad = riesgos.IDTipoRiesgoIncapacidad  
	where (p.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
		and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)
GO
