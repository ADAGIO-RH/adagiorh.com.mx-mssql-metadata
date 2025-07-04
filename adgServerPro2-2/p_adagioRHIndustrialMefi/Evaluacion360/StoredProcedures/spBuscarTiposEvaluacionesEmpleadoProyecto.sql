USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar la calificación por Tipo de evaluación en el proyecto de desempeño
** Autor			: ANEUDY ABREU COLON
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2023-12-18
** Paremetros		:              

** DataTypes Relacionados: 


	NOTA:
		Si el result set de este sp es modificado se debe modificar los sps:
			- Evaluacion360.spBuscarEmpleadoEvaluacionDesempenio
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarTiposEvaluacionesEmpleadoProyecto](
	@IDEmpleadoProyecto int ,
	@IDUsuario int
) as
	declare  
	   @IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		isnull(ee.IDEmpleadoProyecto		 , 0) as IDEmpleadoProyecto		
		,isnull(ee.IDTipoEvaluacion			 , 0) as IDTipoEvaluacion			
		,JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoEvaluacion	 
		,cast(sum(isnull(ee.Progreso				, 0))	/count(*) as decimal(10, 2)) as Progreso					
		,cast(sum(isnull(ee.Promedio				, 0.00))/count(*) as decimal(10, 2)) as Promedio					
		,cast(sum(isnull(ee.Porcentaje				, 0.00))/count(*) as decimal(10, 2)) as Porcentaje					
	from Evaluacion360.tblEvaluacionesEmpleados ee
		left join Evaluacion360.tblCatTiposEvaluaciones cte on cte.IDTipoEvaluacion = ee.IDTipoEvaluacion
	where ee.IDEmpleadoProyecto = @IDEmpleadoProyecto
	group by ee.IDEmpleadoProyecto,ee.IDTipoEvaluacion, cte.Traduccion
GO
