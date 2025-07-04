USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
      
CREATE proc [Reportes].[spReporteBasicoResumenNominaDivision](      
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
  select  *   
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
  e.Division as Division,     
   replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.','') as Concepto,    
  SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1    
      
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
 Group by c.Descripcion, e.Division,c.Codigo    
    
 --select * from #tempConceptos    
 --select * from #tempData    
    
    
    
DECLARE @cols AS NVARCHAR(MAX),    
    @query1  AS NVARCHAR(MAX),    
    @query2  AS NVARCHAR(MAX),    
    @colsAlone AS VARCHAR(MAX)    
 ;    
    
SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)    
    FROM #tempConceptos c    
   GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo    
   ORDER BY c.OrdenColumn,c.OrdenCalculo    
            FOR XML PATH(''), TYPE    
            ).value('.', 'NVARCHAR(MAX)')     
        ,1,1,'');    
    
SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)    
            FROM #tempConceptos c    
   GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo    
   ORDER BY c.OrdenColumn,c.OrdenCalculo    
            FOR XML PATH(''), TYPE    
            ).value('.', 'NVARCHAR(MAX)')     
        ,1,1,'');    
    
    
set @query1 = 'SELECT Division, ' + @cols + ' from     
            (    
                select Division    
                    , Concepto    
                    , isnull(ImporteTotal1,0) as ImporteTotal1    
                from #tempData    
           ) x'    
    
set @query2 = '    
            pivot     
            (    
                 SUM(ImporteTotal1)    
                for Concepto in (' + @colsAlone + ')    
            ) p '    
    
    
    
exec( @query1 + @query2)
GO
