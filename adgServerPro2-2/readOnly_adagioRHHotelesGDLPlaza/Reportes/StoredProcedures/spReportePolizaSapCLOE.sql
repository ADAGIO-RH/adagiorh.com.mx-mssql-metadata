USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
    
CREATE proc [Reportes].[spReportePolizaSapCLOE](    
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
  select   
 IDPeriodo  
 ,IDTipoNomina  
 ,Ejercicio  
 ,ClavePeriodo  
 ,Descripcion  
 ,FechaInicioPago  
 ,FechaFinPago  
 ,FechaInicioIncidencia  
 ,FechaFinIncidencia  
 ,Dias  
 ,AnioInicio  
 ,AnioFin  
 ,MesInicio  
 ,MesFin  
 ,IDMes  
 ,BimestreInicio  
 ,BimestreFin  
 ,Cerrado  
 ,General  
 ,Finiquito  
 ,isnull(Especial,0)  
  from Nomina.tblCatPeriodos  
 where   
   ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))                  
    
  select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
  
  
  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
      
if object_id('tempdb..#tempConceptos') is not null        
    drop table #tempConceptos   
  
       
if object_id('tempdb..#tempData') is not null        
    drop table #tempData  
  
  Select distinct   
     replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.','') as Concepto,
  tc.IDTipoConcepto as IDTipoConcepto,  
  tc.Descripcion as TipoConcepto,  
  c.OrdenCalculo as OrdenCalculo,  
  case when  tc.IDTipoConcepto in (1,4) then 1  
    when  tc.IDTipoConcepto = 2 then 2  
    when  tc.IDTipoConcepto = 3 then 3  
    when  tc.IDTipoConcepto = 6 then 4  
    when  tc.IDTipoConcepto = 5 then 5  
    else 0  
    end as OrdenColumn  
 into #tempConceptos  
  from @periodo P  
 inner join Nomina.tblDetallePeriodo dp  
  on p.IDPeriodo = dp.IDPeriodo  
 inner join Nomina.tblCatConceptos c  
  on C.IDConcepto = dp.IDConcepto  
 Inner join Nomina.tblCatTipoConcepto tc  
  on tc.IDTipoConcepto = c.IDTipoConcepto  
 inner join @empleados e  
  on dp.IDEmpleado = e.IDEmpleado  
  
  
Select  
  CASE
   --TIENE CUENTA CARGO 
    WHEN c.CuentaCargo <> NULL THEN 
		CASE --EL CONCEPTO ES DE FONDO DE AHORRO
		WHEN c.Descripcion = 'FONDO DE AHORRO EMPRESA' THEN 
			CASE--ENTRA EN UN RANGO DE SUCURSALES
			WHEN e.IDSucursal between 0 and 1 
				THEN CONCAT(c.CuentaCargo,'-',[App].[fnAddString](3,e.IDSucursal,'0',1),'-432') -- SI -> SUCURSAL A
				ELSE CONCAT(c.CuentaCargo,'-002-432') -- NO -> SUCURSAL B
			END--ENTRA EN UN RANGO DE SUCURSALES
		ELSE 
			CASE --LA CUENTA CARGO TIENE EN SU SEGUNDA PARTE 3 CEROS CAPTURADOS (000)
				WHEN c.Codigo = '000' THEN CONCAT(c.Codigo,'-_TEL3','-',c.CuentaCargo) --SE SOBRE ESCRIBE EL 000 POR EL DATO DEL _TEL3
				ELSE CONCAT(c.Codigo,'-',c.CuentaCargo) -- SE IMPRIME LA CUENTA CAPTURADA EN EL CONCEPTO
			END --LA CUENTA CARGO TIENE EN SU SEGUNDA PARTE 3 CEROS CAPTURADOS (000)
		END --EL CONCEPTO ES DE FONDO DE AHORRO
		
	--TIENE CUENTA ABONO 
    WHEN c.CuentaAbono <> NULL THEN
		CASE--EL CONCEPTO ES DESCUENTO COMEDOR
			WHEN c.Descripcion = 'FONDO DE AHORRO EMPRESATHEN' THEN CONCAT(c.Codigo,'-',c.CuentaAbono)--SE IMPRIME LA CUENTA ABONO
			ELSE
				CASE--LA CUENTA ABONO TIENE EN SU SEGUNDA PARTE 3 CEROS CAPTURADOS (000)
					WHEN c.Codigo = '000' THEN CONCAT(c.Codigo,'-_TEL3','-',c.CuentaAbono) --SE SOBRE ESCRIBE EL 000 POR EL DATO DEL _TEL3
				ELSE CONCAT(c.Codigo,'-',c.CuentaCargo) -- SE IMPRIME LA CUENTA CAPTURADA EN EL CONCEPTO
				END
		END--EL CONCEPTO ES DESCUENTO COMEDOR

  END AS CUENTA,
  cc.Codigo as NORMA_REPARTO,
  cc.CuentaContable as CCOSTO,
  cc.Descripcion as DESCRIPCION, 
  concat('Semana del ', @fechaIniPeriodo, ' al ', @fechaFinPeriodo) as NOMBRELARGO,
  c.Codigo as IDCONCEPTO,
  c.Descripcion as CDESCRIPCION, --DESCRIPCION, Lo reemplaze a DESCRIPCION por que chocaba con el nombre de arriba
  CASE
    WHEN tc.Descripcion = 'PERCEPCION' THEN 'P'
    WHEN tc.Descripcion = 'DEDUCCION' THEN 'D'
    ELSE 'C'
  END as TIPOCONCEPTO,
  CASE
    WHEN c.CuentaCargo <> NULL THEN SUM(isnull(dp.ImporteTotal1,0))
  END AS DEBITO,
  CASE
    WHEN c.CuentaAbono <> NULL THEN SUM(isnull(dp.ImporteTotal1,0))
  END AS CREDITO,
  p.IDPeriodo as IDPERIODO,
  te.RFC as SUBCONTRATANTE

 into #tempData  
  from @periodo P  
 inner join Nomina.tblDetallePeriodo dp  
  on p.IDPeriodo = dp.IDPeriodo  
 inner join Nomina.tblCatConceptos c  
  on C.IDConcepto = dp.IDConcepto  
 Inner join Nomina.tblCatTipoConcepto tc  
  on tc.IDTipoConcepto = c.IDTipoConcepto  
 inner join @empleados e  
  on dp.IDEmpleado = e.IDEmpleado  
 inner join RH.tblCatCentroCosto cc
	on e.IDCentroCosto = cc.IDCentroCosto
inner join RH.tblEmpresa te
	on e.Empresa = te.IdEmpresa



 Group by c.Codigo ,cc.Codigo,cc.CuentaContable,c.Descripcion , cc.Descripcion, tc.Descripcion, p.IDPeriodo ,te.RFC
GO
