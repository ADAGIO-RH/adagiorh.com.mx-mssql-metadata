USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
[RH].[spBuscarEmpleadoByID] 1279,1

*/
CREATE PROCEDURE [RH].[spBuscarEmpleadoByID](  
	@IDEmpleado int
	,@IDUsuario int  
)  
AS  
BEGIN  
	--SET QUERY_GOVERNOR_COST_LIMIT 0;  
	declare  	
		@EmpleadoIni Varchar(20)   
		,@EmpleadoFin Varchar(20)  
		,@dtEmpleados [RH].[dtEmpleados]
	;
	
	select 
		@EmpleadoIni = ClaveEmpleado
		,@EmpleadoFin  = ClaveEmpleado
	from [RH].[tblempleados] with(nolock)
	where IDEmpleado = @IDEmpleado

	exec [RH].[spBuscarEmpleados]  
		@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@IDUsuario		= @IDUsuario
 
 END
GO
