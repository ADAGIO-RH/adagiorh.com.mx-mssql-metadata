USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarNotificacionesPendientes]  
as  
	select   
		n.IDNotifiacion  
		,n.IDTipoNotificacion  
		,n.FechaHoraCreacion  
		,ISNULL(n.Parametros,ena.Parametros) [Parametros] 
  
		,ena.IDEnviarNotificacionA  
		--,ena.IDNotifiacion  
		,ena.IDMedioNotificacion  
		,ena.Destinatario  
		,isnull(ena.Enviado,0) as Enviado  
		,isnull(ena.FechaHoraEnvio,getdate())  as FechaHoraEnvio  
		--,ena.FechaHoraCreacion  
		,tn.IDTemplateNotificacion  
		--,tn.IDTipoNotificacion  
		--,tn.IDMedioNotificacion  
		,tn.Template  
		--,tipoNoti.Asunto
		,'adagioRH' Asunto
		,ena.Adjuntos  
        ,ENA.TipoReferencia
        ,ena.IDReferencia
		,isnull(ena.IDTipoAdjunto, 1) as IDTipoAdjunto -- 1 = Rutas separadas por comas
        ,isnull(ena.IDUsuario ,0)  as IDUsuario
	from [App].[tblNotificaciones] n  
		join [App].[tblEnviarNotificacionA] ena on n.IDNotifiacion = ena.IDNotifiacion  
		left join [App].[tblTemplateNotificaciones] tn on tn.IDTipoNotificacion = n.IDTipoNotificacion   
				and tn.IDMedioNotificacion = ena.IDMedioNotificacion  
				and isnull(tn.IDIdioma,'es-MX') = isnull(n.IDIdioma,'es-MX')
		left join [App].tblTiposNotificaciones tipoNoti on n.IDTipoNotificacion = tipoNoti.IDTipoNotificacion  
	where isnull(ena.Enviado,cast(0 as bit)) = 0
GO
