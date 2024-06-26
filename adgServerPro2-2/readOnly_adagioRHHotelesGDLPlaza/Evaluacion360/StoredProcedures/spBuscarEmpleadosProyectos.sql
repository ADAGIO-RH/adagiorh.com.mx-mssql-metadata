USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los colaboradores que están asignados a una prueba
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
CREATE proc [Evaluacion360].[spBuscarEmpleadosProyectos](
	@IDProyecto int = null
	,@IDEmpleadoProyecto int = null
	,@TipoFiltro  varchar(255)   = null
	,@IDUsuario int
) as
	SET LANGUAGE 'Spanish';

	select ep.IDEmpleadoProyecto
			,ep.IDProyecto
			,ep.IDEmpleado
			,em.ClaveEmpleado
			,em.NOMBRECOMPLETO
			,em.Departamento
			,em.Sucursal
			,em.Puesto
			,'Del '+CONVERT(VARCHAR(100),isnull(P.FechaInicio,getdate()),106)+' al '+CONVERT(VARCHAR(100),isnull(P.FechaFin,getdate()),106) as CicloEvaluacion
			,isnull(ep.TipoFiltro,'Empleados') as TipoFiltro
	from [Evaluacion360].[tblEmpleadosProyectos] ep  with (nolock)
		join [RH].[tblEmpleadosMaster] em  with (nolock) on ep.IDEmpleado = em.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		join [Evaluacion360].[tblCatProyectos] p with (nolock) on ep.IDProyecto = p.IDProyecto
	where (ep.IDProyecto = @IDProyecto or @IDProyecto is null) 
		and (ep.IDEmpleadoProyecto = @IDEmpleadoProyecto or @IDEmpleadoProyecto is null)
		and (isnull(ep.TipoFiltro,'Empleados') = @TipoFiltro or @TipoFiltro is null)
	order by em.ClaveEmpleado
GO
