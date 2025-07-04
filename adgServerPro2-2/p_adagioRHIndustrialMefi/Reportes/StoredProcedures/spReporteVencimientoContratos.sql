USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteVencimientoContratos]
(      
     @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) AS
	declare 
	@dtEmpleados RH.dtEmpleados
   ,@TipoContratacion nvarchar(max) 
   ,@IDCliente int
   ,@EmpleadoIni varchar(20)
   ,@EmpleadoFin varchar(20)
   ,@FechaIni Date
   ,@FechaFin Date

	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	Select top 1 @TipoContratacion = Value from @dtFiltros where Catalogo = 'TipoContratacion'

    SET @EmpleadoIni	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	SET @FechaIni		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),getdate())
	SET @FechaFin		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),getdate())
   	;      
BEGIN      

insert @dtEmpleados  
		exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin        
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 
  


	 select 
	 EM.ClaveEmpleado as [CLAVE],
	 EM.NOMBRECOMPLETO as [Nombre Completo], 
	 EM.Departamento, 
	 EM.Puesto,
	 D.Descripcion as Documento,  
	 FORMAT(CE.FechaIni,'dd/MM/yyyy') as [Fecha Inicio],
	 FORMAT(CE.FechaFin,'dd/MM/yyyy') as [Fecha Fin], 
	 CE.Duracion,  
	 TC.Descripcion as [Tipo Contratacion]

	from RH.tblContratoEmpleado CE
	inner join @dtEmpleados  EM on CE.IDEmpleado = EM.IDEmpleado
	Inner join RH.tblCatDocumentos D on CE.IDDocumento = D.IDDocumento   
	Inner join Sat.tblCatTiposContrato TC on CE.IDTipoContrato = TC.IDTipoContrato 
	where (CE.IDTipoContrato in (select cast(Item as int) from App.Split(@TipoContratacion,',')) or @TipoContratacion is null) 
				AND CE.FechaFin BETWEEN @FechaIni AND @FechaFin
	ORDER BY EM.Sucursal ASC
  
  
END
GO
