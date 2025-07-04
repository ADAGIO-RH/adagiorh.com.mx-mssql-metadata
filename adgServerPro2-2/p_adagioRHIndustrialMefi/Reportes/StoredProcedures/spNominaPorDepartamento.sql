USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spNominaPorDepartamento]--1,17,0  
(  
    @IDUsuario int  = 0  
   ,@IDTipoNomina int   
   ,@IDPeriodo int = 0  
   ,@dtDepartamentos Varchar(MAX) = null  
   ,@dtSucursales Varchar(MAX) = null  
   ,@dtPuestos Varchar(MAX) = null  
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
		 ,@IDIdioma varchar(20)
		;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
  
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
		select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado  
		from Nomina.TblCatPeriodos  
		where IDPeriodo = @IDPeriodoSeleccionado  
  
   
		select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago  
		from Nomina.TblCatPeriodos  
		where IDPeriodo = @IDPeriodoSeleccionado  
  
	  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */  
		insert into @empleados  
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros , @IDUsuario= @IDUsuario 
  
	   -- select * from @periodo  
	   -- select * from @dtFiltros  
	   --select * from @empleados  
  
   select dp.IDPeriodo  
    ,cp.Descripcion as Periodo  
    ,cp.IDTipoNomina as IDTipoNomina  
    ,tn.Descripcion as TipoNomina  
    ,tn.IDCliente as IDCliente  
    ,JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente  
    ,tn.IDPeriodicidadPago as IDPeriodicidadPago  
    ,pp.Descripcion as PeriodicidadPago  
    ,dp.IDConcepto  
    ,ccp.Codigo  
    ,ccp.Descripcion as Concepto  
    ,ccp.IDTipoConcepto  
    ,tc.Descripcion as TipoConcepto  
    ,ccp.OrdenCalculo  
    ,SUM(dp.CantidadMonto) as CantidadMonto  
    ,SUM(dp.CantidadDias) as CantidadDias  
    ,SUM(dp.CantidadVeces) as CantidadVeces  
    ,SUM(dp.CantidadOtro1) as CantidadOtro1  
    ,SUM(dp.CantidadOtro2) as CantidadOtro2  
    ,SUM(dp.ImporteGravado) as ImporteGravado  
    ,SUM(dp.ImporteExcento) as ImporteExcento  
    ,SUM(dp.ImporteOtro) as ImporteOtro  
    ,SUM(dp.ImporteTotal1) as ImporteTotal1  
    ,SUM(dp.ImporteTotal2) ImporteTotal2      
    ,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales  
   from [Nomina].[tblDetallePeriodo] dp with (nolock)  
    LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo  
	LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina  
	LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente  
	LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago  
    INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
	LEFT join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto  
	join @empleados e on dp.IDEmpleado = e.IDEmpleado  
   where cp.IDPeriodo = @IDPeriodoSeleccionado  
  
   GROUP BY dp.IDPeriodo  
    ,cp.Descripcion   
    ,cp.IDTipoNomina   
    ,tn.Descripcion   
    ,tn.IDCliente   
    ,cc.Traduccion   
    ,tn.IDPeriodicidadPago   
    ,pp.Descripcion   
    ,dp.IDConcepto  
    ,ccp.Codigo  
    ,ccp.Descripcion   
    ,ccp.IDTipoConcepto  
    ,tc.Descripcion   
    ,ccp.OrdenCalculo  
  
 ORDER BY OrdenCalculo ASC  
  
  
  
  
END
GO
