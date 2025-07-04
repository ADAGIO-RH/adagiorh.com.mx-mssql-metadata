USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePropinaFondoValesViva] --1,4,22,1
(
	@IDCliente int
	,@IDTipoNomina int
	,@IDPeriodo int
	,@RazonesSociales varchar(max)		= ''
	,@Sucursales varchar(max)		= ''
	,@Departamentos varchar(max)	= ''
	,@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@FechaInicio Date
		,@FechaFin Date
		,@empleados [RH].[dtEmpleados]      
		,@IDConceptoPFV int
		,@IDConceptoPropinaFondo int
		,@IDConceptoPropinaVales int
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		
		select top 1 @IDConceptoPFV = IDConcepto from Nomina.tblCatConceptos where Codigo = '403' 
		select top 1 @IDConceptoPropinaFondo = IDConcepto from Nomina.tblCatConceptos where Codigo = '401' 
		select top 1 @IDConceptoPropinaVales = IDConcepto from Nomina.tblCatConceptos where Codigo = '402' 

  
  
	insert @dtFiltros(Catalogo,Value)    
	values
		('Departamentos',isnull(@Departamentos,''))    
		,('Sucursales',isnull(@Sucursales,''))    
		,('RazonesSociales',isnull(@RazonesSociales,''))

	Select @FechaInicio = p.FechaInicioPago
		  ,@FechaFin = p.FechaFinPago
	from Nomina.tblCatPeriodos p
	Where IDPeriodo = @IDPeriodo
	
  insert into @empleados     
  exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @FechaInicio, @Fechafin= @FechaFin ,@dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario                  
 
 -- select * from @empleados

	SELECT 
		   e.ClaveEmpleado,
		   e.NOMBRECOMPLETO as Nombre,
		   e.Empresa as RazonSocial,
		   e.Sucursal,
		   e.Departamento,
		   e.RegPatronal,
		   dpPF.ImporteTotal1 as PropinaFondo,
		   dpPV.ImporteTotal1 as PropinaVales,
		   dpPFV.ImporteTotal1 as PropinaFondoVales

	FROM Nomina.tblDetallePeriodo dpPFV
		inner join @empleados e
			on e.IDEmpleado = dpPFV.IDEmpleado
			and dpPFV.IDConcepto = @IDConceptoPFV 
			and dpPFV.IDPeriodo = @IDPeriodo
		LEFT JOIN Nomina.tblDetallePeriodo dpPF
			on dpPF.IDEmpleado = e.IDEmpleado
			and dpPF.IDConcepto = @IDConceptoPropinaFondo
			and dpPF.IDPeriodo = @IDPeriodo
		LEFT JOIN Nomina.tblDetallePeriodo dpPV
			on dpPV.IDEmpleado = e.IDEmpleado
			and dpPV.IDConcepto = @IDConceptoPropinaVales
			and dpPV.IDPeriodo = @IDPeriodo
		--LEFT JOIN Nomina.tblDetallePeriodo dpPF
		--	on dpPF.IDEmpleado = e.IDEmpleado
		--left join Nomina.tblCatConceptos cPF
		--	on cPF.IDConcepto = dpPF.IDConcepto
		--	and cPF.IDConcepto = @IDConceptoPropinaFondo
		--LEFT JOIN Nomina.tblDetallePeriodo dpPV
		--	on dpPV.IDEmpleado = e.IDEmpleado
		--left join Nomina.tblCatConceptos cPV
		--	on cPV.IDConcepto = dpPF.IDConcepto
		--	and cPV.IDConcepto = @IDConceptoPropinaVales
		
	ORDER BY E.ClaveEmpleado	
	
END
GO
