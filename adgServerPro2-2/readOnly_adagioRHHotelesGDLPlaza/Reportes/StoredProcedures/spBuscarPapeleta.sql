USE [readOnly_adagioRHHotelesGDLPlaza]
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

	select 
		 p.IDPapeleta
		,p.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO as NombreCompleto
		,em.Departamento
		,em.Sucursal
		,em.Puesto
		,Descripcion = 'POR EL SIGUIENTE CONDUCTO ME PERMITO SOLICITAR PERMISO PARA: '+COALESCE(i.Descripcion,'')
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
