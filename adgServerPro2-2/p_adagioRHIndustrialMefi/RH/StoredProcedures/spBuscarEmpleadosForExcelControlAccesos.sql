USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2023-08-13
-- Description:	 
-- SP PARA BUSCAR LOS EMPLEADOS, PARA LA IMPORTACION DE CONTROLES DE ACCESOS
-- =============================================


CREATE PROCEDURE [RH].[spBuscarEmpleadosForExcelControlAccesos]
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int   
AS
BEGIN
    
    declare @strIDEmpleados varchar(max);  
    declare @strIDSPuestos varchar(max);
    declare @strIDSAplicaciones varchar(max);
    
    declare @aplicaciones  table (
        ID int ,
        aplicacion_o_permiso varchar(150)   
    )

    declare @empleados  table (
        IDEmpleado int ,
        ClaveEmpleado varchar(150)  , 
        NombreCompleto varchar(150)   ,
        Puesto varchar(150)
    )
    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;    
    if object_id('tempdb..#tempFiltrosAsignarEmpaAvisos') is not null drop table #tempFiltrosAsignarEmpaAvisos;            

    set @strIDEmpleados= isnull((select top 1 cast(Value as varchar(max)) from @dtFiltros where catalogo = 'Empleados'),'')
    set @strIDSPuestos= isnull((select top 1 cast(Value as varchar(max)) from @dtFiltros where catalogo = 'Puestos'),'')
    set @strIDSAplicaciones= isnull((select top 1 cast(Value as varchar(max)) from @dtFiltros where catalogo = 'Aplicaciones'),'')
     

    insert into @empleados (ClaveEmpleado,NombreCompleto,Puesto) 
    SELECT  
        empleado.ClaveEmpleado as [Clave Empleado],
        empleado.NOMBRECOMPLETO as [Nombre Completo],
        empleado.Puesto    
    from rh.tblEmpleadosMaster empleado
    where 
        empleado.Vigente=1  and (
     (empleado.IDEmpleado in ( select Item from App.Split( @strIDEmpleados,',')) or (isnull(@strIDEmpleados,'')=''  and isnull(@strIDSPuestos,'')=''))
        or  (empleado.IDPuesto in (Select item from App.Split(@strIDSPuestos,',')) or (isnull(@strIDSPuestos,'')='') and isnull(@strIDEmpleados,'')='') )
        
        
    insert into @aplicaciones(ID,aplicacion_o_permiso)
    SELECT      
        case 
            when app.Nombre=permisos.Nombre  then 
                app.IDMatrizControlAcceso
            else             
                permisos.IDMatrizControlAcceso
        end as ID,
        case 
            when app.Nombre=permisos.Nombre then 
                app.Nombre +'__'
            else             
                concat(app.Nombre,'__',permisos.Nombre)
        end as Descripcion
    FROM [RH].[tblMatrizControlAcceso]  app
    inner join [RH].[tblMatrizControlAcceso] permisos on 
        ((app.IDMatrizControlAcceso=permisos.Parent) or (permisos.[Parent]=0 and permisos.IDMatrizControlAcceso=app.IDMatrizControlAcceso )) and app.Estatus=1
    WHERE isnull(app.Parent,0)  = 0 and app.Estatus=1 and 
     (app.IDMatrizControlAcceso in (Select item from App.Split(@strIDSAplicaciones,',')) or  isnull(@strIDSAplicaciones,'')='') 
    order by app.IDMatrizControlAcceso,permisos.Parent

    if object_id('tempdb..#tempResultMatrizControlAcceso') is not null drop table #tempResultMatrizControlAcceso;
	    Create table #tempResultMatrizControlAcceso   (      
            IDEmpleado int,        
            ClaveEmpleado varchar(40),
            Puesto varchar(max),
            NombreCompleto varchar(max),
            aplicacion_o_permiso varchar(150),
            Value  varchar(5)
    );     

    insert into #tempResultMatrizControlAcceso(IDEmpleado,ClaveEmpleado,NombreCompleto,Puesto,aplicacion_o_permiso,[Value])
    SELECT
            ids.IDEmpleado,
            ids.ClaveEmpleado,
            ids.NombreCompleto,
            ids.Puesto,
            app.aplicacion_o_permiso,        
            isnull((
                SELECT
                    CASE
                        when asignacion.Value=1 then ''
                    else '' end
                FROM rh.tblAsignacionesMatrizControlAcceso asignacion 
                WHERE asignacion.IDMatrizControlAcceso=app.ID and asignacion.IDEmpleado=ids.IDEmpleado
            ),'') as Value
    FROM @empleados ids   
    CROSS join @aplicaciones app
    
    DECLARE @columnsAplicaciones NVARCHAR(MAX)
    SELECT @columnsAplicaciones = COALESCE(@columnsAplicaciones + ', ', '') + QUOTENAME(aplicacion_o_permiso)
    from (
        select distinct (aplicacion_o_permiso) from #tempResultMatrizControlAcceso 
    ) as tble  order by aplicacion_o_permiso  
    
    DECLARE @DynamicPivotQuery NVARCHAR(MAX)
    if(exists(select top 1 1 from #tempResultMatrizControlAcceso))
    begin
        
        SET @DynamicPivotQuery = N'
        SELECT  
            ClaveEmpleado as [Clave Empleado], NombreCompleto as [Nombre Completo],Puesto, '+@columnsAplicaciones+'
            FROM #tempResultMatrizControlAcceso
            PIVOT (
                MAX(Value)
                FOR aplicacion_o_permiso IN (' + @columnsAplicaciones + ')
            ) AS PivotTable;';

        EXEC sp_executesql @DynamicPivotQuery;
    end
    ELSE
    BEGIN    
        select ClaveEmpleado  [Clave Empleado],NombreCompleto [Nombre Completo],Puesto from #tempResultMatrizControlAcceso                        
    end
    
END
GO
