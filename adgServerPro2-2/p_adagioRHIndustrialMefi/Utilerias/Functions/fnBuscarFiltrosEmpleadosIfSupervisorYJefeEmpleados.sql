USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- ========================================================
-- Author...........  : Jose Vargas
-- Create date........: 2022-11-18
-- Last Date Modified.: 2022-11-18
-- Description........: Obtener los IDs de los empleados que un usuario puede ver tomando en cuenta
--                      * Relacion jefe empleados
--                      * Filtros Usuarios siempre y cuando este sea supervisor                       
-- ========================================================
-- select  * from [Utilerias].[fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados](290)
CREATE FUNCTION  [Utilerias].[fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados](@IDUsuario int)       
    returns  TABLE
as  

return                
        SELECT IDEmpleado , 
            case    
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'es-MX' then 'Yo'  
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'en-US' then 'Myself'  
                else '' END                        
        as Tipo from Seguridad.tblUsuarios where IDUsuario= @IDUsuario
        UNION
        SELECT jf.IDEmpleado ,
            CASE WHEN dt.IDUsuario is null THEN
                case    
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'es-MX' then 'Subordinado'  
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'en-US' then 'Subordinate'  
                else '' END                
            ELSE 
                case    
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'es-MX' then 'Ambos'  
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'en-US' then 'Both'  
                else '' END
            END [Tipo]
        FROM RH.tblJefesEmpleados  jf
                INNER JOIN  Seguridad.tblUsuarios  u on u.IDUsuario=@IDUsuario
                LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dt on dt.IDUsuario=u.IDUsuario and dt.IDEmpleado=jf.IDEmpleado and u.Supervisor=1
            WHERE  jf.IDJefe=  u.IDEmpleado
        UNION
        select  dt.IDEmpleado,
            CASE WHEN jf.IDEmpleado  is null then    
                case    
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'es-MX' then 'Filtro-Supervisor'  
                    when App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') = 'en-US' then 'Filter-Supervisor'  
                else '' END                
            ELSE 
                ''
            END [Tipo]                
        FROM  Seguridad.tblUsuarios u
            inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios  dt on dt.IDUsuario=u.IDUsuario
            left join RH.tblJefesEmpleados jf on jf.IDJefe=u.IDEmpleado and dt.IDEmpleado=jf.IDEmpleado
        where u.IDUsuario=@IDUsuario 
                and (jf.IDEmpleado is null)  -- EVITA QUE SE REPITAN
                and u.Supervisor=1
    -- select  * from [Utilerias].[fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados](290)
GO
