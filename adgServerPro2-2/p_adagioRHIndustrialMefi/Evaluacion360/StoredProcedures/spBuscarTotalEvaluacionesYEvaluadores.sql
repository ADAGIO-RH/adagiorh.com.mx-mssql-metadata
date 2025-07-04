USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los totales de las pruebas de un proyecto
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
CREATE proc [Evaluacion360].[spBuscarTotalEvaluacionesYEvaluadores] (
	@IDProyecto int 
	,@IDUsuario int
) as

	declare 
		@TotalEmpleados int
		,@TotalPruebas int
		,@TotalAutoEvaluaciones int

	select @TotalEmpleados = Count(ep.IDEmpleadoProyecto) 
	from [Evaluacion360].[tblEmpleadosProyectos] ep
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where IDProyecto = @IDProyecto

	--select * from [Evaluacion360].[tblCatTiposRelaciones]
	select @TotalPruebas = SUM(Minimo)
	from [Evaluacion360].[tblEvaluadoresRequeridos]
	where IDTipoRelacion <> 4 AND IDProyecto = @IDProyecto

	select @TotalAutoEvaluaciones = SUM(Maximo)
	from [Evaluacion360].[tblEvaluadoresRequeridos]
	where IDTipoRelacion = 4 AND IDProyecto = @IDProyecto

	select 
		  isnull(@TotalPruebas,0) as TotalEvaluadoresPorPersona
		, isnull(@TotalEmpleados,0) as TotalPersonasAEvaluar
		, isnull(@TotalPruebas * @TotalEmpleados,0) as TotalPruebasARealizar
		, isnull((@TotalPruebas * @TotalEmpleados),0)  as TotalDeEvaluadores
		, ISNULL(@TotalAutoEvaluaciones * @TotalEmpleados,0) as TotalAutoEvaluaciones


--select * from [Evaluacion360].[tblEstatusEvaluacionEmpleado] order by IDEvaluacionEmpleado
--insert into [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
--select 105580,12,1
--select * from Evaluacion360.tblCatEstatus
GO
