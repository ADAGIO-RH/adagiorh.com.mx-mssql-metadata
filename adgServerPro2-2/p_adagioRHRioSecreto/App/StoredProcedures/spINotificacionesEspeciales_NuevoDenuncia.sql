USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-02  
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2025-03-20          Jose Vargas         Al insertar a la tabla  `[App].[tblEnviarNotificacionA]` se agregan los valores 
                                        `IDReferencia`,`TipoReferencia`,`IDusuario` esto para el rastreo de correos.
***************************************************************************************************/  
 
CREATE PROCEDURE [App].[spINotificacionesEspeciales_NuevoDenuncia] ( 
 @IDDenuncia int = 0
)  
AS  
BEGIN  

    declare @tRowDenunciados varchar(500)
    declare @IDNotificacion int;
    declare @IDTipoDenunciado int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (4000)                    
    declare @subject varchar (4000)         
    declare @TIPO_REFERENCIA_DENUNCIAS varchar (255)                    

    set @TIPO_REFERENCIA_DENUNCIAS='[Norma35].[tblDenuncias]';
    
    set @tRowDenunciados='<b>%s<b><br>'

    set @IDTipoNotificacion='NuevaDenuncia'
    set @subject='Notificación De Nueva Denuncia'
    set @htmlbody =N'<p>Hola %s ,Se ha generado una denuncia.</p> <br>                    
                    <h1>Detalle de la denuncia</h1><br>
                    <table id=''table-detalle''>
                        <tr> <td>Empleado Denunciante</td> <td>%s</td> </tr>                  
                        <tr> <td>Fecha del evento</td> <td>%s</td> </tr>  
                        <tr> <td>Tipo denuncia</td> <td>%s</td> </tr>                   
                        <tr> <td>Descripcion de los hecho</td> <td>%s</td> </tr>                   
                        <tr> <td>Tipo denunciados</td> <td>%s</td> </tr>                   
                        <tr> <td>%s</td> <td>%s</td> </tr>                   
                    </table>'

 
    select @IDTipoDenunciado=IDTipoDenunciado from Norma35.tblDenuncias d where d.IDDenuncia=@IDDenuncia

    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    if (@IDTipoDenunciado =1)  --CUANDO LA DENUNCIA ES PARA UNA SITUACION EN ESPECIFICO Y NO INVOLUCA NINGUN EMPLEADO
        Begin
            --USUARIOS
            
            insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
            select  @IDNotificacion,'Email',U.Email,0,
            '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,
                                                                                    (case d.EsAnonima when  1 then 'Anonimo' else emDenunciante.NOMBRECOMPLETO end) ,
                                                                                    convert(varchar, d.FechaEvento, 23),
                                                                                    td.Descripcion,
                                                                                    REPLACE(DescripcionHechos, '"',''''),                                                                                    
                                                                                    ctd.Descripcion,
                                                                                    'Situación denunciada',
                                                                                    d.Denunciados
                                                                                    )+'"}',
                                                                                    @TIPO_REFERENCIA_DENUNCIAS,
                                                                                    @IDDenuncia,
                                                                                    u.IDUsuario  
            From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)
                INNER JOIN Seguridad.tblUsuarios as u with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
                INNER JOIN Norma35.tblDenuncias d with (nolock) on d.IDDenuncia=@IDDenuncia
                INNER JOIN Norma35.tblCatTiposDenuncias td  with (nolock) on td.IDTipoDenuncia = d.IDTipoDenuncia
                inner join Norma35.tblCatTiposDenunciado ctd with (nolock) on ctd.IDTipoDenunciado=d.IDTipoDenunciado and ctd.IDTipoDenunciado=1
                left  join RH.tblEmpleadosMaster emDenunciante with (nolock) on emDenunciante.IDEmpleado = d.IDEmpleadoDenunciante            
            where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=d.IDCliente

            --EMPLEADOS
            insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
            SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
            '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),
                                                                                    (case d.EsAnonima when  1 then 'Anonimo' else emDenunciante.NOMBRECOMPLETO end) ,
                                                                                    convert(varchar, d.FechaEvento, 23),
                                                                                    td.Descripcion,
                                                                                    REPLACE(DescripcionHechos, '"',''''),
                                                                                    ctd.Descripcion,
                                                                                    'Situación denunciada',                                                                                    
                                                                                    d.Denunciados
                                                                                    )+'"}', 
                                                                                    @TIPO_REFERENCIA_DENUNCIAS,
                                                                                    @IDDenuncia,
                                                                                    u.IDUsuario 
            FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet with (nolock)  
                inner join RH.tblContactoEmpleado cm  with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
                inner join RH.tblCatTipoContactoEmpleado ctc  with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
                inner join RH.tblEmpleadosMaster emDestinatario  with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null    
                INNER JOIN Norma35.tblDenuncias d  with (nolock) on d.IDDenuncia=@IDDenuncia
                INNER JOIN Norma35.tblCatTiposDenuncias td with (nolock) on td.IDTipoDenuncia = d.IDTipoDenuncia 
                inner join Norma35.tblCatTiposDenunciado ctd  with (nolock) on ctd.IDTipoDenunciado=d.IDTipoDenunciado and ctd.IDTipoDenunciado=1    
                left  join RH.tblEmpleadosMaster emDenunciante  with (nolock) on emDenunciante.IDEmpleado = d.IDEmpleadoDenunciante            
                left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = d.IDEmpleadoDenunciante 
            where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=d.IDCliente
        end
    else if (@IDTipoDenunciado =2 or @IDTipoDenunciado =3) -- CUANDO LA DENUNCIA INVOLUCRA ALGÚN EMPLEADO(s)
        BEGIN
            --USUARIOS
            insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
            select  @IDNotificacion,'Email',U.Email,0,
            '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,
                                                                                    (case d.EsAnonima when  1 then 'Anonimo' else emDenunciante.NOMBRECOMPLETO end) ,
                                                                                    convert(varchar, d.FechaEvento, 23),
                                                                                    td.Descripcion,
                                                                                    REPLACE(DescripcionHechos, '"',''''),
                                                                                    ctd.Descripcion,
                                                                                    'Denunciados',
                                                                                    (SELECT (select  FORMATMESSAGE(@tRowDenunciados,emDenunciados.NOMBRECOMPLETO) AS 'data'   from  RH.tblEmpleadosMaster  emDenunciados
                                                                                    where emDenunciados.IDEmpleado in  (select item from  App.Split(d.Denunciados,',') ) 
                                                                                    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'))
                                                                                    )+'"}',
                                                                                    @TIPO_REFERENCIA_DENUNCIAS,
                                                                                    @IDDenuncia,
                                                                                    u.IDUsuario   

            From App.tblContactosUsuariosTiposNotificaciones as cu
                INNER JOIN Seguridad.tblUsuarios u with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
                INNER JOIN Norma35.tblDenuncias d with (nolock) on d.IDDenuncia=@IDDenuncia
                INNER JOIN Norma35.tblCatTiposDenuncias td  with (nolock) on td.IDTipoDenuncia = d.IDTipoDenuncia
                inner join Norma35.tblCatTiposDenunciado ctd with (nolock) on ctd.IDTipoDenunciado=d.IDTipoDenunciado and ctd.IDTipoDenunciado in(2,3)    
                left  join RH.tblEmpleadosMaster emDenunciante with (nolock)  
                    on emDenunciante.IDEmpleado = d.IDEmpleadoDenunciante            
            where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=d.IDCliente

            --EMPLEADOS
            insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
            SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
            '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),
                                                                                    (case d.EsAnonima when  1 then 'Anonimo' else emDenunciante.NOMBRECOMPLETO end) ,
                                                                                    convert(varchar, d.FechaEvento, 23),
                                                                                    td.Descripcion,
                                                                                    REPLACE(DescripcionHechos, '"',''''),
                                                                                    ctd.Descripcion,
                                                                                    'Denunciados',
                                                                                    (SELECT (select  FORMATMESSAGE(@tRowDenunciados,emDenunciados.NOMBRECOMPLETO) AS 'data'   from  RH.tblEmpleadosMaster  emDenunciados
                                                                                    where emDenunciados.IDEmpleado in  (select item from  App.Split(d.Denunciados,',') ) 
                                                                                    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'))
                                                                                    )+'"}',
                                                                                    @TIPO_REFERENCIA_DENUNCIAS,
                                                                                    @IDDenuncia,
                                                                                    u.IDUsuario   
            FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet with (nolock)  
                inner join RH.tblContactoEmpleado cm  with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
                inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
                inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null    
                INNER JOIN Norma35.tblDenuncias d with (nolock) on d.IDDenuncia=@IDDenuncia
                INNER JOIN Norma35.tblCatTiposDenuncias td with (nolock) on td.IDTipoDenuncia = d.IDTipoDenuncia 
                inner join Norma35.tblCatTiposDenunciado ctd with (nolock) on ctd.IDTipoDenunciado=d.IDTipoDenunciado and ctd.IDTipoDenunciado in (2,3)
                left  join RH.tblEmpleadosMaster emDenunciante with (nolock) on emDenunciante.IDEmpleado = d.IDEmpleadoDenunciante            
                left join Seguridad.tblUsuarios u with (nolock)  on u.IDEmpleado = d.IDEmpleadoDenunciante 
            where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=d.IDCliente
        end
     
END
GO
