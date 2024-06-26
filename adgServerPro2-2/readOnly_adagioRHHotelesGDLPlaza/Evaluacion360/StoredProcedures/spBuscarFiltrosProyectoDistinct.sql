USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarFiltrosProyectoDistinct](
	@IDFiltroProyecto int = 0
	,@IDProyecto int = 0 
) as
	select  
		distinct 
			IDFiltroProyecto = case when TipoFiltro = 'Empleados' then 0
							else IDFiltroProyecto
							end
			,IDProyecto
			,TipoFiltro = case when TipoFiltro = 'Empleados' then TipoFiltro
							else coalesce(TipoFiltro,'')+ ' | '+coalesce(Descripcion,'')
							end
	from [Evaluacion360].[tblFiltrosProyectos]
	where (IDFiltroProyecto = @IDFiltroProyecto or @IDFiltroProyecto = 0) and (IDProyecto = @IDProyecto or @IDProyecto = 0)
GO
