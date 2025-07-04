USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc App.spBuscarNotificaciones as

	select 
		convert(varchar(100),isnull(n.FechaHoraCreacion,'1990-01-01 00:00:00'),106)+' - '+tn.Asunto as Grupo
		,n.IDNotifiacion
		,n.IDTipoNotificacion
		,isnull(n.FechaHoraCreacion,'1990-01-01 00:00:00') as FechaHoraCreacion
		,enviar.IDEnviarNotificacionA
		,enviar.IDMedioNotificacion
		,enviar.Destinatario
		,isnull(enviar.Enviado,cast(0 as bit)) as Enviado
		,isnull(enviar.FechaHoraEnvio,'1990-01-01 00:00:00') FechaHoraEnvio
		,tn.Descripcion as TipoNotificacion
		,tn.Asunto
	from App.tblNotificaciones n
		join App.tblEnviarNotificacionA enviar on enviar.IDNotifiacion = n.IDNotifiacion
		left join App.tblTiposNotificaciones tn on n.IDTipoNotificacion = tn.IDTipoNotificacion
		--left join App.tblTemplateNotificaciones tp on n. = tp.IDTemplateNotificacion
	order by isnull(n.FechaHoraCreacion,'1990-01-01 00:00:00') desc
GO
