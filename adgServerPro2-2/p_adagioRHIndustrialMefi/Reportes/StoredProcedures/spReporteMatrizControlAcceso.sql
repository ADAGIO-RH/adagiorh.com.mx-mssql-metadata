USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2023-08-07
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Reportes].[spReporteMatrizControlAcceso](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

)
AS
BEGIN

    declare	
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null   
        ,@Empleados varchar(max);


    SET @Empleados = (select top 1 cast(Value as varchar(max)) from @dtFiltros where catalogo = 'Empleados')

	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p  with (nolock) 
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish';  
	end  
    	
     
    declare @IdsEmpleads table(
        IDEmpleado int,
        ClaveEmpleado varchar(40),
        NombreCompleto varchar(150),
        Puesto varchar(150)
    );
    
    if object_id('tempdb..#tempResultMatrizControlAcceso') is not null drop table #tempResultMatrizControlAcceso;
	Create table #tempResultMatrizControlAcceso   (      
        IDEmpleado int,        
        ClaveEmpleado varchar(40),
        Puesto varchar(max),
        NombreCompleto varchar(max),
        aplicacion_o_permiso varchar(150),
        Value  varchar(5)
    );     

    declare @aplicaciones  table (
        ID int ,
        aplicacion_o_permiso varchar(150)   
    )
    insert into @IdsEmpleads (IDEmpleado,ClaveEmpleado,NombreCompleto,Puesto)
    SELECT DISTINCT (asignacion.IDEmpleado),empleado.ClaveEmpleado,NOMBRECOMPLETO,Puesto from rh.tblAsignacionesMatrizControlAcceso asignacion
        INNER JOIN  rh.tblEmpleadosMaster empleado on asignacion.IDEmpleado=empleado.IDEmpleado
    where  
        ((empleado.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>'')))) AND
        (empleado.IDEmpleado in ( select Item from App.Split( @Empleados,',')) or isnull(@Empleados,'')='')

    

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
    WHERE isnull(app.Parent,0)  = 0 and app.Estatus=1
    order by app.IDMatrizControlAcceso,permisos.Parent
    
    
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
                        when asignacion.Value=1 then 'SI'
                    else 'NO' end
                FROM rh.tblAsignacionesMatrizControlAcceso asignacion 
                WHERE asignacion.IDMatrizControlAcceso=app.ID and asignacion.IDEmpleado=ids.IDEmpleado
            ),'NO') as Value
    FROM @IdsEmpleads ids   
    CROSS join @aplicaciones app
    
    DECLARE @columnsAplicaciones NVARCHAR(MAX)
    SELECT @columnsAplicaciones = COALESCE(@columnsAplicaciones + ', ', '') + QUOTENAME(aplicacion_o_permiso)
    from (
        select distinct (aplicacion_o_permiso) from #tempResultMatrizControlAcceso
    ) as tble    
    
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
