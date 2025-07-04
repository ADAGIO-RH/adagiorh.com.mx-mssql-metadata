USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarEjercicios] as  
	declare @ejercicioInicial int   
		,@ejercicioFinal int = datepart(YEAR,getdate())  
		,@maxEjercicio int = 0  
	;  
  
	select   
		@ejercicioInicial = MIN(Ejercicio)   
		,@maxEjercicio = max(Ejercicio)   
	from Nomina.tblCatPeriodos  
  
	set @ejercicioFinal = case when @maxEjercicio > @ejercicioFinal then @maxEjercicio else @ejercicioFinal end  
  
	;with cte_n as (  
		select @ejercicioInicial as Ejercicio  
		union all  
		select Ejercicio+1 from cte_n   
		where Ejercicio < @ejercicioFinal  
	) 
	select ISNULL(Ejercicio, datepart(year,GETDATE())) as Ejercicio
	from cte_n order by Ejercicio desc option (maxrecursion 0)
GO
