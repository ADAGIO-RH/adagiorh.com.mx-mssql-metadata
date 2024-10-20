USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spPreguntasDeRespuestaAbierta] (
	@IDProyecto int, 
    @IDUsuario int
) as

--declare 
--	@IDEmpleadoProyecto int = 42293
--	,@IDUsuario int = 1
--	;
	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END


	
declare 
	@Privacidad bit = 1,
	@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3
	;


select @Privacidad= case when IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL then 1 else Privacidad end
from Evaluacion360.tblCatProyectos
where IDProyecto = @IDProyecto

if object_id('tempdb..#tempMainData') is not null 
    drop table #tempMainData;

 
Select 
	cp.Nombre as PROYECTO,
	cp.Descripcion as DESCRIPCION_PROYECTO,
	catc.Nombre as GRUPO,
	catc.Descripcion as DESCRIPCION_GRUPO,
	case when isnull(@Privacidad, 0) = 1 then 'ANÓMINO' else M.ClaveEmpleado end as ClaveEmpleado,
	case when isnull(@Privacidad, 0) = 1 then 'ANÓMINO' else M.NOMBRECOMPLETO end as EVALUADO,
	case when isnull(@Privacidad, 0) = 1 then 'ANÓMINO' else EM.NOMBRECOMPLETO end EVALUADOR,
	catp.Descripcion as PREGUNTA,
	catc.Nombre as INDICADOR,
	resp.Respuesta,
	M.Departamento	Departamento_Evaluado	,
	M.Sucursal		Sucursal_Evaluado	,
	M.Puesto		Puesto_Evaluado

from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
	left join Evaluacion360.tblCatIndicadores i on i.IDIndicador = catp.IDIndicador
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
inner join Evaluacion360.tblCatProyectos cp on ep.IDProyecto = cp.IDProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Inner join rh.tblEmpleadosMaster EM on EM.IDEmpleado = eve.IDEvaluador
Where cp.IDProyecto = @IDProyecto and IDTipoPregunta  in (4)




GO
