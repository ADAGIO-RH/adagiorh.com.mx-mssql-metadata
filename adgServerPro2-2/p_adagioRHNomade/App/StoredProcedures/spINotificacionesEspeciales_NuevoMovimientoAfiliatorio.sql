USE [p_adagioRHNomade]
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
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,m.NOMBRECOMPLETO,m.ClaveEmpleado ,ctm.Descripcion,convert(varchar, ma.Fecha, 23))+'"}'  
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios as u  with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
        inner join IMSS.tblMovAfiliatorios ma with (nolock) on ma.IDMovAfiliatorio = @IDMovimientoAfiliatorio
        inner join RH.tblEmpleadosMaster m with (nolock) on m.IDEmpleado = ma.IDEmpleado
        inner join imss.tblCatTipoMovimientos ctm with (nolock) on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=m.IDCliente

    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),m.NOMBRECOMPLETO ,m.ClaveEmpleado,ctm.Descripcion,convert(varchar, ma.Fecha, 23))+'"}'  

    FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet with (nolock)  
        inner join RH.tblContactoEmpleado cm with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null    
        inner join IMSS.tblMovAfiliatorios ma with (nolock) on ma.IDMovAfiliatorio = @IDMovimientoAfiliatorio
        inner join RH.tblEmpleadosMaster m with (nolock) on m.IDEmpleado = ma.IDEmpleado
        inner join imss.tblCatTipoMovimientos ctm with (nolock)  on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
    where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=m.IDCliente
END
GO
