USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarTemplateNotificaciones](
    @IDTemplateNotificacion int = null
)
as 


select 
 template.IDTemplateNotificacion
,template.IDTipoNotificacion
,template.IDMedioNotificacion
,template.Template

from [App].[tblTemplateNotificaciones] template
    join [App].[tblTiposNotificaciones] tipoNotificaciones on template.IDTipoNotificacion = tipoNotificaciones.IDTipoNotificacion
    join [App].[tblMediosNotificaciones] medioNotificacion on template.IDMedioNotificacion = medioNotificacion.IDMedioNotificacion
where (template.IDTemplateNotificacion = @IDTemplateNotificacion or @IDTemplateNotificacion is null)
GO
