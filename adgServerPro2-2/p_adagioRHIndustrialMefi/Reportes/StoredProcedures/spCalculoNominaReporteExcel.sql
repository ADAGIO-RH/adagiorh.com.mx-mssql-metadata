USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Reportes].[spCalculoNominaReporteExcel]  1,26,0,'','','','',''            
            
CREATE PROC [Reportes].[spCalculoNominaReporteExcel] (            
    @IDUsuario int             
   ,@IDTipoNomina int    
   ,@IDPeriodoIni int = 0           
   ,@IDPeriodoFin int = 0           
   ,@dtDepartamentos Varchar(MAX) = null        
   ,@dtSucursales Varchar(MAX) = null        
   ,@dtPuestos Varchar(MAX) = null        
   ,@dtDivisiones Varchar(MAX) = null            
   ,@dtClasificacionesCorporativas Varchar(MAX) = null            
)            
as            
            
            
declare             
    @i int = 0             
   ,@IDPeriodoSeleccionado int=0            
   ,@periodo [Nomina].[dtPeriodos]            
   ,@configs [Nomina].[dtConfiguracionNomina]            
   ,@empleados [RH].[dtEmpleados]            
   ,@Conceptos [Nomina].[dtConceptos]            
   ,@DetallePeriodo [Nomina].[dtDetallePeriodo]     
   ,@dtFiltros [Nomina].[dtFiltrosRH]             
   ,@spConcepto nvarchar(255)            
   ,@IDConcepto int = 0            
   ,@CodigoConcepto varchar(20)            
   ,@fechaIniPeriodo  date            
   ,@fechaFinPeriodo  date        
   ,@codigoPeriodoIni Varchar(20)    
   ,@codigoPeriodoFin Varchar(20)    
       
       
      
 if(isnull(@dtDepartamentos,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Departamentos',case when @dtDepartamentos is null then '' else @dtDepartamentos end)        
   END;        
 if(isnull(@dtSucursales,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Sucursales',case when @dtSucursales is null then '' else @dtSucursales end)        
   END;        
 if(isnull(@dtPuestos,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Puestos',case when @dtPuestos is null then '' else @dtPuestos end)        
   END;        
 if(isnull(@dtDivisiones,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Divisiones',case when @dtDivisiones is null then '' else @dtDivisiones end)        
   END;       
    if(isnull(@dtClasificacionesCorporativas,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('ClasificacionesCorporativas',case when @dtClasificacionesCorporativas is null then '' else @dtClasificacionesCorporativas end)        
   END;      
            
           
            
   /* Se busca el ID de periodo seleccionado del tipo de nómina */            
              
            
          
            
   /* Se buscar toda la información del periodo seleccionado y se guarda en @periodo*/            
   Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)            
   select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado    
  
    
   from Nomina.TblCatPeriodos            
   where IDPeriodo = @IDPeriodoSeleccionado            
            
   select @fechaIniPeriodo = FechaInicioPago, @codigoPeriodoIni =ClavePeriodo            
   from Nomina.TblCatPeriodos            
   where IDPeriodo = @IDPeriodoIni            
            
   select @fechaFinPeriodo =FechaFinPago, @codigoPeriodoFin = ClavePeriodo           
   from Nomina.TblCatPeriodos            
   where IDPeriodo = @IDPeriodoFin      
  
   /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */            
   insert into @empleados            
   exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros            
            
   --select * from @empleados         
            
   /* Se carga la configuración de la nómina */            
   insert into @configs            
   select             
    Configuracion            
  ,Valor            
  ,TipoDato            
  ,Descripcion             
    from Nomina.tblConfiguracionNomina            
            
     
            
 --  select * from @empleados            
    
     
 --select @columns    
    
    select             
     dp.IDDetallePeriodo            
    ,dp.IDEmpleado      
 ,e.ClaveEmpleado    
 ,e.NOMBRECOMPLETO as NombreCompleto    
 ,e.Departamento    
 ,e.Sucursal    
 ,e.Puesto                
    ,dp.IDConcepto            
    ,ccp.Codigo            
    ,Concepto = REPLACE ( ccp.Codigo +' - '+ ccp.Descripcion , '.' , '' )      
    ,ccp.IDTipoConcepto            
    ,ctc.Descripcion as TipoConcepto            
    ,SUM(isnull(dp.ImporteTotal1,0))  as ImporteTotal1    
    ,SUM(isnull(dp.ImporteTotal2,0))  as ImporteTotal2    
 ,crr.Orden as OrdenCalculo    
 --into #table         
   from [Nomina].[tblDetallePeriodo] dp with (nolock)            
    join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo            
    join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
 join [Nomina].[tblCatTipoConcepto] ctc with (nolock) on   ccp.IDTipoConcepto = ctc.IDTipoConcepto      
 join @empleados e on dp.IDEmpleado = e.IDEmpleado  
 Join Reportes.tblconfigReporteRayas CRR  
 on CRR.IDConcepto = dp.IDConcepto  
 and CRR.Impresion = 1           
   where cp.FechaInicioPago >= @fechaIniPeriodo and cp.FechaFinPago <= @fechaFinPeriodo and cp.IDTipoNomina = @IDTipoNomina
  -- where cp.ClavePeriodo between @codigoPeriodoIni and @codigoPeriodoFin         
 GROUP BY    
   dp.IDDetallePeriodo            
    ,dp.IDEmpleado      
 ,e.ClaveEmpleado    
 ,e.NOMBRECOMPLETO    
 ,e.Departamento    
 ,e.Sucursal    
 ,e.Puesto                
    ,dp.IDConcepto            
    ,ccp.Codigo            
    , ccp.Descripcion  
    ,ccp.IDTipoConcepto            
    ,ctc.Descripcion     
  ,crr.Orden
GO
