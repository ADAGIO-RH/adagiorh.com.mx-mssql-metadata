USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- declare @IDTipoNotificacion varchar(50) = 'ActivarCuenta'  
CREATE proc [App].[spBuscarNotificacionesPendientes]  
as  
select   
  n.IDNotifiacion  
 ,n.IDTipoNotificacion  
 ,n.FechaHoraCreacion  
 ,n.Parametros   
  
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
 ,tipoNoti.Asunto
 ,ena.Adjuntos  
from [App].[tblNotificaciones] n  
 join [App].[tblEnviarNotificacionA] ena on n.IDNotifiacion = ena.IDNotifiacion  
 left join [App].[tblTemplateNotificaciones] tn on tn.IDTipoNotificacion = n.IDTipoNotificacion   
              and tn.IDMedioNotificacion = ena.IDMedioNotificacion  
 left join [App].tblTiposNotificaciones tipoNoti on n.IDTipoNotificacion = tipoNoti.IDTipoNotificacion  
where isnull(ena.Enviado,cast(0 as bit)) = 0  
  
  
  
  
/*  
  
select * from [App].[tblMediosNotificaciones]  
select * from [App].[tblTiposNotificaciones]  
select * from [App].[tblTemplateNotificaciones]  
  
*/
GO
