USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from Nomina.tblHistorialesEmpleadosPeriodos    
    
CREATE PROCEDURE  [Nomina].[spLayoutBANCOMER_CUENTAS_GLASFIRMA_SAN_MIGUEL]--2,'2018-12-27',8,0    
(    
 @IDPeriodo int,    
 @FechaDispersion date,    
 @IDLayoutPago int,    
 @dtFiltros [Nomina].[dtFiltrosRH]  readonly,   
 @MarcarPagados bit = 0,  
 @IDUsuario int      
)    
AS    
BEGIN    
 declare     
  --@Consecutivo int = 1    
  --,@NoCuenta varchar(50) = '1528454299'    
  --,@Monto decimal(18,2) = 1.00    
  --,@Nombre varchar(255) = 'RUBEN ALEJANDRO SOLIS AVILA'    
  --,@Respuesta nvarchar(max)    
  @empleados [RH].[dtEmpleados]    
  ,@ListaEmpleados Nvarchar(max)    
  ,@periodo [Nomina].[dtPeriodos]    
  ,@fechaIniPeriodo  date                    
  ,@fechaFinPeriodo  date  
  ,@IDTipoNomina int                
 --if((select isnull(Cerrado,0) from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo)= 0)    
 --BEGIN    
 -- RAISERROR('No se puede generar Layouts de Periodos Abiertos, Favor Cerrarlo previamente',16,1);    
 -- RETURN;    
 --END    
    
    if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    
    create table #tempResp(Respuesta nvarchar(max));    
  
 Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                    
 select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0) 
 
 from Nomina.TblCatPeriodos                    
 where IDPeriodo = @IDPeriodo                    
                    
 select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                    
 from @periodo                    
                  
 /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                    
 insert into @empleados                    
 exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario      
     
    if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;      
      
 create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int);   
  
 IF((Select top 1 Finiquito from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo) = 0)    
 BEGIN    
      
  if(isnull(@MarcarPagados,0) = 1)  
  BEGIN   
   insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)  
   SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago  
   FROM  @empleados e    
    INNER join Nomina.tblCatPeriodos p    
     on  p.IDPeriodo = @IDPeriodo    
    INNER JOIN RH.tblPagoEmpleado pe    
     on pe.IDEmpleado = e.IDEmpleado    
    INNER JOIN  Nomina.tblLayoutPago lp    
     on lp.IDLayoutPago = pe.IDLayoutPago    
    inner join Nomina.tblCatTiposLayout tl    
     on tl.TipoLayout = 'BBVA CUENTAS GLASFIRMA SAN MIGUEL'    
      and lp.IDTipoLayout = tl.IDTipoLayout    
    INNER JOIN Nomina.tblDetallePeriodo dp    
     on dp.IDPeriodo = @IDPeriodo    
      --and lp.IDConcepto = dp.IDConcepto    
      and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end  
      and dp.IDEmpleado = e.IDEmpleado    
   where  pe.IDLayoutPago = @IDLayoutPago    
  
   MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET  
   USING #tempempleadosMarcables AS SOURCE  
    ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
     and TARGET.IDEmpleado = SOURCE.IDEmpleado  
     and TARGET.IDLayoutPago = SOURCE.IDLayoutPago  
   WHEN NOT MATCHED BY TARGET THEN   
    INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)    
    VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);  
  END  
  
  insert INTO #tempResp(Respuesta)    
  select     
   [App].[fnAddString](9,Row_Number()OVER(order by e.IDEmpleado asc),'0',1)     
   +[App].[fnAddString](16,'','',2)    
   +'99'    
   +[App].[fnAddString](10,isnull(PE.Cuenta,''),'0',1)    
   +[App].[fnAddString](10,'','',1)    
   +[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 THEN dp.ImporteTotal1 ELSE dp.ImporteTotal2 END,0) as varchar(max)),'.',''),'0',1)    
   +[App].[fnAddString](40,( REPLACE(  
         RTRIM(LTRIM( CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), ' '  ) +' ' END+  
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), ''  ) +' ' END+  
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), ' '  ) +' ' END+   
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,''))), '') = '' THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,' '))), ' ')  END  
            )  
           )  
          ,'Ñ','N') ),'',2)    
   +[App].[fnAddString](6,'001001','',1)    
       
  FROM  @empleados e    
   INNER join Nomina.tblCatPeriodos p    
    on  p.IDPeriodo = @IDPeriodo    
   INNER JOIN RH.tblPagoEmpleado pe    
    on pe.IDEmpleado = e.IDEmpleado    
   INNER JOIN  Nomina.tblLayoutPago lp    
    on lp.IDLayoutPago = pe.IDLayoutPago    
   inner join Nomina.tblCatTiposLayout tl    
    on tl.TipoLayout = 'BBVA CUENTAS GLASFIRMA SAN MIGUEL'    
     and lp.IDTipoLayout = tl.IDTipoLayout    
   INNER JOIN Nomina.tblDetallePeriodo dp    
    on dp.IDPeriodo = @IDPeriodo    
     --and lp.IDConcepto = dp.IDConcepto    
     and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end  
     and dp.IDEmpleado = e.IDEmpleado    
  where  pe.IDLayoutPago = @IDLayoutPago    
 END    
 ELSE    
 BEGIN    
  if(isnull(@MarcarPagados,0) = 1)  
  BEGIN   
   insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)  
   SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago  
   FROM  @empleados e    
    INNER join Nomina.tblCatPeriodos p    
     on  p.IDPeriodo = @IDPeriodo    
    INNER JOIN RH.tblPagoEmpleado pe    
     on pe.IDEmpleado = e.IDEmpleado    
    INNER JOIN  Nomina.tblLayoutPago lp    
     on lp.IDLayoutPago = pe.IDLayoutPago    
    inner join Nomina.tblCatTiposLayout tl    
     on tl.TipoLayout = 'BBVA CUENTAS GLASFIRMA SAN MIGUEL'    
      and lp.IDTipoLayout = tl.IDTipoLayout    
    INNER JOIN Nomina.tblDetallePeriodo dp    
     on dp.IDPeriodo = @IDPeriodo    
      --and lp.IDConceptoFiniquito= dp.IDConcepto    
      and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end  
      and dp.IDEmpleado = e.IDEmpleado    
   where pe.IDLayoutPago = @IDLayoutPago    
  
   MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET  
   USING #tempempleadosMarcables AS SOURCE  
    ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
     and TARGET.IDEmpleado = SOURCE.IDEmpleado  
     and TARGET.IDLayoutPago = SOURCE.IDLayoutPago  
   WHEN NOT MATCHED BY TARGET THEN   
    INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)    
    VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);  
  END  
  
  insert INTO #tempResp(Respuesta)    
  select     
   [App].[fnAddString](9,Row_Number()OVER(order by e.IDEmpleado asc),'0',1)     
   +[App].[fnAddString](16,'','',2)    
   +'99'    
   +[App].[fnAddString](10,isnull(PE.Cuenta,''),'0',1)    
   +[App].[fnAddString](10,'','',1)    
   +[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 THEN dp.ImporteTotal1 ELSE dp.ImporteTotal2 END,0) as varchar(max)),'.',''),'0',1)    
   +[App].[fnAddString](40,( REPLACE (   
         RTRIM(LTRIM( CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), ' '  ) +' ' END+  
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), ''  ) +' ' END+  
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '') = ''   THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), ' '  ) +' ' END+   
             CASE WHEN COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,''))), '') = '' THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,' '))), ' ')  END  
            )  
           )  
          ,'Ñ','N')),'',2)    
   +[App].[fnAddString](6,'001001','',1)     
  FROM  @empleados e    
   INNER join Nomina.tblCatPeriodos p    
    on  p.IDPeriodo = @IDPeriodo    
   INNER JOIN RH.tblPagoEmpleado pe    
    on pe.IDEmpleado = e.IDEmpleado    
   INNER JOIN  Nomina.tblLayoutPago lp    
    on lp.IDLayoutPago = pe.IDLayoutPago    
   inner join Nomina.tblCatTiposLayout tl    
    on tl.TipoLayout = 'BBVA CUENTAS GLASFIRMA SAN MIGUEL'    
     and lp.IDTipoLayout = tl.IDTipoLayout    
   INNER JOIN Nomina.tblDetallePeriodo dp    
    on dp.IDPeriodo = @IDPeriodo    
     --and lp.IDConceptoFiniquito= dp.IDConcepto    
     and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end  
     and dp.IDEmpleado = e.IDEmpleado    
  where pe.IDLayoutPago = @IDLayoutPago    
 END    
       
    select * from #tempResp    
END
GO
