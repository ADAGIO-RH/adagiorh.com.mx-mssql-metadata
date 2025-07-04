USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : JOSE ROMAN
** Email   : jroman@adagio.com.mx  
** FechaCreacion : 2025-02-20  
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2025-02-20			JOSE ROMAN			Este procedimiento es para generar la notificación de la generación
										de movimientos afiliatorios por cambio de factor de integración.
***************************************************************************************************/  
 

CREATE PROCEDURE [App].[spINotificacionesEspeciales_CalculoAplicacionNuevoIntegrado] ( 
	@Body Varchar(MAX)
)  
AS  
BEGIN  

	print @Body
    declare @IDNotificacion int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (4000)                    
    declare @subject varchar (4000)         
    set @IDTipoNotificacion='CalculoNuevoIntegrado'
    set @subject='Nuevos Salarios Integrados Aplicados.'
    set @htmlbody =N'   <p> Hola %s , <br/>
                        La configuración automatica de AdagioRH ha generado por aniversario de antigüedad <br/>                        
						los siguientes movimientos afiliatorios. <br/>   
                        <h1>Detalle de los movimientos afiliatorios</h1> <br />
                       '+ @Body  
	            		
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+FORMATMESSAGE(@subject,u.Nombre)+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre)+'"}'  
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios as u  with (nolock) on u.IDUsuario=cu.IDUsuario and u.Email is not null
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and ISNULL(u.Activo,0) = 1

    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
    '{ "subject":"'+FORMATMESSAGE(@subject,emDestinatario.Nombre)+'","body":"'+ FORMATMESSAGE(@htmlbody,emDestinatario.Nombre)+'"}'  
    FROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet
        inner join RH.tblContactoEmpleado cm  with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null
    where cet.IDTipoNotificacion=@IDTipoNotificacion  
		and emDestinatario.Vigente=1

END
GO
