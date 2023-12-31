USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[Reportes].[spCalculoNominaDetallePorEmpleadoANS]1182,147,'1,4'
*/
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoANS]--1182,147,'1,4'    
(    
 @IDEmpleado int,    
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50) = null,    
 @Codigo varchar(50) = null,    
 @Include varchar(MAX) = null,    
 @Exclude varchar(MAX) = null    
)    
AS    
BEGIN    
    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
     
	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
    
    
	select dp.IDPeriodo   
		,dp.IDEmpleado
		,cp.Descripcion as Periodo    
		,cp.IDTipoNomina as IDTipoNomina    
		,tn.Descripcion as TipoNomina    
		,tn.IDCliente as IDCliente    
		,cc.NombreComercial as Cliente    
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
		,CASE WHEN ISNULL(dp.CantidadOtro1,0) <= 0.00 THEN '' ELSE cast(ISNULL(dp.CantidadOtro1,0) as varchar(max)) END as CantidadOtro1    
		,dp.CantidadOtro2 as CantidadOtro2    
		,dp.ImporteGravado as ImporteGravado    
		,dp.ImporteExcento as ImporteExcento    
		,dp.ImporteOtro as ImporteOtro    
		,ISNULL(dp.ImporteTotal1,0) as ImporteTotal1    
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
		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
		and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
	ORDER BY ccp.OrdenCalculo ASC   
	
	IF exists((select ITEM from App.Split(@IDTipoConcepto,',') where item  in (1,4) ))
	BEGIN
	
		INSERT INTO  #tempResultado 
			select dp.IDPeriodo   
			,dp.IDEmpleado
			,cp.Descripcion as Periodo    
			,cp.IDTipoNomina as IDTipoNomina    
			,tn.Descripcion as TipoNomina    
			,tn.IDCliente as IDCliente    
			,cc.NombreComercial as Cliente    
			,tn.IDPeriodicidadPago as IDPeriodicidadPago    
			,pp.Descripcion as PeriodicidadPago    
			,0 as IDConcepto    
			,'' as Codigo    
			,'Días + Vac.' as Concepto    
			,0 as IDTipoConcepto    
			,'' as TipoConcepto    
			,0 as OrdenCalculo    
			,''as Descripcion    
			,SUM(dp.CantidadMonto) as CantidadMonto    
			,sum(dp.CantidadDias) as CantidadDias    
			,sum(dp.CantidadVeces) as CantidadVeces    
			,sum(ISNULL(dp.ImporteTotal1,0)) as CantidadOtro1    
			,sum(dp.CantidadOtro2) as CantidadOtro2    
			,sum(dp.ImporteGravado) as ImporteGravado    
			,sum(dp.ImporteExcento) as ImporteExcento    
			,sum(dp.ImporteOtro) as ImporteOtro    
			,0 as ImporteTotal1    
			,sum(dp.ImporteTotal2) ImporteTotal2        
			,sum(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales    
	   
		from [Nomina].[tblDetallePeriodo] dp with (nolock)    
			LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
			LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
			LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
			LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
			INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
			INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
		where cp.IDPeriodo = @IDPeriodo    
			and dp.IDEmpleado = @IDEmpleado    
			and ((ccp.Codigo in( '002','005','007')) )    
		GROUP BY dp.IDPeriodo   
			,dp.IDEmpleado
			,cp.Descripcion  
			,cp.IDTipoNomina    
			,tn.Descripcion    
			,tn.IDCliente     
			,cc.NombreComercial     
			,tn.IDPeriodicidadPago    
			,pp.Descripcion 
		 

	END
	IF exists((select ITEM from App.Split(@IDTipoConcepto,',') where item  in (2) ))
	BEGIN
		INSERT INTO  #tempResultado 
			select dp.IDPeriodo   
			,dp.IDEmpleado
			,cp.Descripcion as Periodo    
			,cp.IDTipoNomina as IDTipoNomina    
			,tn.Descripcion as TipoNomina    
			,tn.IDCliente as IDCliente    
			,cc.NombreComercial as Cliente    
			,tn.IDPeriodicidadPago as IDPeriodicidadPago    
			,pp.Descripcion as PeriodicidadPago    
			,0 as IDConcepto    
			,'' as Codigo    
			,'Faltas + Inc.' as Concepto    
			,0 as IDTipoConcepto    
			,'' as TipoConcepto    
			,0 as OrdenCalculo    
			,''as Descripcion    
			,SUM(dp.CantidadMonto) as																									CantidadMonto    
			,sum(dp.CantidadDias) as																									CantidadDias    
			,sum(dp.CantidadVeces) as																									CantidadVeces    
			,CASE WHEN sum(ISNULL(dp.ImporteTotal1,0)) <= 0 THEN '' ELSE cast(sum(ISNULL(dp.ImporteTotal1,0)) as varchar(max)) END as	CantidadOtro1    
			,sum(dp.CantidadOtro2) as																									CantidadOtro2    
			,sum(dp.ImporteGravado) as																									ImporteGravado    
			,sum(dp.ImporteExcento) as																									ImporteExcento    
			,sum(dp.ImporteOtro) as																										ImporteOtro    
			,0 as																														ImporteTotal1    
			,sum(dp.ImporteTotal2)																										ImporteTotal2        
			,sum(dp.ImporteAcumuladoTotales) as																							ImporteAcumuladoTotales    
	   
		from [Nomina].[tblDetallePeriodo] dp with (nolock)    
			LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
			LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
			LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
			LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
			INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
			INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
		where cp.IDPeriodo = @IDPeriodo    
			and dp.IDEmpleado = @IDEmpleado    
			and ((ccp.Codigo in( '003','004')) )    
		GROUP BY dp.IDPeriodo   
			,dp.IDEmpleado
			,cp.Descripcion  
			,cp.IDTipoNomina    
			,tn.Descripcion    
			,tn.IDCliente     
			,cc.NombreComercial     
			,tn.IDPeriodicidadPago    
			,pp.Descripcion 
		

	END

    
	if (@Exclude is not null and @Codigo is not null)
	begin
		update tr
			set tr.ImporteTotal1 = tr.ImporteTotal1 - excludes.ImporteTotal1
		from  #tempResultado tr 
			join (select dp.IDEmpleado,SUM(dp.ImporteTotal1) as ImporteTotal1
					from [Nomina].[tblDetallePeriodo] dp with (nolock) 
						INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
					where dp.IDPeriodo = @IDPeriodo and ccp.Codigo in (select ITEM from App.Split(@Exclude,','))
					group by dp.IDEmpleado
				) as excludes on  tr.IDEmpleado = excludes.IDEmpleado
		where tr.Codigo = @Codigo
	end

	IF(@IDTipoConcepto = '5')    
	BEGIN    
		SELECT * 
		FROM #tempResultado    
		where (
			isnull(CantidadMonto    	   ,0) +
			isnull(CantidadDias    		   ,0) +
			isnull(CantidadVeces    	   ,0) +
			--isnull(cast(CantidadOtro1 as decimal(18,4)),0) +
			isnull(CantidadOtro2    	   ,0) +
			isnull(ImporteGravado    	   ,0) +
			isnull(ImporteExcento    	   ,0) +
			isnull(ImporteOtro    		   ,0) +
			isnull(ImporteTotal1    	   ,0) +
			isnull(ImporteTotal2           ,0) +
			isnull(ImporteAcumuladoTotales ,0) 
		) > 0
		ORDER BY OrdenCalculo ASC  
	END    
	ELSE    
	BEGIN    
		SELECT * 
		FROM #tempResultado  
		where (
			isnull(CantidadMonto    	   ,0) +
			isnull(CantidadDias    		   ,0) +
			isnull(CantidadVeces    	   ,0) +
			--isnull(cast(CantidadOtro1 as decimal(18,4)),0) +
			isnull(CantidadOtro2    	   ,0) +
			isnull(ImporteGravado    	   ,0) +
			isnull(ImporteExcento    	   ,0) +
			isnull(ImporteOtro    		   ,0) +
			isnull(ImporteTotal1    	   ,0) +
			isnull(ImporteTotal2           ,0) +
			isnull(ImporteAcumuladoTotales ,0) 
		) > 0
		ORDER BY OrdenCalculo ASC  
	END 
	
END
GO
