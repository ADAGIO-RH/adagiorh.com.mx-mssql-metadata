USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarJefesEmpleadosListaAsignar]              
(              
 @IDJefe int,          
 @IDUsuario int = 0,                                      
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY              
)              
AS              
BEGIN  
	declare 
		@dtEmpleados RH.dtEmpleados
		,@FechaIni date = getdate()
		,@FechaFin date = getdate()
		;

	insert @dtEmpleados
	exec RH.spBuscarEmpleados 
		@FechaIni = @FechaIni
		, @FechaFin = @FechaFin
		, @IDUsuario = @IDUsuario
		, @dtFiltros = @dtFiltros

	select * 
	from @dtEmpleados e
	--RH.tblEmpleadosMaster E
	--	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios deu
	--		on deu.IDUsuario = @IDUsuario and e.IDEmpleado =deu.IDEmpleado
	--WHERE ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
	--	   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
	--   and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
	--	   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
	--   and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
	--	  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
	--   and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
	--   and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
	--   and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
	--   and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
	--   and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
	-- and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
	--   and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))        
	-- and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))               
	--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
             
	--   and ((              
	--	((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')                
 
	--		) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>''))) 
	--	and e.IDEmpleado not in (select IDEmpleado from RH.[tblJefesEmpleados] where IDJefe = @IDJefe )

		where e.IDEmpleado <> @IDJefe and e.IDEmpleado not in (select IDEmpleado from RH.[tblJefesEmpleados] with (nolock) where IDJefe = @IDJefe )

END
GO
