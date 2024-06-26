USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [App].[spGuardarNotificacion](
    @IDTipoNotificacion	varchar(50)
    ,@Parametros nvarchar(max)
    ,@destinatarios [App].[dtDestinatarios] READONLY
    )
    as  
    Declare @IDNotifiacion int = 0
    
    --,@IDTipoNotificacion	varchar(50)= 'ActivarCuenta'
    --,@Parametros nvarchar(max) = 'tipoObjeto:usuario|id:1'
    --,@destinatarios [App].[dtDestinatarios];

    insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)
    select @IDTipoNotificacion,@Parametros

    select @IDNotifiacion=@@IDENTITY;

    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'eMail','email1@server.com'  
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'eMail','email2@server.com'
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'eMail','email3@server.com'
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'eMail','email4@server.com'

    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'Telegram','-970388769'
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'Telegram','-567346785'
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'Telegram','-059384535'
    --insert into @destinatarios(IDMedioNotificacion,Valor)
    --select 'Telegram','-598798334'

    insert into App.tblEnviarNotificacionA(IDNotifiacion,IDMedioNotificacion,Destinatario)
    SELECT @IDNotifiacion as IDNotifiacion,m.IDMedioNotificacion,Valor
    FROM @destinatarios d
	   join [App].[tblMediosNotificaciones] m on d.IDMedioNotificacion=m.IDMedioNotificacion

    --select *
    --from App.tblNotificaciones

    --select *
    --from App.tblEnviarNotificacionA
GO
