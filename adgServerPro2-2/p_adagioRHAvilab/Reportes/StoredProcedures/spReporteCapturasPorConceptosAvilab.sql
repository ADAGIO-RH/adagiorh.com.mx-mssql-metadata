USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteCapturasPorConceptosAvilab](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)as
	declare 
		@empleados [RH].[dtEmpleados]        
		,@IDPeriodo int=0        
		,@Conceptos nvarchar(max)   
		,@IDTipoNomina int     
		,@FechaIniPeriodo  date        
		,@FechaFinPeriodo  date        
	;    

	-- Obtener los conceptos del filtro
	Select top 1 @Conceptos = Value from @dtFiltros where Catalogo = 'CatalogoConceptos'

	-- Obtener el ID del periodo
	set @IDPeriodo = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) 
		then (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
		else 0  
		END 

	-- Obtener fechas de periodo
	select 
		@FechaIniPeriodo = p.FechaInicioPago
		,@FechaFinPeriodo = p.FechaFinPago	
	from Nomina.tblCatPeriodos p with (nolock)
	where p.IDPeriodo = @IDPeriodo

	-- Obtener tipo de nómina
	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
		then (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		else 0  
		END 

	-- Insertar empleados
	insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario  

	if @Conceptos > 0
	begin
		-- Traer los registros de empleados con conceptos específicos
		Select  
			e.ClaveEmpleado
			,e.NOMBRECOMPLETO as 'Nombre'
			,e.Departamento
			,e.Sucursal
			,e.Puesto
			,e.Division
			,replace(replace(replace(c.Codigo+'_'+c.Descripcion,' ','_'),'-',''),'.','') as Concepto
			,isnull(dp.CantidadMonto,0) as CantidadMonto  
			,isnull(dp.CantidadDias,0)  as CantidadDias  
			,isnull(dp.CantidadVeces,0) as CantidadVeces  
			,isnull(dp.CantidadOtro1,0) as CantidadOtro1 
			,convert(varchar,(cast(((isnull(dp.CantidadOtro1,0)/24.000001)) as datetime)),8) as TIEMPO
			,isnull(dp.CantidadOtro2,0) as CantidadOtro2  
			,isnull(dp.ImporteGravado,0) as ImporteGravado  
			,isnull(dp.ImporteExcento,0) as ImporteExento 
			,isnull(dp.ImporteTotal1,0) as ImporteTotal1  
			,isnull(dp.ImporteTotal2,0) as ImporteTotal2  
			,isnull(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales 
			,c.OrdenCalculo
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
			) <> 0 -- Aquí se puede cambiar a "= 0" si deseas incluir incluso cuando son 0
		union all

		-- Traer empleados sin concepto
		Select	
			e.ClaveEmpleado
			,e.NOMBRECOMPLETO as 'Nombre'
			,e.Departamento
			,e.Sucursal
			,e.Puesto
			,e.Division
			,'' as Concepto
			,0 as CantidadMonto  
			,0 as CantidadDias  
			,0 as CantidadVeces  
			,0 as CantidadOtro1
			,convert(varchar,(cast(((0/24.000001)) as datetime)),8) as TIEMPO
			,0 as CantidadOtro2  
			,0  as ImporteGravado  
			,0  as ImporteExento 
			,0 as ImporteTotal1  
			,0 as ImporteTotal2  
			,0  as ImporteAcumuladoTotales
			,0 as OrdenCalculo
		from Nomina.tblDetallePeriodo dp  with (nolock)
			inner join @empleados e  
				on dp.IDEmpleado = e.IDEmpleado  
		where dp.IDPeriodo = @IDPeriodo -- Aquí cambiamos la condición del periodo
			and e.IDEmpleado not in (select distinct IDEmpleado from nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodo and IDConcepto in (select cast(Item as int) from App.Split(@Conceptos,',')) )
			and (
			isnull(dp.CantidadMonto,0)
			+isnull(dp.CantidadDias,0) 
			+isnull(dp.CantidadVeces,0)
			+isnull(dp.CantidadOtro1,0)
			+isnull(dp.CantidadOtro2,0)
			+isnull(dp.ImporteTotal1,0)
			+isnull(dp.ImporteTotal2,0)
			) <> 0 -- Aquí también se puede cambiar a "= 0" si quieres incluir registros con 0
		 group by 
			e.ClaveEmpleado
			,e.NOMBRECOMPLETO 
			,e.Departamento
			,e.Sucursal
			,e.Puesto
			,e.Division
		 order by ClaveEmpleado,OrdenCalculo

	end
	else 
		-- Consulta cuando no hay conceptos especificados
		Select  
			e.ClaveEmpleado
			,e.NOMBRECOMPLETO as 'Nombre'
			,e.Departamento
			,e.Sucursal
			,e.Puesto
			,e.Division
			,replace(replace(replace(c.Codigo+'_'+c.Descripcion,' ','_'),'-',''),'.','') as Concepto
			,isnull(dp.CantidadMonto,0) as CantidadMonto  
			,isnull(dp.CantidadDias,0)  as CantidadDias  
			,isnull(dp.CantidadVeces,0) as CantidadVeces  
			,isnull(dp.CantidadOtro1,0) as CantidadOtro1 
			,convert(varchar,(cast(((isnull(dp.CantidadOtro1,0)/24.000001)) as datetime)),8) as TIEMPO
			,isnull(dp.CantidadOtro2,0) as CantidadOtro2  
			,isnull(dp.ImporteGravado,0) as ImporteGravado  
			,isnull(dp.ImporteExcento,0) as ImporteExento 
			,isnull(dp.ImporteTotal1,0) as ImporteTotal1  
			,isnull(dp.ImporteTotal2,0) as ImporteTotal2  
			,isnull(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales
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
		order by ClaveEmpleado,OrdenCalculo

GO
