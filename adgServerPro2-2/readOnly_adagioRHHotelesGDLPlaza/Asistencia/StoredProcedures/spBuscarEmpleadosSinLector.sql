USE [readOnly_adagioRHHotelesGDLPlaza]
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
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosSinLector]    
(    
 @FechaIni date = '1900-01-01',    
 @Fechafin date = '9999-12-31',    
 @IDUsuario int = 0,    
 @EmpleadoIni Varchar(20) = '0',    
 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
 @IDTipoNomina int = 0,    
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY,    
 @IDLector int    
)    
AS    
BEGIN    
 DECLARE @empleados [RH].[dtEmpleados]    
    
   insert into @empleados    
   select  e.*        
   from RH.tblEmpleadosMaster    e
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
   where Vigente = 1    
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
    
    
   select 
	   IDEmpleado    
	  ,ClaveEmpleado    
	  ,NOMBRECOMPLETO    
	  ,Puesto    
	  ,Departamento    
	  ,Sucursal    
	  ,0 as IDLector    
	  ,'Ninguno' as Lector     
   from @empleados     
   where IDEmpleado not in (Select IDEmpleado from Asistencia.tblLectoresEmpleados where IDLector =  @IDLector)    
    
END
GO
