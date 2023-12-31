USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spCalificacionGeneralPorPuesto_Sub] (
	@IDProyecto int, 
    @IDPuesto int,
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
        Puesto VARCHAR(max),
        NombreGrupo varchar(max),
        Porcentaje DECIMAL(10,2)
        );

Insert into #tempDummy(IDProyecto,Nombre,Puesto,NombreGrupo,Porcentaje)
Select  IDProyecto,M.NOMBRECOMPLETO,M.Puesto,catc.Nombre,Porcentaje from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Where IDProyecto = @IDProyecto And IDPuesto = @IDPuesto


insert into #tempDummy(IDProyecto,Nombre,Puesto,NombreGrupo,Porcentaje)
Select  IDProyecto,M.NOMBRECOMPLETO,M.Puesto,OpcionRespuesta,(SUM(Valor) * 100) / (COUNT(VALOR) * NUM)  as PORCENTAJE  from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
CROSS JOIN (SELECT MAX(VALOR) AS NUM from Evaluacion360.tblRespuestasPreguntas resp
            Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
            Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
            Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto WHERE IDPROYECTO = 18 ) AS CROS
where IDProyecto = @IDProyecto and creadoparaidtipopregunta = 10 and m.IDPuesto = @IDPuesto
GROUP by IDproyecto,M.NOMBRECOMPLETO,M.Puesto,OPCIONRESPUESTA,NUM


Insert into #tempDummy(IDProyecto,Nombre,Puesto,NombreGrupo,Porcentaje)
Select 0,null,'null',null, 100 - SUM(Porcentaje) / COUNT(Porcentaje) from #tempDummy


Select IDProyecto,Puesto,SUM(Porcentaje)/COUNT(Porcentaje)as Total from #tempDummy
Group by Puesto,IDProyecto

GO
