USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spIUTemplateNotificacion](
	@IDTemplateNotificacion	int = 0
    ,@IDTipoNotificacion varchar(50)
    ,@IDMedioNotificacion varchar(50)
    ,@Template nvarchar(MAX)
)
as

    if not exists(select 1 
		    from [App].[tblTemplateNotificaciones] with (nolock) 
		    where IDTemplateNotificacion = @IDTemplateNotificacion)
    begin
	   insert into [App].[tblTemplateNotificaciones](IDTipoNotificacion,IDMedioNotificacion,Template)
	   select @IDTipoNotificacion,@IDMedioNotificacion,@Template

	   select @IDTemplateNotificacion=@@IDENTITY
    end else
    begin
	   update [App].[tblTemplateNotificaciones]
	   set IDTipoNotificacion   = @IDTipoNotificacion
	      ,IDMedioNotificacion  = @IDMedioNotificacion
		 ,Template		   = @Template
	   where IDTemplateNotificacion = @IDTemplateNotificacion
    end;   

    exec [App].[spBuscarTemplateNotificaciones] @IDTemplateNotificacion=@IDTemplateNotificacion
GO
