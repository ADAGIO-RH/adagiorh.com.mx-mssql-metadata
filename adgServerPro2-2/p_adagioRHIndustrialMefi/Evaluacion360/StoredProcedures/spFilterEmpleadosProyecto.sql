USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los empleados que están asignados al proyecto y que cumplan con el filtro recibido por parámetro
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
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
CREATE proc [Evaluacion360].[spFilterEmpleadosProyecto](  
  @IDUsuario int 
  ,@IDProyecto int
  ,@filter varchar(max)   
)as  
  
--declare   
    --@FechaIni date = '1900-01-01',  
    --@Fechafin date = '9999-12-31',  
    --@empleados [RH].[dtEmpleados]  
    --,@dtFiltros [Nomina].[dtFiltrosRH];  
  
    --insert into @dtFiltros(Catalogo,Value)  
    --select 'NombreClaveFilter',@filter  
  
  --  insert into @empleados  
    --exec [RH].[spBuscarEmpleados]   
    --@IDUsuario=@IDUsuario  
    --,@dtFiltros = @dtFiltros  
  
    select e.*
    from  [RH].[tblEmpleadosMaster] e WITH (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep WITH (nolock) on e.IDEmpleado = ep.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
    where [ClaveNombreCompleto] like '%'+@filter+'%' and ep.IDProyecto = @IDProyecto
    order by ClaveEmpleado asc
GO
