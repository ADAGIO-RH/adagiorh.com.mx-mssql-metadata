USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoJMInformativos]--4114,17,'5'    
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
	 DECLARE @Ejercicio int,
	 @MesIni int = 1,
	 @IDMes int;

	 select @Ejercicio = Ejercicio from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo
     
	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
    	IF OBJECT_ID('tempdb..#RangoMes') IS NOT NULL DROP TABLE #RangoMes    
		    	IF OBJECT_ID('tempdb..#solo') IS NOT NULL DROP TABLE #solo    
				IF OBJECT_ID('tempdb..#acumuladoMes') IS NOT NULL DROP TABLE acumuladoMes    




	
	select    @IDMES = IDMes   
	from [Nomina].[tblDetallePeriodo] dp1 with (nolock)    
		inner join [Nomina].[tblCatPeriodos] cp with (nolock) on dp1.IDPeriodo = cp.IDPeriodo    
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp1.IDConcepto = ccp.IDConcepto       
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
		inner join RH.tblEmpleadosMaster M with(nolock) on dp1.IDEmpleado = m.IDEmpleado
		where  cp.IDPeriodo = @IDPeriodo -- and cp.Ejercicio = @Ejercicio  and IDMES>=@MesIni AND IDMES<=@IDMES
	
	select    
		 dp.IDEmpleado 
		,dp.IDConcepto    
		,ccp.Codigo    
		,ccp.Descripcion as Concepto    
		,SUM(dp.ImporteOtro) as ImporteOtro    
		,SUM(dp.ImporteTotal1) as ImporteTotal1    
		,SUM(dp.ImporteTotal2 )ImporteTotal2        
		,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales  
		,ccp.OrdenCalculo
		,cp.IDMes as IDMes

	INTO #tempResultado    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
		inner join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto  
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
		inner join RH.tblEmpleadosMaster M with(nolock) on dp.IDEmpleado = m.IDEmpleado
		where (IDMES between @MesIni and @IDMes) and cp.Ejercicio = @Ejercicio  
		and ccp.Impresion = 1    
		and dp.IDEmpleado = @IDEmpleado    
		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
		and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
	group by 
	dp.IDEmpleado 
	,dp.IDConcepto    
	,ccp.Codigo    
	,ccp.Descripcion
	,ImporteTotal1    
	,ImporteTotal2        
	,ImporteAcumuladoTotales
	,ccp.OrdenCalculo
	,cp.IDMes

	ORDER BY IDMES ASC    
   
   --select*from #tempResultado
   
	select  distinct  IDMes INTO #RangoMes  from #tempResultado
	--select *from #RangoMes
	

--		select *
----select*from [Nomina].[tblDetallePeriodo]
----select*from Nomina.tblCatPeriodos
-- from #RangoMes r
--		inner join  [Nomina].[tblDetallePeriodo] dp on @IDPeriodo = dp.IDPeriodo
--		inner join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
--		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
--		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
--		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
--		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto  
--		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
--		inner join RH.tblEmpleadosMaster M with(nolock) on dp.IDEmpleado = m.IDEmpleado
--		--cross apply  Nomina.[fnObtenerAcumuladoPorConceptoPorMes] (M.IDEmpleado,dp.IDConcepto,r.IDMes,@IDperiodo) as acummm
--		where ccp.Impresion = 1 --and    cp.Ejercicio = @Ejercicio  and @IDMes>0 AND @IDMes<=6
--		and dp.IDEmpleado = @IDEmpleado    
--		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
--		and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
--		and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
--		and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
	
--		ORDER BY ccp.OrdenCalculo ASC   

		 select  
		 IDEmpleado 
		,IDConcepto    
		,Codigo    
		,Concepto as Concepto    
		,SUM(ImporteOtro) as ImporteOtro    
		,SUM(ImporteTotal1) as ImporteAcumuladoTotales     
		,SUM(ImporteTotal2 )ImporteTotal2        
		,CAST(CONVERT(VARCHAR(20),SUM(ImporteAcumuladoTotales) OVER (PARTITION BY IDConcepto   
                                            ORDER BY IDConcepto   
                                            ),1) AS DEC(18, 4))as ImporteTotal1 
		,OrdenCalculo
		,IDMes as IDMes
		
		 into #solo from #tempResultado rm
											group by IDEmpleado,IDConcepto,Codigo, Concepto,ImporteOtro,ImporteTotal2, OrdenCalculo,IDMes,ImporteAcumuladoTotales
		order by IDEmpleado,IDConcepto,Codigo, Concepto,ImporteOtro,ImporteTotal2,OrdenCalculo, IDMes,ImporteAcumuladoTotales
		
		select *from #solo where IDMes=1 

	


   
		
		--cross apply  Nomina.[fnObtenerAcumuladoPorConceptoPorMes] (M.IDEmpleado,dp.IDConcepto,r.IDMes,@IDperiodo) as acummm
		--where ccp.Impresion = 1 --and    cp.Ejercicio = @Ejercicio  and @IDMes>0 AND @IDMes<=6
		--and dp.IDEmpleado = @IDEmpleado    
		--and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		--and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
		--and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		--and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
				
		
		--ORDER BY ccp.OrdenCalculo ASC   

				--where #RangoMes.IDMes>=@MesIni AND #RangoMes.IDMes<=@IDMES

	--	and ccp.Impresion = 1    
	--	and dp.IDEmpleado = @IDEmpleado    
	--	and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
	--	and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
	--	and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
	--	and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    

	--ORDER BY IDMES ASC    



		--select
		-- dp.IDEmpleado 
		--,dp.IDConcepto    
		--,ccp.Codigo    
		--,ccp.Descripcion as Concepto    
		--,SUM(dp.ImporteOtro) as ImporteOtro    
		--,SUM(dp.ImporteTotal1) as ImporteTotal1    
		--,SUM(dp.ImporteTotal2 )ImporteTotal2        
		--,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales  
		--,ccp.OrdenCalculo
		--,cp.IDMes as IDMes
		--from Nomina.[fnObtenerAcumuladoPorConceptoPorMes](@IDEmpleado,@Codigo,@IDMes,@Ejercicio)
		--inner join  [Nomina].[tblDetallePeriodo] dp on @IDPeriodo = dp.IDPeriodo
		--		inner join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    

		--	LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
		--LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
		--LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
		--INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto  
		--INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
		--inner join RH.tblEmpleadosMaster M with(nolock) on dp.IDEmpleado = m.IDEmpleado
		--inner join #RangoMes on IDMes = IDMES
		--where cp.Ejercicio = @Ejercicio  and IDMES>=@MesIni AND IDMES<=@IDMES
		--and ccp.Impresion = 1    
		--and dp.IDEmpleado = @IDEmpleado    
		--and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		--and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
		--and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		--and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    


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
		SELECT * FROM #tempResultado    
		WHERE ImporteTotal1 > 0    
	ORDER BY OrdenCalculo ASC  
	END    
	ELSE    
	BEGIN    
		SELECT * FROM #tempResultado   
		WHERE ImporteTotal1 > 0    
		
		ORDER BY OrdenCalculo ASC  
	END 
	
	DROP TABLE #tempResultado;
END
GO
