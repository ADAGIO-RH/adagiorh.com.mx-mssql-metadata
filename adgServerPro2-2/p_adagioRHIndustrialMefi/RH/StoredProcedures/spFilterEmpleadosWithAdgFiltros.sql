USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado utilizando adgfiltros
** Autor			: Jose vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-02-02
** Paremetros		:              	
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleadosWithAdgFiltros](  
	@IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
	    
)as   

    declare  @tipo int ,
            @search varchar(max)

    Select  @search=isnull(Value,'') from @dtFiltros where Catalogo = 'Search'
    Select  @tipo=Value from @dtFiltros where Catalogo = 'Vigente'
    set @search=isnull(@search,'')
    
    
	select  e.IDEmpleado,
            e.ClaveEmpleado,
            e.NOMBRECOMPLETO [NombreCompleto],
            e.Nombre,
            e.SegundoNombre,
            e.Paterno,
            e.Materno,
            e.Departamento,
            e.Sucursal,
            e.Puesto
            
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
			on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatTiposPrestaciones TP with (nolock) 
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
		left join RH.tblTipoTrabajadorEmpleado tte with (nolock) 
			on e.IDEmpleado = tte.IDEmpleado
	where [ClaveNombreCompleto] like '%'+@search+'%'  
		and (e.Vigente = case when @tipo is not null then @tipo else e.Vigente end)
		--and (e.IDEmpleado <> case when @intranet = 1 then @IDEmpleado else 0  end)        
        and ((e.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
        and ((e.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
        and ((e.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
        and ((e.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))                      
        and ((e.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))                  
        and ((e.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))                
        and ((e.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))                    
        and ((e.ClaveEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleado'),',')))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClaveEmpleado' and isnull(Value,'')<>'')))                    
	    order by ClaveEmpleado asc
GO
