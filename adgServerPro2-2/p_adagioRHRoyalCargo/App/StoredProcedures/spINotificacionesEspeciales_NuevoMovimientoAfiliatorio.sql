USE [p_adagioRHRoyalCargo]
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
 
CREATE PROCEDURE [App].[spINotificacionesEspeciales_NuevoMovimientoAfiliatorio] ( 
 @IDMovimientoAfiliatorio int = 0
)  
AS  
BEGIN  

    declare @IDNotificacion int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (4000)                    
    declare @subject varchar (4000)         
    declare @TIPO_REFERENCIA_MOVIMIENTO_AFILIATORIO varchar (255)        

    set @TIPO_REFERENCIA_MOVIMIENTO_AFILIATORIO='[IMSS].[tblMovAfiliatorios]';


    set @IDTipoNotificacion='NuevoMovimientoAfiliatorio'
    set @subject='Notificación De Nuevo Movimiento Afiliatorio'
    set @htmlbody =N'<p>Hola %s ,Se ha generado un movimiento afiliatorio.</p> <br>                    
                    <h1>Información del movimiento afiliatorio</h1><br>
                    <table id=''table-detalle''>
                        <tr> <td>Nombre del empleado</td> <td>%s</td> </tr>                  
                        <tr> <td>Clave del empleado</td> <td>%s</td> </tr>                  
                        <tr> <td>Tipo del movimiento</td> <td>%s</td> </tr>  
                        <tr> <td>Fecha del movimiento</td> <td>%s</td> </tr>                                           
                    </table>'


    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,m.NOMBRECOMPLETO,m.ClaveEmpleado ,ctm.Descripcion,convert(varchar, ma.Fecha, 23))+'"}',@TIPO_REFERENCIA_MOVIMIENTO_AFILIATORIO,@IDMovimientoAfiliatorio,u.IDUsuario
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios as u  with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
        inner join IMSS.tblMovAfiliatorios ma with (nolock) on ma.IDMovAfiliatorio = @IDMovimientoAfiliatorio
        inner join RH.tblEmpleadosMaster m with (nolock) on m.IDEmpleado = ma.IDEmpleado
        inner join imss.tblCatTipoMovimientos ctm with (nolock) on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=m.IDCliente

    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),m.NOMBRECOMPLETO ,m.ClaveEmpleado,ctm.Descripcion,convert(varchar, ma.Fecha, 23))+'"}',@TIPO_REFERENCIA_MOVIMIENTO_AFILIATORIO,@IDMovimientoAfiliatorio,u.IDUsuario  

    FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet with (nolock)  
        inner join RH.tblContactoEmpleado cm with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null    
        inner join IMSS.tblMovAfiliatorios ma with (nolock) on ma.IDMovAfiliatorio = @IDMovimientoAfiliatorio
        inner join RH.tblEmpleadosMaster m with (nolock) on m.IDEmpleado = ma.IDEmpleado
        inner join imss.tblCatTipoMovimientos ctm with (nolock)  on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
        left join Seguridad.tblUsuarios u with (nolock)   on u.IDEmpleado=emDestinatario.IDEmpleado
    where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=m.IDCliente and m.Vigente=1
END
GO
