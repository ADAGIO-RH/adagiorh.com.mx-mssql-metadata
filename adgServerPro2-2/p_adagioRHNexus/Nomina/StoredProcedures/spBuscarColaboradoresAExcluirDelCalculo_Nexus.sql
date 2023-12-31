USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	exec Nomina.spBuscarCatTipoNomina
Create proc [Nomina].[spBuscarColaboradoresAExcluirDelCalculo_Nexus](
	@FechaIni date
	,@FechaFin date
	,@empleados [RH].[dtEmpleados] readonly                  
	,@fechasUltimaVigencia [App].[dtFechasVigenciaEmpleado] readonly 
	,@IDPeriodo int
	,@ExcluirBajas bit =1 
	,@IDUsuario int                
) as
	declare
		@empleadosRespuesta [RH].[dtEmpleados],
		@IDTipoNomina int,
		@IDPais int,
		@fechaFinIncPeriodo date,
		@fechaFinPeriodo date
	--	@IDUsuario int = 1                  
	--	,@IDTipoNomina int  = 4                 
	--	,@IDPeriodo int = 104                  
	--	,@dtFiltros [Nomina].[dtFiltrosRH]                  
	--	,@isPreviewFiniquito bit=0        
	--	,@ExcluirBajas bit =1                
	--	,@AjustaISRMensual bit =0      

	select @IDTipoNomina = p.IDTipoNomina, @IDPais = TN.IDPais 
	,@fechaFinIncPeriodo = p.FechaFinIncidencia, @fechaFinPeriodo = p.FechaFinPago
	from Nomina.tblCatPeriodos p
		inner join Nomina.tblcattipoNomina TN
			on p.IDTipoNomina = TN.IDTipoNomina
		where p.IDPeriodo = @IDPeriodo
	
	print @IDPais
	IF(@IDPais not in ( 203, 9)) -- SANTA LUCIA y ANTIGUA
	BEGIN

		IF(@ExcluirBajas = 1)        
		BEGIN 
			insert @empleadosRespuesta
			select e.*
			from @empleados e
				join @fechasUltimaVigencia fuv on e.IDEmpleado = fuv.IDEmpleado
			where fuv.Vigente = 0
			--where IDEmpleado in (select IDEmpleado from @fechasUltimaVigencia where Vigente = 0) 
	
		END;
	END
	ELSE
	BEGIN --- EXCLUSION PARA SANTA LUCIA Y ANTIGUA
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
						and isnull(mov.RespetarAntiguedad,0) = 0
						)  
			END;
	END
	
	select *
	from @empleadosRespuesta
GO
