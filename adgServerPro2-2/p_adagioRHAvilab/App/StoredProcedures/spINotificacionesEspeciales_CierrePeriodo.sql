USE [p_adagioRHAvilab]
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
 
CREATE PROCEDURE [App].[spINotificacionesEspeciales_CierrePeriodo] ( 
 @IDPeriodo int = 0
)  
AS  
BEGIN  
    declare 
		@IDNotificacion int
		,@IDTipoNotificacion varchar (255)                    
		,@htmlbody varchar (4000)                    
		,@subject varchar (4000)   
		,@IDIdioma varchar(20) = 'esmx'
        ,@TIPO_REFERENCIA_PERIODO varchar (255)
	;
    set @TIPO_REFERENCIA_PERIODO ='[Nomina].[tblCatPeriodos]';

    set @IDTipoNotificacion='CierrePeriodo'
    set @subject='Notificación De Cierre Un Periodo'
    set @htmlbody =N'<p>Hola %s ,Se ha cerrado un periodo.</p> <br>                    
                    <h1>Información del periodo</h1><br>
                    <table id=''table-detalle''>
                        <tr> <td>Clave Periodo</td> <td>%s</td> </tr>  
                        <tr> <td>Cliente</td> <td>%s</td> </tr>                  
                        <tr> <td>Descripcion</td> <td>%s</td> </tr>                  
                        <tr> <td>Tipo Nomina</td> <td>%s</td> </tr>                                           
                        <tr> <td>Periocidad Pago</td> <td>%s</td> </tr>           
                        <tr> <td>Ejercicio</td> <td>%i</td> </tr>                                                 
                        <tr> <td>Mes</td> <td>%s</td> </tr>                  
                        <tr> <td>Dias</td> <td>%i</td> </tr>                  
                        <tr> <td>Fecha Inicio Incidencia</td> <td>%s</td> </tr>                  
                        <tr> <td>Fecha Fin Incidencia</td> <td>%s</td> </tr>                                          
                        <tr> <td>Fecha Inicio Pago</td> <td>%s</td> </tr>                                                                  
                        <tr> <td>Fecha Fin Pago</td> <td>%s</td> </tr>                                          
                        <tr> <td>Tipo de periodo</td> <td>%s</td> </tr>                                          
                    </table>'
	
    insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
    values(@IDTipoNotificacion,null)
        
    set @IDNotificacion=SCOPE_IDENTITY();
        
    --USUARIOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)    
    select  @IDNotificacion,'Email',U.Email,0,
    '{ "subject":"'+@subject+'","body":"'+ FORMATMESSAGE(@htmlbody,u.Nombre,
                                                            p.ClavePeriodo,
                                                            JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),
                                                            p.Descripcion,                                                            
                                                            tn.Descripcion,
                                                            pp.Descripcion,
                                                            p.Ejercicio,
                                                            --m.Descripcion, 
															JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),
                                                            p.Dias,
                                                            convert(varchar, p.FechaInicioIncidencia, 23),
                                                            convert(varchar, p.FechaFinIncidencia, 23),
                                                            convert(varchar, p.FechaInicioPago, 23),
                                                            convert(varchar, p.FechaFinPago, 23),
                                                            case 
                                                            when p.General =1 then 'General'
                                                             when p.Especial =1 then 'Especial'
                                                             when p.Finiquito =1 then 'Finiquito'
                                                            end
                                                        )+'"}',
                                                        @TIPO_REFERENCIA_PERIODO,
                                                        @IDPeriodo,
                                                        u.IDUsuario  
    From App.tblContactosUsuariosTiposNotificaciones as cu with (nolock)  
        INNER JOIN Seguridad.tblUsuarios as u with (nolock)  on u.IDUsuario=cu.IDUsuario and u.Email is not null
        INNER JOIN Nomina.tblCatPeriodos p with (nolock)  on p.IDPeriodo=@IDPeriodo
		INNER JOIN Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		INNER JOIN Sat.tblCatPeriodicidadesPago pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		INNER JOIN Nomina.tblCatMeses m with (nolock) on p.IDMes = m.IDMes
		INNER JOIN RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente    
    where cu.IDTipoNotificacion=@IDTipoNotificacion  and cu. IDCliente=tn.IDCliente
    
    --EMPLEADOS
    insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDReferencia,IDUsuario)
    SELECT  @IDNotificacion,IDMedioNotificacion,cm.[Value],0,
    '{ "subject":"'+@subject+'","body":"'+  FORMATMESSAGE(@htmlbody,(emDestinatario.Nombre+ ' '+emDestinatario.Paterno),
                                                            p.ClavePeriodo,
                                                             JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),
                                                            p.Descripcion,
                                                            tn.Descripcion,
                                                            pp.Descripcion,
                                                            p.Ejercicio,
                                                            --m.Descripcion, 
															JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),
                                                            p.Dias,
                                                            convert(varchar, p.FechaInicioIncidencia, 23),
                                                            convert(varchar, p.FechaFinIncidencia, 23),
                                                            convert(varchar, p.FechaInicioPago, 23),
                                                            convert(varchar, p.FechaFinPago, 23),
                                                            case 
                                                                when p.General =1 then 'General'
                                                                when p.Especial =1 then 'Especial'
                                                                when p.Finiquito =1 then 'Finiquito'
                                                            end
                                                        )+'"}'  ,
                                                        @TIPO_REFERENCIA_PERIODO,
                                                        @IDPeriodo,
                                                        u.IDUsuario
    fROM [RH].[tblContactosEmpleadosTiposNotificaciones]  cet with (nolock)  
        inner join RH.tblContactoEmpleado cm with (nolock) on cm.IDContactoEmpleado=cet.IDContactoEmpleado 
        inner join RH.tblCatTipoContactoEmpleado ctc with (nolock) on ctc.IDTipoContacto=cm.IDTipoContactoEmpleado
        inner join RH.tblEmpleadosMaster emDestinatario with (nolock) on emDestinatario.IDEmpleado=cet.IDEmpleado and IDMedioNotificacion is not null
        inner join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo=@IDPeriodo
		inner join Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		inner join Nomina.tblCatMeses m with (nolock) on p.IDMes = m.IDMes
		inner join RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente
        left join Seguridad.tblUsuarios u with (nolock)   on u.IDEmpleado=emDestinatario.IDEmpleado
    where cet.IDTipoNotificacion=@IDTipoNotificacion  and emDestinatario.IDCliente=tn.IDCliente and emDestinatario.Vigente=1

END
GO
