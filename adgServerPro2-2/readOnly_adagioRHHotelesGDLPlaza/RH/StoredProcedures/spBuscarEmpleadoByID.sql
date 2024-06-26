USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [RH].[spBuscarEmpleadoByID]  
(  
  @IDEmpleado int
 ,@IDUsuario int  
)  
AS  
BEGIN  
SET QUERY_GOVERNOR_COST_LIMIT 0;  
Declare  
--@FechaIni date = '2018-03-16',  
-- @Fechafin date = '2018-03-31',  
-- @IDUsuario int = 0,  
 @EmpleadoIni Varchar(20)   
 ,@EmpleadoFin Varchar(20)  
 ,@dtEmpleados [RH].[dtEmpleados]
-- @IDTipoNomina int = 2,  
-- @dtFiltros [Nomina].[dtFiltrosRH]   
  
--insert into @dtFiltros  
--values('Departamentos','')  
--insert into @dtFiltros  
--values('Sucursales','')  
--insert into @dtFiltros  
--values('Puestos','')  
--insert into @dtFiltros  
--values('Prestaciones','')  
--delete  @dtFiltros  
  
  select 
	  @EmpleadoIni = ClaveEmpleado
	 ,@EmpleadoFin  = ClaveEmpleado
  from [RH].[tblempleados]
  where IDEmpleado = @IDEmpleado


	exec [RH].[spBuscarEmpleados]  
		@EmpleadoIni = @EmpleadoIni
		,@EmpleadoFin  = @EmpleadoFin
		,@IDUsuario = @IDUsuario
 
END
GO
