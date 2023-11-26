USE [p_adagioRHAfosa]
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
 
CREATE PROCEDURE [App].[spINotificacionesEspeciales_NuevoColaborador] ( 
 @IDEmpleado int = 0
)  
AS  
BEGIN  

    declare @IDNotificacion int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (4000)                    
    declare @subject varchar (4000)         
    set @IDTipoNotificacion='NuevoColaborador'
    set @subject='Notificación De Nuevo Colaborador'
    set @htmlbody =N'   <p> Hola %s ,Se ha ingresado al sistema un nuevo colaborador.</p><br>
                        <h1>Detalle del colaborador</h1><br>
                        <table id=''table-detalle''>
                        <tr> <td>Clave Colaborador</td> <td>%s</td> </tr>                  
                        <tr> <td>Nombre del colaborador</td> <td>%s</td> </tr>  
                        <tr> <td>Sexo</td> <td>%s</td> </tr>                   
                        <tr> <td>Jornada Laboral</td> <td>%s</td> </tr>                   
                        <tr> <td>Departamento</td> <td>%s</td> </tr>                   
                        <tr> <td>Sucursal</td> <td>%s</td> </tr>                   
                        <tr> <td>Puesto</td> <td>%s</td> </tr>                   
                        <tr> <td>Centro de Costo</td> <td>%s</td> </tr>                   
                        <tr> <td>Empresa</td> <td>%s</td> </tr>                   
                        <tr> <td>Area</td> <td>%s</td> </tr>                   
                        <tr> <td>División</td> <td>%s</td> </tr>                   
                        <tr> <td>Tipo Nomina</td> <td>%s</td> </tr>                   
                        <tr> <td>Tipo Empleado</td> <td>%s</td> </tr>              
                    </table>'
	
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,
                                                                            m.ClaveEmpleado,
                                                                            m.NOMBRECOMPLETO,
                                                                            m.Sexo,
                                                                            m.JornadaLaboral,
                                                                            m.Departamento,
                                                                            m.Sucursal,
                                                                            m.Puesto,
                                                                            m.CentroCosto,
                                                                            m.Empresa,
                                                                            m.Area,
                                                                            m.Division,
                                                                            m.TipoNomina,
                                                                            m.tipoTrabajadorEmpleado)+'"}'  
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios u with (nolock)  
            on u.IDUsuario=cu.IDUsuario and u.Email is not null
        INNER JOIN RH.tblEmpleadosMaster m with (nolock)  
            on m.IDEmpleado= @IDEmpleado
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=m.IDCliente

    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0 ,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),
                                                                            m.ClaveEmpleado,
                                                                            m.NOMBRECOMPLETO,
                                                                            m.Sexo,
                                                                            m.JornadaLaboral,
                                                                            m.Departamento,
                                                                            m.Sucursal,
                                                                            m.Puesto,
                                                                            m.CentroCosto,
                                                                            m.Empresa,
                                                                            m.Area,
                                                                            m.Division,
                                                                            m.TipoNomina,
                                                                            m.tipoTrabajadorEmpleado)+'"}'  
    fROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet
        inner join RH.tblContactoEmpleado cm  with (nolock)  
            on cm.IDContactoEmpleado=cet.IDContactoEmpleado
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock)  
            on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock)  
            on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null
        INNER JOIN RH.tblEmpleadosMaster m with (nolock)  
            on m.IDEmpleado= @IDEmpleado
    where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=m.IDCliente

END
GO
