USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author...........  : Jose Vargas
-- Create date........: 2022-09-20
-- Last Date Modified.: 2022-09-20
-- Description........: Obtener los correos de los empleados
-- ========================================================

CREATE FUNCTION [Utilerias].[fnBuscarCorreosEmpleados](@IDTipoNotificacion nvarchar(max))       
    returns TABLE 
as       
    RETURN 
        SELECT 
            temp.IDEmpleado,
            case when noti.IDTipoNotificacion is null then COALESCE(temp.Email,temp.EmailUsuario) 
                when noti.IDTipoConfiguracionNotificacion = 1 and temp.source = 'Correo Contacto Predeterminado'  then COALESCE(temp.Email,temp.EmailUsuario) 
                when noti.IDTipoConfiguracionNotificacion = 1 and temp.source <> 'Correo Contacto Predeterminado'  then COALESCE(temp.EmailUsuario,temp.Email) 
                when noti.IDTipoConfiguracionNotificacion = 2 then COALESCE(temp.Email,temp.EmailUsuario) 
                when noti.IDTipoConfiguracionNotificacion = 3 then COALESCE(temp.Email,temp.EmailUsuario) 
                else temp.EmailUsuario 
            end as Email
        From (
                select                                                   
                    M.IDEmpleado,cc.Email,u.Email [EmailUsuario],cc.source
                    From RH.tblEmpleadosMaster  m                
                LEFT JOIN (
                        select ce.IDEmpleado
                    ,lower(ce.[Value]) as Email
                    ,ce.Predeterminado
                    ,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by tt.IDTipoNotificacion desc ,ce.Predeterminado desc) as [ROW]
                    , tt.IDTipoNotificacion
                    , case when tt.IDTipoNotificacion is not null then 'Correo Contacto Predeterminado' else  'Correo Contacto Empleado' end as [source]
                from RH.tblContactoEmpleado ce with (nolock)
                    join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado  and ctce.IDMedioNotificacion = 'email'
                    left join rh.tblContactosEmpleadosTiposNotificaciones tt on tt.IDContactoEmpleado=ce.IDContactoEmpleado AND TT.IDTipoNotificacion=@IDTipoNotificacion
                where ce.[Value] is not null                               
            ) as cc on cc.IDEmpleado=m.IDEmpleado and cc.[ROW]=1  
            left join [Seguridad].[tblUsuarios] u on u.IDEmpleado=m.IDEmpleado                    
        ) as temp
        left join app.tblConfiguracionTiposNotificaciones noti on noti.IDTipoNotificacion=@IDTipoNotificacion
            -- SELECT m.IDEmpleado,COALESCE(cc.Email,u.Email)  as Email
            --     From  rh.tblEmpleadosMaster m 
            --     LEFT JOIN (
            --             select ce.IDEmpleado
            --                 ,lower(ce.[Value]) as Email
            --                 ,ce.Predeterminado
            --                 ,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by tt.IDTipoNotificacion desc ,ce.Predeterminado desc) as [ROW]
            --                 , tt.IDTipoNotificacion
            --             from RH.tblContactoEmpleado ce with (nolock)
            --                 join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado  and ctce.IDMedioNotificacion = 'email'
            --                 left join rh.tblContactosEmpleadosTiposNotificaciones tt on tt.IDContactoEmpleado=ce.IDContactoEmpleado AND TT.IDTipoNotificacion=@IDTipoNotificacion
            --             where ce.[Value] is not null 
            --     ) as cc on cc.IDEmpleado=m.IDEmpleado and cc.[ROW]=1            
            --     left join [Seguridad].[tblUsuarios] u on u.IDEmpleado=m.IDEmpleado 
GO
