USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los colaboradores que no tienen lectores asignados
** Autor			: Joseph Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosSinLector]  --@IDLector = 1, @IDUsuario = 1  
(    
	 @FechaIni date = '1900-01-01',    
	 @Fechafin date = '9999-12-31',    
	 @IDUsuario int = 0,    
	 @EmpleadoIni Varchar(20) = '0',    
	 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	 @IDTipoNomina int = 0,    
	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY,    
	 @IDLector int    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN    
 SET FMTONLY OFF;


	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@empleados [RH].[dtEmpleados]    
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

    
   insert into @empleados    
   select  e.*        
   from RH.tblEmpleadosMaster    e
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
   where Vigente = 1    
   and e.IDEmpleado not in (Select IDEmpleado from Asistencia.tblLectoresEmpleados where IDLector =  @IDLector)    
   and  (ClaveEmpleado BETWEEN @EmpleadoIni AND @EmpleadoFin )      
     and ((e.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))       
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))      
   and ((IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))       
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))      
   and ((IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))       
      or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))      
   and ((IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))       
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))      
   and ((IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))       
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))  
	    and ((IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))      
 and ((IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
   and ((      
    ((COALESCE(ClaveEmpleado,'')+' '+ COALESCE(Paterno,'')+' '+COALESCE(Materno,'')+', '+COALESCE(Nombre,'')+' '+COALESCE(SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')         
        ) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))      
    
   
   select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @empleados

	select @TotalRegistros = COUNT(IDEmpleado) from @empleados		

	select 
	 IDEmpleado    
	  ,ClaveEmpleado    
	  ,NOMBRECOMPLETO    
	  ,Puesto    
	  ,Departamento    
	  ,Sucursal    
	  ,0 as IDLector    
	  ,'Ninguno' as Lector 
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from @empleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,		
		ClaveEmpleado asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
   


END
GO
