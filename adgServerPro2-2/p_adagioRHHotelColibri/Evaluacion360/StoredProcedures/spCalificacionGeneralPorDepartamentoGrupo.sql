USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spCalificacionGeneralPorDepartamentoGrupo] (
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

if object_id('tempdb..#tempMainData') is not null 
    drop table #tempMainData;

 create table #tempMainData(
        IDDepartamento int,
        IDPuesto int,
        Departamento VARCHAR(max),
        Puesto VARCHAR(max),
        Nombre varchar(max),
        );

insert into #tempMainData (IDDepartamento,IDPuesto,Departamento,Puesto,Nombre)
Select  m.IDDepartamento,m.IDPuesto,m.Departamento,m.Puesto,catc.Nombre from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Where IDProyecto = @IDProyecto and IDTipoPregunta not in (4,10)

insert into #tempMainData (IDDepartamento,IDPuesto,Departamento,Puesto,Nombre)
Select  M.IDDepartamento,m.IDPuesto,m.Departamento,m.Puesto,pr.OpcionRespuesta  from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
where IDProyecto = @IDProyecto and creadoparaidtipopregunta = 10

Select * from #tempMainData
GO
