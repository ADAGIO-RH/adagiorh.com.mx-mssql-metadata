USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	exec Nomina.spBuscarCatTipoNomina
CREATE proc [Nomina].[spBuscarColaboradoresAExcluirDelCalculo](
	@FechaIni date
	,@FechaFin date
	,@empleados [RH].[dtEmpleados] readonly                  
	,@fechasUltimaVigencia [App].[dtFechasVigenciaEmpleado] readonly 
	,@IDPeriodo int
	,@ExcluirBajas bit =1 
	,@IDUsuario int                
) as
declare
		@empleadosRespuesta [RH].[dtEmpleados]
		,@fechaFinIncPeriodo date
		,@fechaFinPeriodo date
	--	@IDUsuario int = 1                  
	--	,@IDTipoNomina int  = 4                 
	--	,@IDPeriodo int = 104                  
	--	,@dtFiltros [Nomina].[dtFiltrosRH]                  
	--	,@isPreviewFiniquito bit=0        
	--	,@ExcluirBajas bit =1                
	--	,@AjustaISRMensual bit =0     
	
	select top 1 @fechaFinIncPeriodo = FechaFinIncidencia, @fechaFinPeriodo = FechaFinPago from Nomina.tblCatPeriodos 
	where IDPeriodo = @IDPeriodo
	 
	
	IF(@ExcluirBajas = 1)        
	BEGIN 
		insert @empleadosRespuesta
		select e.*
		from @empleados e
			join @fechasUltimaVigencia fuv on e.IDEmpleado = fuv.IDEmpleado
		where fuv.Vigente = 0
		--where IDEmpleado in (select IDEmpleado from @fechasUltimaVigencia where Vigente = 0) 
	
		insert @empleadosRespuesta
		select e.*
		from @empleados e 
		where e.IDEmpleado in (Select Mov.IDEmpleado from IMSS.tblMovAfiliatorios mov        
				inner join IMSS.tblCatTipoMovimientos tmov        
				on mov.IDTipoMovimiento = tmov.IDTipoMovimiento        
				where tmov.Codigo in('A','R')        
				and mov.Fecha between dateadd(day,1,@fechaFinIncPeriodo) and @fechaFinPeriodo       
				)  


	END;
	
	select *
	from @empleadosRespuesta
	where IDEmpleado not in (select IDEmpleado from Nomina.tblControlFiniquitos where IDPeriodo = @IDPeriodo)
GO
