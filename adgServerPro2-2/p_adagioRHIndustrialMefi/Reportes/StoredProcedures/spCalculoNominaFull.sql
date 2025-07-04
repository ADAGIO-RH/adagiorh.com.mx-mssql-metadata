USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaFull]--1,17,0      
(      
 @IDUsuario int  = 0      
 ,@IDTipoNomina int       
 ,@IDPeriodo int = 0      
 -- ,@dtEmpleados Varchar(MAX) = null     
 ,@EmpleadoIni varchar(20) = null  
 ,@EmpleadoFin varchar (20) = null   
 ,@dtDepartamentos Varchar(MAX) = null      
 ,@dtSucursales Varchar(MAX) = null      
 ,@dtPuestos Varchar(MAX) = null      
 ,@dtPrestaciones Varchar(MAX) = null      
 ,@dtEmpresas Varchar(MAX) = null      
)      
AS      
BEGIN      
      
DECLARE       
  @empleados [RH].[dtEmpleados]      
 ,@IDPeriodoSeleccionado int=0      
 ,@periodo [Nomina].[dtPeriodos]      
 ,@configs [Nomina].[dtConfiguracionNomina]      
 ,@Conceptos [Nomina].[dtConceptos]      
 ,@dtFiltros [Nomina].[dtFiltrosRH]      
 ,@fechaIniPeriodo  date      
    ,@fechaFinPeriodo  date      
      
    
  set @EmpleadoIni = case when @EmpleadoIni is null or @EmpleadoIni = '' then '0' else @EmpleadoIni END  
  set @EmpleadoFin = case when @EmpleadoFin is null or @EmpleadoFin = '' then 'ZZZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin END  
  
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
 if(isnull(@dtPrestaciones,'')<>'')      
   BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Prestaciones',case when @dtPrestaciones is null then '' else @dtPrestaciones end)      
   END;      
  if(isnull(@dtEmpresas,'')<>'')      
   BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('RazonesSociales',case when @dtEmpresas is null then '' else @dtEmpresas end)      
   END;      
      
 IF(isnull(@IDPeriodo,0)=0)      
    BEGIN       
     select @IDPeriodoSeleccionado = IDPeriodo      
     from Nomina.tblCatTipoNomina      
     where IDTipoNomina=@IDTipoNomina      
    END      
    ELSE      
    BEGIN      
   set @IDPeriodoSeleccionado = @IDPeriodo      
    END      
      
  Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)      
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado      
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodoSeleccionado      
      
       
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago      
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodoSeleccionado      
      
  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
    insert into @empleados      
    exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @EmpleadoIni= @EmpleadoIni,@EmpleadoFin=@EmpleadoFin, @IDUsuario= @IDUsuario      
      
    
	select * from  @empleados e
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on cp.IDPeriodo = @IDPeriodoSeleccionado
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina  
		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago 
	where IDEmpleado in (select IDEMpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoSeleccionado ) 
       
	   
	     
      
 --  select dp.IDPeriodo      
 --   ,cp.Descripcion as Periodo      
 --   ,cp.IDTipoNomina as IDTipoNomina      
 --   ,tn.Descripcion as TipoNomina      
 --   ,tn.IDCliente as IDCliente      
 --   ,cc.NombreComercial as Cliente      
 --   ,tn.IDPeriodicidadPago as IDPeriodicidadPago      
 --   ,pp.Descripcion as PeriodicidadPago      
 --   ,dp.IDConcepto      
 --   ,ccp.Codigo      
 --   ,ccp.Descripcion as Concepto      
 --   ,ccp.IDTipoConcepto      
 --   ,tc.Descripcion as TipoConcepto      
 --   ,ccp.OrdenCalculo      
 --   ,dp.Descripcion      
 --   ,dp.CantidadMonto as CantidadMonto      
 --   ,dp.CantidadDias as CantidadDias      
 --   ,dp.CantidadVeces as CantidadVeces      
 --   ,dp.CantidadOtro1 as CantidadOtro1      
 --   ,dp.CantidadOtro2 as CantidadOtro2      
 --   ,dp.ImporteGravado as ImporteGravado      
 --   ,dp.ImporteExcento as ImporteExcento      
 --   ,dp.ImporteOtro as ImporteOtro      
 --   ,dp.ImporteTotal1 as ImporteTotal1      
 --   ,dp.ImporteTotal2 ImporteTotal2          
 --   ,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales      
 --   ,E.*      
 --  from [Nomina].[tblDetallePeriodo] dp with (nolock)      
 --   LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
 --LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
 --LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente      
 --LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago      
 --   INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
 --LEFT join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
 --join @empleados e on dp.IDEmpleado = e.IDEmpleado      
 --  where cp.IDPeriodo = @IDPeriodoSeleccionado      
 --and ccp.Impresion = 1      
 --ORDER BY OrdenCalculo ASC      
      
      
      
      
END
GO
