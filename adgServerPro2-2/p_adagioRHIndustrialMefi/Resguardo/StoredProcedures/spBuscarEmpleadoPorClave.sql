USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-09-14
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Resguardo].[spBuscarEmpleadoPorClave](  
	@ClaveEmpleado varchar(20)   
	,@IDUsuario	int
)as   
	select 
		e.IDEmpleado,
		e.ClaveEmpleado,
		e.Nombre,
		e.SegundoNombre,
		e.Paterno,
		e.Materno,
		e.NOMBRECOMPLETO as NombreCompleto,
		e.Departamento,
		e.Sucursal,
		e.Puesto,
		isnull(e.Vigente,0) as Vigente
	from [RH].[tblEmpleadosMaster] e with (nolock)
	where e.ClaveEmpleado = @ClaveEmpleado
	order by ClaveEmpleado asc
GO
