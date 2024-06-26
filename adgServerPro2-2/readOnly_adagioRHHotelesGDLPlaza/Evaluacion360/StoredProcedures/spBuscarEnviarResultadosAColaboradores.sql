USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spBuscarEnviarResultadosAColaboradores(
	@IDProyecto int
	,@IDUsuario int
) as
--	select * from Evaluacion360.tblCatProyectos

	--declare @IDProyecto int = 5
	
	select ep.IDEmpleadoProyecto
		  ,ep.IDEmpleado
		  ,e.ClaveEmpleado
		  ,e.NOMBRECOMPLETO as NombreCompleto
		  ,isnull(erac.IDEnviarResultadosAColaboradores,0) IDEnviarResultadosAColaboradores
		  ,isnull(erac.Valor,0) Valor
	from Evaluacion360.tblEmpleadosProyectos ep 
		join RH.tblEmpleadosMaster e on ep.IDEmpleado = e.IDEmpleado
		left join Evaluacion360.tblEnviarResultadosAColaboradores erac on erac.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	where ep.IDProyecto = @IDProyecto
GO
