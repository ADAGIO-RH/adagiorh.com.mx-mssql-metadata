USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteVencimientoContratosPersonal]
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
   ,@IDTipoVigente int


	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	Select top 1 @TipoContratacion = Value from @dtFiltros where Catalogo = 'TipoContratacion'

    SET @EmpleadoIni	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	SET @FechaIni		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),getdate())
	SET @FechaFin		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),getdate())
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

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
  

  
	if(@IDTipoVigente = 1)
	BEGIN
	 select 
	 EM.ClaveEmpleado as [CLAVE],
	 EM.NOMBRECOMPLETO as [Nombre Completo], 
	 EM.Region,
	 EM.Sucursal,
	 EM.Departamento, 
	 EM.Puesto,
	 D.Descripcion as Documento,  
	 FORMAT(CE.FechaIni,'dd/MM/yyyy') as [Fecha Inicio],
	 FORMAT(CE.FechaFin,'dd/MM/yyyy') as [Fecha Fin], 
	 CE.Duracion,  
	 TC.Descripcion as [Tipo Contratacion],
	 ctt.Descripcion as [TIPO TRABAJADOR SUA],
	 (Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = CE.IDEmpleado
				) as Supervisor
				
	from RH.tblContratoEmpleado CE
	inner join rh.tblEmpleadosMaster  EM on CE.IDEmpleado = EM.IDEmpleado
	Inner join RH.tblCatDocumentos D on CE.IDDocumento = D.IDDocumento   
	Inner join Sat.tblCatTiposContrato TC on CE.IDTipoContrato = TC.IDTipoContrato 
	left join rh.tblTipoTrabajadorEmpleado tte on tte.IDEmpleado = ce.IDEmpleado
	inner join IMSS.tblCatTipoTrabajador ctt on ctt.IDTipoTrabajador = tte.IDTipoTrabajador
	where (CE.IDTipoContrato in (select cast(Item as int) from App.Split(@TipoContratacion,',')) or @TipoContratacion is null) 
				AND CE.FechaFin BETWEEN @FechaIni AND @FechaFin  and EM.Vigente =1
	ORDER BY EM.Sucursal ASC
  
  	END
END
GO
