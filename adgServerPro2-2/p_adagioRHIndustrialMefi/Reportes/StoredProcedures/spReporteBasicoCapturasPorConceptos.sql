USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoCapturasPorConceptos](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)as
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int = 1

	--insert into @dtFiltros(Catalogo,Value)
	--values('IDPeriodoInicial','98')
	--	--,('CatalogoConceptos','219')

	declare 
		@empleados [RH].[dtEmpleados]        
		,@IDPeriodo int=0        
 
		,@Conceptos nvarchar(max)   
		,@IDTipoNomina int     
		,@FechaIniPeriodo  date        
		,@FechaFinPeriodo  date        
	;    


	Select top 1 @Conceptos = Value from @dtFiltros where Catalogo = 'CatalogoConceptos'
	set @IDPeriodo = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
		else 0  
		END 

	select 
		@FechaIniPeriodo = p.FechaInicioPago
		,@FechaFinPeriodo = p.FechaFinPago	
	from Nomina.tblCatPeriodos p with (nolock)
	where p.IDPeriodo = @IDPeriodo

	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
			else 0  
		END 

	insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	Select  
		e.ClaveEmpleado as[Clave Empleado]
		,e.NOMBRECOMPLETO as 'Nombre'
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.Division
		,replace(replace(replace(c.Codigo+'_'+c.Descripcion,' ','_'),'-',''),'.','') as Concepto
		,isnull(dp.CantidadMonto,0) as [Cantidad Monto]  
		,isnull(dp.CantidadDias,0)  as [Cantidad Dias]  
		,isnull(dp.CantidadVeces,0) as [Cantidad Veces]  
		,isnull(dp.CantidadOtro1,0) as [Cantidad Otro 1]  
		,isnull(dp.CantidadOtro2,0) as [Cantidad Otro 2]  
		,isnull(dp.ImporteGravado,0) as [Importe Gravado]  
		,isnull(dp.ImporteExcento,0) as [Importe Exento] 
		,isnull(dp.ImporteTotal1,0) as [Importe Total 1]  
		,isnull(dp.ImporteTotal2,0) as [Importe Total 2]  
		,isnull(dp.ImporteAcumuladoTotales,0) as [Importe Acumulado Totales]  
	from Nomina.tblCatPeriodos P with (nolock) 
		inner join Nomina.tblDetallePeriodo dp  with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo  
		inner join Nomina.tblCatConceptos c with (nolock)  
			on C.IDConcepto = dp.IDConcepto  
		Inner join Nomina.tblCatTipoConcepto tc  with (nolock) 
			on tc.IDTipoConcepto = c.IDTipoConcepto  
		inner join @empleados e  
			on dp.IDEmpleado = e.IDEmpleado  
	where p.IDPeriodo = @IDPeriodo
		and (dp.IDConcepto in (select cast(Item as int) from App.Split(@Conceptos,',')) or @Conceptos is null)
		and (
		isnull(dp.CantidadMonto,0)
		+isnull(dp.CantidadDias,0) 
		+isnull(dp.CantidadVeces,0)
		+isnull(dp.CantidadOtro1,0)
		+isnull(dp.CantidadOtro2,0)
		+isnull(dp.ImporteTotal1,0)
		+isnull(dp.ImporteTotal2,0)
		) <> 0
	order by c.OrdenCalculo,e.ClaveEmpleado
GO
