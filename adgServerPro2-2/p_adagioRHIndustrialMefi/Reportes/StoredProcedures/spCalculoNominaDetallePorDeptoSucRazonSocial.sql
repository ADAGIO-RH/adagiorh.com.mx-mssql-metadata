USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorDeptoSucRazonSocial]--4114,17,'5'    
(    
 @IDDepartamento varchar(max) = '',    
 @IDSucursal  varchar(max) = '',       
 @IDRazonSocial  varchar(max) = '',       
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50),    
 @Codigo varchar(50) = null ,
 @IDUsuario int   
)    
AS    
BEGIN    
    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
  
  DECLARE       
  @empleados [RH].[dtEmpleados]      
 ,@IDPeriodoSeleccionado int=0      
 ,@periodo [Nomina].[dtPeriodos]      
 ,@configs [Nomina].[dtConfiguracionNomina]      
 ,@Conceptos [Nomina].[dtConceptos]      
 ,@dtFiltros [Nomina].[dtFiltrosRH]     
 ,@IDTipoNomina int 
 ,@fechaIniPeriodo  date      
    ,@fechaFinPeriodo  date    
  
     
 IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL    
  DROP TABLE #tempResultado    
    
 if(isnull(@IDDepartamento,0)<>0)      
   BEGIN      
  insert into @dtFiltros(Catalogo,Value)      
  values('Departamentos',case when @IDDepartamento is null then '' else @IDDepartamento end)      
   END;      
 if(isnull(@IDSucursal,0)<>0)      
   BEGIN      
  insert into @dtFiltros(Catalogo,Value)      
  values('Sucursales',case when @IDSucursal is null then '' else @IDSucursal end)      
   END;     
  
   if(isnull(@IDRazonSocial,'')<>'')      
   BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('RazonesSociales',case when @IDRazonSocial is null then '' else @IDRazonSocial end)      
   END;  
     
      
  Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)      
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado      
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodo      
      
       
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago   , @IDTipoNomina = IDTipoNomina   
    from @periodo     
    where IDPeriodo = @IDPeriodo   

     insert into @empleados      
    exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario      
       
    
    
   select 
    dp.IDConcepto    
    ,ccp.Codigo    
    ,ccp.Descripcion as Concepto    
    ,ccp.IDTipoConcepto    
    ,tc.Descripcion as TipoConcepto    
    ,ccp.OrdenCalculo     
    ,SUM(dp.ImporteGravado) as ImporteGravado    
    ,SUM(dp.ImporteExcento) as ImporteExcento    
    ,SUM(dp.ImporteOtro) as ImporteOtro    
    ,SUM(dp.ImporteTotal1) as ImporteTotal1    
    ,SUM(dp.ImporteTotal2) ImporteTotal2        
    ,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales    
 INTO #tempResultado    
   from [Nomina].[tblDetallePeriodo] dp with (nolock)    
    LEFT join @periodo cp  on dp.IDPeriodo = cp.IDPeriodo    
 LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
 INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
 INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
 inner join @empleados e  on e.IDEmpleado = dp.IDEmpleado
 where cp.IDPeriodo = @IDPeriodo    
 and ccp.Impresion = 1        
 and (tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,',')))    
 and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )   
 
 GROUP BY
    dp.IDConcepto    
    ,ccp.Codigo    
    ,ccp.Descripcion 
    ,ccp.IDTipoConcepto    
    ,tc.Descripcion 
    ,ccp.OrdenCalculo     
   
 ORDER BY ccp.OrdenCalculo ASC    
    
 --select * from #tempResultado    
    
 IF(@IDTipoConcepto = '5')    
 BEGIN    
  SELECT * FROM #tempResultado    
  WHERE ImporteTotal1 > 0    
  ORDER BY OrdenCalculo ASC  
 END    
 ELSE    
 BEGIN    
  SELECT * FROM #tempResultado    
   ORDER BY OrdenCalculo ASC  
 END    
    DROP TABLE #tempResultado;
END
GO
