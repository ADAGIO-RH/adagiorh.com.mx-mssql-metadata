USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spCalificacionGeneralPorDepartamento_SubDeptGrupo] (
	@IDProyecto int, 
    @IDDepartamento int,
    @NombreGrupo VARCHAR(max),
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

if object_id('tempdb..#tempDummy') is not null 
    drop table #tempDummy;

 create table #tempDummy(
        IDProyecto int,
        Nombre varchar(max),
        Departamento VARCHAR(max),
        NombreGrupo varchar(max),
        Porcentaje DECIMAL(10,2)
        );

Insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select  IDProyecto,M.NOMBRECOMPLETO,M.Departamento,catc.Nombre,Porcentaje from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Where IDProyecto = @IDProyecto And IDDepartamento = @IDDepartamento and catc.Nombre = @NombreGrupo and IDTipoPregunta not in (4,10)

insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select  IDProyecto,M.NOMBRECOMPLETO,M.Departamento,OpcionRespuesta,(SUM(Valor) * 100) / (COUNT(VALOR) * NUM)  as PORCENTAJE  from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
CROSS JOIN (SELECT MAX(VALOR) AS NUM from Evaluacion360.tblRespuestasPreguntas resp
            Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
            Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
            Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto WHERE IDPROYECTO = 18 ) AS CROS
where IDProyecto = @IDProyecto and creadoparaidtipopregunta = 10 and IDDepartamento = @IDDepartamento and OpcionRespuesta = @NombreGrupo
GROUP by IDproyecto,M.NOMBRECOMPLETO,M.DEPARTAMENTO,OPCIONRESPUESTA,NUM,M.IDEmpleado


Insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select 0,null,'null','null', 100 - SUM(Porcentaje) / COUNT(Porcentaje) from #tempDummy


Select IDProyecto,NombreGrupo,SUM(Porcentaje)/COUNT(Porcentaje)as Total from #tempDummy
Group by NombreGrupo,IDProyecto

GO
