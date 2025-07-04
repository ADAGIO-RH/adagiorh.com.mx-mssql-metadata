USE [p_adagioRHCSM]
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
 

CREATE PROCEDURE [App].[spINotificacionesEspeciales_NuevoPrestamo] ( 
 @IDSolicitudPrestamo int = 0
)  
AS  
BEGIN  

    declare @IDNotificacion int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (4000)                    
    declare @subject varchar (4000)         
    declare @TIPO_REFERENCIA_SOLICITUD_PRESTAMO varchar(25)

    set @TIPO_REFERENCIA_SOLICITUD_PRESTAMO='[Intranet].[tblSolicitudesPrestamos]';

    set @IDTipoNotificacion='NuevoPrestamo'
    set @subject='%s ha solicitado un nuevo préstamo'
    set @htmlbody =N'   <p> Hola %s ,<p>El colaborador(a) %s <p> <br/>
                        Ha realizado una solicitud de préstamos por concepto de <b>%s.</b> <br/>                        
                        <h1>Detalle del préstamos solicitado</h1> <br />
                        <table id=''table-detalle''> 
                            <tr> <td>Tipo de préstamo</td> <td>%s</t> </tr>  
                            <tr> <td>Monto Solicitado</td> <td>%s</t> </tr>  
                            <tr> <td>Monto de las Coutas</td> <td>%s</t> </tr>  
                            <tr> <td>Cantidad de Cuotas</td> <td>%s</t> </tr>  
                            <tr> <td>Fecha de inicio</td> <td>%s</t> </tr>
                            <tr> <td>Estatus</td> <td>%s</td> </tr> 
                        </table>'  
	            		
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+FORMATMESSAGE(@subject,e.Nombre)+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,
                                                                                    (e.ClaveEmpleado +' - '+e.Nombre),
                                                                                    ctp.Descripcion,ctp.Descripcion,
                                                                                    cast(isnull(sp.MontoPrestamo,0.00) as varchar(20)),
                                                                                    cast(isnull(sp.Cuotas, 0) as varchar(20)),
                                                                                    cast(isnull(sp.CantidadCuotas, 0) as varchar(20)),
                                                                                    format(sp.FechaInicioPago, 'dd/MM/yyyy'),
                                                                                    cesp.Nombre
                                                                                )+'"}',
                                                                                @TIPO_REFERENCIA_SOLICITUD_PRESTAMO,
                                                                                @IDSolicitudPrestamo,
                                                                                u.IDUsuario  
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios as u  with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
        inner join [Intranet].[tblSolicitudesPrestamos] sp with (nolock) on sp.IDSolicitudPrestamo= @IDSolicitudPrestamo
        join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
        join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
        join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo         
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu.IDCliente=e.IDCliente

    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
    '{ "subject":"'+FORMATMESSAGE(@subject,e.Nombre)+'","body":"'+ FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),
                                                                                    (e.ClaveEmpleado +' - '+e.Nombre),
                                                                                    ctp.Descripcion,ctp.Descripcion,
                                                                                    cast(isnull(sp.MontoPrestamo,0.00) as varchar(20)),
                                                                                    cast(isnull(sp.Cuotas, 0) as varchar(20)),
                                                                                    cast(isnull(sp.CantidadCuotas, 0) as varchar(20)),
                                                                                    format(sp.FechaInicioPago, 'dd/MM/yyyy'),
                                                                                    cesp.Nombre
                                                                                )+'"}',
                                                                                @TIPO_REFERENCIA_SOLICITUD_PRESTAMO,
                                                                                @IDSolicitudPrestamo ,
                                                                                u.IDUsuario 
    FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet
        inner join RH.tblContactoEmpleado cm  with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null
        inner join [Intranet].[tblSolicitudesPrestamos] sp with (nolock) on sp.IDSolicitudPrestamo= @IDSolicitudPrestamo
        join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
        join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
        join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo         
        left join Seguridad.tblUsuarios u with (nolock)   on u.IDEmpleado=emDestinatario.IDEmpleado
    where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=e.IDCliente and e.Vigente=1

END
GO
