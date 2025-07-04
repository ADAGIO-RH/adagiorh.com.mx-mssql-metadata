USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spBuscarFiltrosProyectoDistinct](
	@IDFiltroProyecto int = 0,
	@IDProyecto int = 0 
) AS
	SELECT  
		DISTINCT IDFiltroProyecto = CASE
										WHEN FP.TipoFiltro = 'Empleados' OR FP.TipoFiltro = 'Excluir Empleado'
											THEN 0
											ELSE FP.IDFiltroProyecto
										END,
				 FP.IDProyecto,
				 --FP.TipoFiltro,
				 TipoFiltro = CASE
								WHEN FP.TipoFiltro = 'Empleados' OR FP.TipoFiltro = 'Excluir Empleado' 
									THEN FP.TipoFiltro
									ELSE COALESCE(FP.TipoFiltro, '') + ' | ' + COALESCE(FP.Descripcion, '')
								END,
				 Descripcion = CASE 
								WHEN FP.TipoFiltro = 'Empleados' OR FP.TipoFiltro = 'Excluir Empleado' 
									THEN TP.Descripcion
									ELSE COALESCE(TP.Descripcion, '') + ' | ' + COALESCE(FP.Descripcion, '')
								END,
				 TP.DOMElementID,
				 Evaluar = CASE
								WHEN FP.TipoFiltro = 'Excluir Empleado'
									THEN 'false'
									ELSE 'true'
								END
		FROM [Evaluacion360].[tblFiltrosProyectos] FP
			JOIN [Seguridad].[tblCatTiposFiltros] TP ON FP.TipoFiltro = TP.Filtro  
	WHERE (FP.IDFiltroProyecto = @IDFiltroProyecto OR @IDFiltroProyecto = 0) AND
		  (FP.IDProyecto = @IDProyecto or @IDProyecto = 0)
GO
