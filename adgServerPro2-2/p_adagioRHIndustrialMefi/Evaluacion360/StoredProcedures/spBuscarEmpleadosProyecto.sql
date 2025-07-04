USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los empleados de un proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarEmpleadosProyecto](
	@IDProyecto int
	,@IDUsuario int
) as
select ep.* 
from Evaluacion360.tblEmpleadosProyectos  ep
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
where ep.IDProyecto =@IDProyecto
GO
