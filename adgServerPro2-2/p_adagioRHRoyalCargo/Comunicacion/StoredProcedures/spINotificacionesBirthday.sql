USE [p_adagioRHRoyalCargo]
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
        ,@TIPO_REFERENCIA_BIRTHDAY varchar(255)
    ;

    set @TIPO_REFERENCIA_BIRTHDAY='[RH].[tblEmpleadosMaster]';

    set @IDTipoNotificacion='Birthday'    
  
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)        
        
    set @IDNotificacion=SCOPE_IDENTITY();

    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
    select @IDNotificacion
			, s.IDMedioNotificacion
			, s.Destinatario
			--, 'aparedes@adagio.com.mx'
			, 0
			, '{ "subject":"'+s.Subject+'","body":"'+REPLACE( s.Body,'"','\"')+'"}'
            ,@TIPO_REFERENCIA_BIRTHDAY
            ,s.IDEmpleado
            ,u.IDUsuario
    from @dtDestinatarios s
    LEFT JOIN Seguridad.tblUsuarios u on u.IDEmpleado=s.IDEmpleado

END
GO
