USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteCapturasConceptos]--1,17,0      
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
    exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @EmpleadoIni= @EmpleadoIni,@EmpleadoFin=@EmpleadoFin      
      
      
         
      
   select    
     E.IDEmpleado
	,E.ClaveEmpleado
	,E.NOMBRECOMPLETO as NombreCompleto
    ,dp.IDConcepto      
    ,ccp.Codigo      
    ,ccp.Descripcion as Concepto            
    ,dp.CantidadMonto as CantidadMonto      
    ,dp.CantidadDias as CantidadDias      
    ,dp.CantidadVeces as CantidadVeces      
    ,dp.CantidadOtro1 as CantidadOtro1      
    ,dp.CantidadOtro2 as CantidadOtro2      
    ,CASE WHEN E.Vigente = 1 THEN 'SI' ELSE 'NO' END as Vigente   
    
   from [Nomina].[tblDetallePeriodo] dp with (nolock)      
    LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
	 LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	 LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente      
	 LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago      
    INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	LEFT join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	join RH.tblEmpleadosMaster e on dp.IDEmpleado = e.IDEmpleado      
   where cp.IDPeriodo = @IDPeriodoSeleccionado      
		and e.IDEmpleado in (select IDEmpleado from @empleados)
	and ((ISNULL(dp.CantidadMonto,0) > 0) OR (ISNULL(dp.CantidadDias,0) > 0) OR (ISNULL(dp.CantidadVeces,0) > 0) OR (ISNULL(dp.CantidadOtro1,0) > 0) OR (ISNULL(dp.CantidadOtro2,0) > 0))
 ORDER BY OrdenCalculo ASC      
      
      
      
      
END
GO
