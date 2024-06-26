USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spSePuedoModificarElProyecto](  
	@IDProyecto int  
	,@IDUsuario int  
) as  
  
	declare  
		@IDEstatusProyecto int = 0  
	;  
  
	select top 1 
		@IDEstatusProyecto = tep.IDEstatus  
	from Evaluacion360.tblEstatusProyectos tep with (nolock) 
	where tep.IDProyecto = @IDProyecto  
	order by FechaCreacion desc  
  
	if (@IDEstatusProyecto IN (3,4,5,6))  
	begin  
		raiserror('Error, no se puede modificar el proyecto',16,1);
		--EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003'  
		return 0;  
	end;
GO
