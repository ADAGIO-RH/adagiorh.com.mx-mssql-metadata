USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarColaboradoresABorrarDetallePeriodo](
		@IDUsuario int                   
		,@IDTipoNomina int                   
		,@IDPeriodo int = 0                  
		,@dtFiltros [Nomina].[dtFiltrosRH] readonly                
		,@isPreviewFiniquito bit=0        
		,@ExcluirBajas bit =1                
		,@AjustaISRMensual bit =0 
) as 
	declare                   
		@i int = 0                   
		,@IDPeriodoSeleccionado int=0                  
		,@periodo [Nomina].[dtPeriodos]                  
		,@configs [Nomina].[dtConfiguracionNomina]                  
		,@empleados [RH].[dtEmpleados]                  
		,@empleadosEliminarDelCalculo [RH].[dtEmpleados]                  
		,@Conceptos [Nomina].[dtConceptos]                  
		,@DetallePeriodo [Nomina].[dtDetallePeriodo]                  
		,@spConcepto nvarchar(255)                  
		,@IDConcepto int = 0                  
		,@CodigoConcepto varchar(20)                  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date      
		,@fechaIniIncPeriodo  date                  
		,@fechaFinIncPeriodo  date             
		,@Homologa varchar(10)
		,@dtEmpleadosMovimientoSalario RH.dtEmpleados 
		,@dtEmpleadosAEliminarDelCalculo RH.dtEmpleados 
		,@fechas [App].[dtFechas]   
		,@fechasUltimaVigencia [App].[dtFechas]              
		,@ListaFechasUltimaVigencia [App].[dtFechasVigenciaEmpleado]

	;

	/* Se busca el ID de periodo seleccionado del tipo de nómina */                  
	IF(isnull(@IDPeriodo,0)=0)                  
	BEGIN                   
		select @IDPeriodoSeleccionado = IDPeriodo                  
		from Nomina.tblCatTipoNomina with (nolock)                 
		where IDTipoNomina=@IDTipoNomina                  
		END                  
	ELSE                  
	BEGIN                  
		set @IDPeriodoSeleccionado = @IDPeriodo                  
	END                  
                  
	select 
		@fechaIniPeriodo	= FechaInicioPago
		,@fechaFinPeriodo	= FechaFinPago
		,@fechaIniIncPeriodo	= FechaInicioIncidencia 
		,@fechaFinIncPeriodo	= FechaFinIncidencia                  
	from Nomina.TblCatPeriodos with (nolock)                
	where IDPeriodo = @IDPeriodoSeleccionado               
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	if(isnull(@isPreviewFiniquito,0) = 0 )
	BEGIN             
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros  , @IDUsuario = @IDUsuario                
	END
	ELSE
	BEGIN
		-- Si es un Preview de finiquitos no hacemos nada
		select *
		from @empleados
		return
	END 

	insert into @fechasUltimaVigencia
	exec [App].[spListaFechas]@fechaFinPeriodo,@fechaFinPeriodo
	
	insert @ListaFechasUltimaVigencia
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @empleados,@fechasUltimaVigencia,@IDUsuario

	insert @empleadosEliminarDelCalculo
	exec Nomina.spBuscarColaboradoresAExcluirDelCalculo
		@FechaIni				= @fechaIniPeriodo
		,@FechaFin				= @fechaIniPeriodo
		,@empleados				= @empleados        
		,@fechasUltimaVigencia	= @ListaFechasUltimaVigencia
		,@IDPeriodo				= @IDPeriodoSeleccionado  
		,@ExcluirBajas			= @ExcluirBajas
		,@IDUsuario				= @IDUsuario

	select distinct e.*
	from Nomina.tblDetallePeriodo dp with (nolock)
		join @empleadosEliminarDelCalculo e on dp.IDEmpleado = e.IDEmpleado
	where
	--dp.IDEmpleado in (select IDEmpleado from @empleadosEliminarDelCalculo) 
		dp.IDPeriodo = @IDPeriodoSeleccionado 
		and dp.IDEmpleado not in (Select IDEmpleado 
								from Nomina.tblControlFiniquitos f with (nolock)
								join Nomina.tblCatEstatusFiniquito ef with (nolock) on f.IDEStatusFiniquito = ef.IDEStatusFiniquito 
								where IDPeriodo = @IDPeriodoSeleccionado and ef.Descripcion = 'Aplicar')   
	--select e.*
	--from @empleados e
	--	join @empleadosEliminarDelCalculo d on e.IDEmpleado = d.IDEmpleado
GO
