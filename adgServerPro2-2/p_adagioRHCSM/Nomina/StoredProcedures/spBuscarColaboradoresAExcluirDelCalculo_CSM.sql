USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*ExcluirColaboradores*/
--	exec Nomina.spBuscarCatTipoNomina
CREATE proc [Nomina].[spBuscarColaboradoresAExcluirDelCalculo_CSM](
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
        @PTU BIT
    ;
        
    select @PTU = PTU from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo
	--	@IDUsuario int = 1                  
	--	,@IDTipoNomina int  = 4                 
	--	,@IDPeriodo int = 104                  
	--	,@dtFiltros [Nomina].[dtFiltrosRH]                  
	--	,@isPreviewFiniquito bit=0        
	--	,@ExcluirBajas bit =1                
	--	,@AjustaISRMensual bit =0      
	
	IF(@ExcluirBajas = 1 and isnull(@PTU, 0) != 1)        
	BEGIN 
		insert @empleadosRespuesta
		select e.*
		from @empleados e
			join @fechasUltimaVigencia fuv on e.IDEmpleado = fuv.IDEmpleado
		where fuv.Vigente = 0
		--where IDEmpleado in (select IDEmpleado from @fechasUltimaVigencia where Vigente = 0) 
	
	END;
	
	select *
	from @empleadosRespuesta
GO
