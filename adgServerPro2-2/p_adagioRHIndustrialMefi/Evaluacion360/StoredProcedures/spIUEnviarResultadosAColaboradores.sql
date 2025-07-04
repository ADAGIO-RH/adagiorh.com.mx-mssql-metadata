USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Evaluacion360.spIUEnviarResultadosAColaboradores(
	 @IDEnviarResultadosAColaboradores int = 0
	,@IDEmpleadoProyecto int  
	,@Valor bit
	,@IDUsuario int
) as 
	if not exists(select top 1 1 
		from Evaluacion360.tblEnviarResultadosAColaboradores 
		where IDEmpleadoProyecto = @IDEmpleadoProyecto)
	begin
		insert Evaluacion360.tblEnviarResultadosAColaboradores(IDEmpleadoProyecto,Valor)
		select @IDEmpleadoProyecto,@Valor
	end else 
	begin
		update Evaluacion360.tblEnviarResultadosAColaboradores
			set Valor = @Valor 
		where IDEmpleadoProyecto = @IDEmpleadoProyecto
	end;
GO
