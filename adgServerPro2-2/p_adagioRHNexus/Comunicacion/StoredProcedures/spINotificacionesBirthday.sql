USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Comunicacion].[spINotificacionesBirthday] ( 
	@subject varchar(max),
	@dtDestinatarios [Comunicacion].[dtEnviarNotificacionA] readonly,
	@IDUsuario int =0
)  
AS  
BEGIN  
    declare @IDNotificacion int
		,@IDTipoNotificacion varchar (255)                    
		,@htmlbody varchar (max)                    
		,@isGeneral bit
    ;

    set @IDTipoNotificacion='Birthday'    
  
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)        
        
    set @IDNotificacion=SCOPE_IDENTITY();

    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)    
    select @IDNotificacion
			, s.IDMedioNotificacion
			, s.Destinatario
			--, 'aparedes@adagio.com.mx'
			, 0
			, '{ "subject":"'+s.Subject+'","body":"'+REPLACE( s.Body,'"','\"')+'"}'
    from @dtDestinatarios s

END
GO
