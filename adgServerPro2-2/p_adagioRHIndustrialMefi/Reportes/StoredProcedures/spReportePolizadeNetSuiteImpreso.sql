USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReportePolizadeNetSuiteImpreso](
	 @Cliente int,  
	 @TipoNomina int,   
	 @IDPeriodoInicial Varchar(max),   
	 @Ejercicio Varchar(max),   
	 @IDDepartamento varchar(max) = '',  
	 @IDUsuario int    
) as    
	SET FMTONLY OFF 
	declare 
		@empleados [RH].[dtEmpleados]            
		,@periodo [Nomina].[dtPeriodos]        
		,@fechaIniPeriodo date
		,@fechaFinPeriodo date

	;    


  
  /* Se buscan el periodo seleccionado */    
  insert into @periodo  
  select *  
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
 IDPeriodo = @IDPeriodoInicial             
    
  select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
  
  
  
  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @TipoNomina, @FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo, @IDUsuario = @IDUsuario     

  select * from (
  Select  
			--PERCEPCIONES
			Format(getdate(), 'DD/MM/YYYY') as FECHA 
		   ,concat( cd.CuentaContable , ' ' , cd.Descripcion )  as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,0 as CREDIT
		   ,SUM(dp.ImporteTotal1) as DEBIT
		   ,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		   ,convert(varchar, P.FechaInicioPago, 103) as FechaInicioPago 
		   ,convert(varchar, P.FechaFinPago, 103) as FechaFinPago 
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
			group by C.Codigo,
			c.Descripcion
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		   ,P.FechaInicioPago
		   ,p.FechaFinPago

	UNION ALL

	Select  
			--DEDUCIONES
			Format(getdate(), 'DD/MM/YYYY') as FECHA 
		   ,IIF ( c.Codigo = '338', concat('8000',' ' ,'GASTOS DE OPERACIÓN' ), concat( cd.CuentaContable , ' ' , cd.Descripcion ) )  as DEPARTAMENTO
		   ,C.CuentaAbono as CUENTA
		   ,SUM(dp.ImporteTotal1) as CREDIT
		   ,0 as DEBIT
		   ,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		   ,convert(varchar, P.FechaInicioPago, 103) as FechaInicioPago 
		   ,convert(varchar, P.FechaFinPago, 103) as FechaFinPago 
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
			group by C.Codigo,
			c.Descripcion
		   ,cd.Descripcion
		   ,C.CuentaAbono
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		   ,P.FechaInicioPago
		   ,p.FechaFinPago

		UNION ALL

	Select  
			--309 ONDO DE AHORRO EMPRESA y 304 CREDITO INFONAVIT
			Format(getdate(), 'DD/MM/YYYY') as FECHA 
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
		   ,convert(varchar, P.FechaInicioPago, 103) as FechaInicioPago 
		   ,convert(varchar, P.FechaFinPago, 103) as FechaFinPago 
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







  /*
Select  
			getdate() as FECHA
		   ,cd.Descripcion as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,0 as CREDITO
		   ,SUM(dp.ImporteTotal1) as DEBITO
		   ,concat(c.Codigo,'-',c.Descripcion) as NOTA
		   ,P.FechaInicioPago,p.FechaFinPago
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo  
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblDepartamentoEmpleado de on e.IDEmpleado = de.IDEmpleado
			inner join RH.tblCatDepartamentos cd on de.IDDepartamento = cd.IDDepartamento
			where (c.Codigo = '101' or c.Codigo = '121')  --Sueldo y Prima vacacional
			group by cd.IDDepartamento,
			c.Descripcion
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,P.FechaInicioPago
		   ,p.FechaFinPago

UNION ALL

	Select  
			getdate() as FECHA
		   ,cd.Descripcion as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,dp.ImporteTotal1 as CREDITO
		   ,0 as DEBITO
		   ,IIF(c.Codigo = '161'
		   ,concat(c.Codigo,'-204',e.ClaveEmpleado,'-',c.Descripcion)
		   ,concat(c.Codigo,'-309',e.ClaveEmpleado,'-',c.Descripcion)
		   ) AS NOTA
		   ,P.FechaInicioPago,p.FechaFinPago
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo  
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblDepartamentoEmpleado de on e.IDEmpleado = de.IDEmpleado
			inner join RH.tblCatDepartamentos cd on de.IDDepartamento = cd.IDDepartamento
			where (c.Codigo = '161' or c.Codigo = '304')  --FONDO DE AHORRO EMPRESA y CREDITO INFONAVIT
UNION ALL

	Select  
			getdate() as FECHA
		   ,cd.Descripcion as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,0 as CREDITO
		   ,dp.ImporteTotal1 as DEBITO
           ,concat(c.Codigo,'-',c.Descripcion) as NOTA
		   ,P.FechaInicioPago,p.FechaFinPago
		   from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo  
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblDepartamentoEmpleado de on e.IDEmpleado = de.IDEmpleado
			inner join RH.tblCatDepartamentos cd on de.IDDepartamento = cd.IDDepartamento
			where (c.Codigo not in ('161','304','101','121') ) --FONDO DE AHORRO EMPRESA y CREDITO INFONAVIT
			and CuentaCargo is not null


UNION ALL

 Select  
			getdate() as FECHA
		   ,cd.Descripcion as DEPARTAMENTO
		   ,C.CuentaCargo as CUENTA
		   ,dp.ImporteTotal1  as CREDITO
		   ,0 as DEBITO
           ,concat(c.Codigo,'-',c.Descripcion) as NOTA
		   ,P.FechaInicioPago,p.FechaFinPago
		   from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo  
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblDepartamentoEmpleado de on e.IDEmpleado = de.IDEmpleado
			inner join RH.tblCatDepartamentos cd on de.IDDepartamento = cd.IDDepartamento
			where (c.Codigo not in ('161','304','101','121') ) --FONDO DE AHORRO EMPRESA y CREDITO INFONAVIT
			and CuentaAbono is not null */
		) tbl order by DEPARTAMENTO;
GO
