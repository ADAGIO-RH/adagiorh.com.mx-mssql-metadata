USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las Papeletas por empleado y rango de fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-11-06
** Paremetros		:              

** DataTypes Relacionados: 


	Si se modifica el sp [Asistencia].[spBuscarPapeletas] es necesario modificar los siguientes sp's:
		- [Asistencia].[spBuscarEventosCalendario]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Asistencia].[spBuscarPapeletas](
	@IDPapeleta		int = 0
	,@IDEmpleado	int
	,@FechaInicio	date = null
	,@FechaFin		date = null
	,@IDUsuario		int
	,@IDIncidenciaEmpleado int=0
) as

	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		 p.IDPapeleta
		,p.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO as NombreCompleto
		,p.IDIncidencia
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,isnull(i.EsAusentismo,cast(0 as bit)) as EsAusentismo
		,isnull(p.FechaInicio,getdate()) as FechaInicio
		,isnull(p.FechaFin,getdate()) as FechaFin
		,isnull(p.TiempoAutorizado,getdate()) as TiempoAutorizado
		,isnull(p.TiempoSugerido,getdate()) as TiempoSugerido
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
		,P.IDIncidenciaEmpleado 
	from Asistencia.tblPapeletas p
		join RH.tblEmpleadosMaster em on p.IDEmpleado = em.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on em.IDEmpleado = dfeu.IDEmpleado and dfeu.IDUsuario = @IDUsuario	
		join Asistencia.tblCatIncidencias i on p.IDIncidencia = i.IDIncidencia

		left join SAT.tblCatTiposIncapacidad as tipoInca on p.IDTipoIncapacidad = tipoInca.IDTIpoIncapacidad  
		left join IMSS.tblCatClasificacionesIncapacidad clasificacion on p.IDClasificacionIncapacidad = clasificacion.IDClasificacionIncapacidad  
		--left join IMSS.tblCatCausasAccidentes causas on p.IDCausaAccidente = causas.IDCausaAccidente  
		left join IMSS.tblCatTiposLesiones lesiones on p.IDTipoLesion = lesiones.IDTipoLesion  
		left join IMSS.tblCatTipoRiesgoIncapacidad riesgos on p.IDTipoRiesgoIncapacidad = riesgos.IDTipoRiesgoIncapacidad  
	where (p.IDEmpleado = @IDEmpleado or ISNULL(@IDEmpleado,0) = 0)
		and (p.IDPapeleta = @IDPapeleta or ISNULL(@IDPapeleta,0) = 0)
		and ((p.Fecha between @FechaInicio and @FechaFin) or (@FechaInicio is null or @FechaFin is null))
		and  (p.IDIncidenciaEmpleado = @IDIncidenciaEmpleado or ISNULL(@IDIncidenciaEmpleado,0) = 0)
GO
