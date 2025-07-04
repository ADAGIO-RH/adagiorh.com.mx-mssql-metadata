USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePolizadeNetSuite](
  @dtFiltros Nomina.dtFiltrosRH readonly    
 ,@IDUsuario int    
) as    
    
declare @empleados [RH].[dtEmpleados]        
 ,@IDPeriodoSeleccionado int=0        
 ,@periodo [Nomina].[dtPeriodos]        
 ,@configs [Nomina].[dtConfiguracionNomina]        
 ,@Conceptos [Nomina].[dtConceptos]        
 ,@IDTipoNomina int     
 ,@fechaIniPeriodo  date        
 ,@fechaFinPeriodo  date        
 ;    
  
 set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
      else 0  
END  
  
  
  /* Se buscan el periodo seleccionado */    
  insert into @periodo  
  select   *
 --IDPeriodo  
 --,IDTipoNomina  
 --,Ejercicio  
 --,ClavePeriodo  
 --,Descripcion  
 --,FechaInicioPago  
 --,FechaFinPago  
 --,FechaInicioIncidencia  
 --,FechaFinIncidencia  
 --,Dias  
 --,AnioInicio  
 --,AnioFin  
 --,MesInicio  
 --,MesFin  
 --,IDMes  
 --,BimestreInicio  
 --,BimestreFin  
 --,Cerrado  
 --,General  
 --,Finiquito  
 --,isnull(Especial,0)  
  from Nomina.tblCatPeriodos  
 where   
   ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))                  
    
  select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
  
  
  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     

  
select * from (
	Select  
			--PERCEPCIONES
			convert(varchar, getdate(), 103) as FECHA 
		   ,concat( cd.CuentaContable , ' ' , cd.Descripcion )  as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,0 as CREDIT
		   ,SUM(dp.ImporteTotal1) as DEBIT
		   ,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '309','304', '180','307')
			group by cd.IDDepartamento,
			c.Descripcion
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable

	UNION ALL

	Select  
			--DEDUCIONES
			convert(varchar, getdate(), 103) as FECHA 
		   ,IIF ( c.Codigo = '338', concat('8000',' ' ,'GASTOS DE OPERACIÓN' ), concat( cd.CuentaContable , ' ' , cd.Descripcion ) )  as DEPARTAMENTO
		   ,C.CuentaAbono as CUENTA
		   ,SUM(dp.ImporteTotal1) as CREDIT
		   ,0 as DEBIT
		   ,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaAbono <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '309','304', '180','307' )
			group by cd.IDDepartamento,
			c.Descripcion
		   ,cd.Descripcion
		   ,C.CuentaAbono
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable

		UNION ALL

	Select  
			--309 ONDO DE AHORRO EMPRESA y 304 CREDITO INFONAVIT
			convert(varchar, getdate(), 103) as FECHA 
		   ,concat( cd.CuentaContable , ' ' , cd.Descripcion )  as DEPARTAMENTO
		   ,IIF(c.Codigo = '309'
   			   ,concat('204',e.ClaveEmpleado)

			   ,IIF(c.Codigo = '304',
						concat('207',e.ClaveEmpleado)

					   ,IIF(c.Codigo = '307',
							concat('209',e.ClaveEmpleado)
								,concat('221',e.ClaveEmpleado) ) )
					   
					   ) AS CUENTA

			   ,IIF(c.Codigo = '309'
   					,dp.ImporteTotal1 * 2
					, IIF (c.Codigo = '304' OR c.Codigo = '307' , dp.ImporteTotal1, 0 )
					
					) AS CREDIT

		   ,IIF( c.Codigo = '180',dp.ImporteTotal1, 0 ) as DEBIT


		   ,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaAbono <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo in ( '309' , '304', '180','307' )
) tbl order by DEPARTAMENTO;
GO
