USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoFiniquito]--4114,17,'5'      
(      
 @IDEmpleado int,      
 @IDPeriodo int,      
 @IDTipoConcepto varchar(50),      
 @Codigo varchar(50) = null,
 @IDFiniquito int      
)      
AS      
BEGIN      
    SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  

	DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

       
 IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL      
  DROP TABLE #tempResultado    
  
  IF OBJECT_ID('tempdb..#tempResultadoFiniquito') IS NOT NULL      
  DROP TABLE #tempResultadoFiniquito    
 
 declare @Estatus varchar(max)

 
 select top 1 @Estatus = ef.Descripcion from Nomina.tblControlFiniquitos cf
	inner join Nomina.tblCatEstatusFiniquito ef
		on cf.IDEStatusFiniquito = ef.IDEStatusFiniquito
 where IDFiniquito = @IDFiniquito  
 
 if(@Estatus = 'Aplicar')
 BEGIN
 
      
      
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
		,dp.Descripcion      
		,dp.CantidadMonto as CantidadMonto      
		,dp.CantidadDias as CantidadDias      
		,dp.CantidadVeces as CantidadVeces      
		,dp.CantidadOtro1 as CantidadOtro1      
		,dp.CantidadOtro2 as CantidadOtro2      
		,dp.ImporteGravado as ImporteGravado      
		,dp.ImporteExcento as ImporteExcento      
		,dp.ImporteOtro as ImporteOtro      
		,dp.ImporteTotal1 as ImporteTotal1      
		,dp.ImporteTotal2 ImporteTotal2          
		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales      
	 INTO #tempResultado      
	   from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
	 LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	 LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente      
	 LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago      
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	 INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	 where cp.IDPeriodo = @IDPeriodo      
	 and ccp.Impresion = 1      
	 and dp.IDEmpleado = @IDEmpleado      
	 and (tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,',')))      
	 and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
	 and  dp.ImporteTotal1 <> 0
	 ORDER BY ccp.OrdenCalculo ASC    
 
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
 ELSE
 BEGIN
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
		,dp.Descripcion      
		,dp.CantidadMonto as CantidadMonto      
		,dp.CantidadDias as CantidadDias      
		,dp.CantidadVeces as CantidadVeces      
		,dp.CantidadOtro1 as CantidadOtro1      
		,dp.CantidadOtro2 as CantidadOtro2      
		,dp.ImporteGravado as ImporteGravado      
		,dp.ImporteExcento as ImporteExcento      
		,dp.ImporteOtro as ImporteOtro      
		,dp.ImporteTotal1 as ImporteTotal1      
		,dp.ImporteTotal2 ImporteTotal2          
		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales      
	 INTO #tempResultadoFiniquito      
	   from [Nomina].[tblDetallePeriodoFiniquito] dp with (nolock)      
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
	 LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	 LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente      
	 LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago      
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	 INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	 where cp.IDPeriodo = @IDPeriodo      
	 and ccp.Impresion = 1      
	 and dp.IDEmpleado = @IDEmpleado      
	 and (tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,',')))      
	 and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
	 and  dp.ImporteTotal1 <> 0
	 ORDER BY ccp.OrdenCalculo ASC     
	 
	 	  IF(@IDTipoConcepto = '5')      
	 BEGIN      
	  SELECT * FROM #tempResultadoFiniquito      
	  WHERE ImporteTotal1 > 0      
	  ORDER BY OrdenCalculo ASC    
	 END      
	 ELSE      
	 BEGIN      
	  SELECT * FROM #tempResultadoFiniquito      
	   ORDER BY OrdenCalculo ASC    
	 END     
	  DROP TABLE #tempResultadoFiniquito;   
	  
 
 END     
 --select * from #tempResultado       
END
GO
