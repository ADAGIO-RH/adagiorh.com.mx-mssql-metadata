USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoMXPercepciones]--4114,17,'5'    
(    
 @IDEmpleado int,    
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50) = null,    
 @Codigo varchar(50) = null,    
 @Include varchar(MAX) = null,    
 @Exclude varchar(MAX) = null    
)    
AS    
--BEGIN    
--    SET NOCOUNT ON;
--     IF 1=0 BEGIN
--       SET FMTONLY OFF
--     END
     
--	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
--			----TODOS LOS CONCEPTOS DEL SIGUIENTE BLOQUE SON INFORMATIVO PERO PARA EFECTOS VISUALES EN EL RECIBO DE RD,APARECEN COMO PERCEPCIONES
--	DECLARE @IDConceptoRD010  int, ---SALARIO DEL PERIODO (SALARIO DEL TOTAL DE DIAS VIENGENTES) 
--			@IDConceptoRD011  int, ---AUSENCIAS (FALTAS O PERMISOS)	PERCEPCION "NEGATIVA"
--			@IDConceptoRD012 int, ---LICENCIAS PERCEPCIÓN "NEGATIVA"
--			----SE DEBE OMITIR EL CONCEPTO DE SUELDOS Y SALARIOS
--			@IDConceptoRD101 INT
--            ,@Finiquito bit
--            ,@General bit

--    Select @Finiquito = finiquito,@General = General from nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo
--	select @IDConceptoRD010 = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD010'
--	select @IDConceptoRD011 = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD011'
--	select @IDConceptoRD012 = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD012'
--	select @IDConceptoRD101 = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD101'
--    if(@General = 1)
--    begin
--	select dp.IDPeriodo   
--		,dp.IDEmpleado
--		,cp.Descripcion as Periodo    
--		,cp.IDTipoNomina as IDTipoNomina    
--		,tn.Descripcion as TipoNomina    
--		,tn.IDCliente as IDCliente    
--		,cc.NombreComercial as Cliente    
--		,tn.IDPeriodicidadPago as IDPeriodicidadPago    
--		,pp.Descripcion as PeriodicidadPago    
--		,dp.IDConcepto    
--		,ccp.Codigo    
--		,ccp.Descripcion as Concepto    
--		,ccp.IDTipoConcepto    
--		,tc.Descripcion as TipoConcepto    
--		,ccp.OrdenCalculo    
--		,dp.Descripcion    
--		,dp.CantidadMonto as CantidadMonto    
--		,CONVERT (INT,CASE WHEN ccp.IDConcepto IN (@IDConceptoRD011,@IDConceptoRD012) THEN (dp.CantidadDias*-1)
--			  WHEN CCP.IDConcepto=@IDConceptoRD010 THEN 0.00
--			  ELSE dp.CantidadDias END)
--		 as CantidadDias    
--		,dp.CantidadVeces as CantidadVeces    
--		,dp.CantidadOtro1 as CantidadOtro1    
--		,dp.CantidadOtro2 as CantidadOtro2    
--		,dp.ImporteGravado as ImporteGravado    
--		,dp.ImporteExcento as ImporteExcento    
--		,dp.ImporteOtro as ImporteOtro    
--		,dp.ImporteTotal1 as ImporteTotal1    
--		,dp.ImporteTotal2 ImporteTotal2        
--		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales  
--		-- ,CASE WHEN CCP.Codigo in ('JM101') THEN (SELECT isnull(ImporteTotal1,0) from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodo and IDEmpleado = dp.IDEmpleado and IDConcepto = @IDConceptoJM009) 
--		-- 	WHEN CCP.Codigo in ('JM102','JM104','JM105','JM106') THEN isnull(dp.ImporteTotal1,0) / (m.SalarioDiario/8.0)  
--		-- 	WHEN CCP.Codigo in ('JM103') THEN isnull(dp.ImporteTotal1,0) / (m.SalarioDiario/8.0) /2.0 
--		-- 	WHEN CCP.Codigo in ('JM111') THEN CASE WHEN (DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) <= 10 THEN (CAST((DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) as Decimal(18,2)) * 2) 
--		-- 				ELSE ((((DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) - 10.0) *15.0)+20)
--		-- 				END
--		-- 	WHEN CCP.Codigo in ('JM112') THEN isnull(dp.CantidadVeces,0) 
--		-- 	ELSE 0.00 
--		-- 	END as [HOURS]
--		-- ,CASE WHEN CCP.Codigo in ('JM101','JM102','JM104','JM105','JM106') THEN(m.SalarioDiario/8.0) 
--		-- WHEN  CCP.Codigo in ('JM103') THEN (m.SalarioDiario/8.0) * 2
--		-- ELSE 0.00 END as [RATE]
--	INTO #tempResultado    
--	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
--		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
--		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
--		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
--		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
--		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
--		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
--		inner join RH.tblEmpleadosMaster M with(nolock) on dp.IDEmpleado = m.IDEmpleado
--		LEFT JOIN Nomina.tblControlFiniquitos cf with(nolock) on cf.IDEmpleado = dp.IDEmpleado and cf.IDPeriodo = dp.IDPeriodo
--	where cp.IDPeriodo = @IDPeriodo    
--		and ccp.Impresion = 1    
--		and dp.IDEmpleado = @IDEmpleado    
--		and (tc.IDTipoConcepto=1 or ccp.IDConcepto IN(@IDConceptoRD010,@IDConceptoRD011,@IDConceptoRD012))
--		----SE EXCLUYE SUELDOS Y SALARIOS 
--		AND ccp.IDConcepto not in (@IDConceptoRD101)
--		-- and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
--		-- and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
--		-- and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
--		-- and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
--	ORDER BY ccp.OrdenCalculo ASC    
--    END
    

--    IF(@Finiquito = 1 )
--    BEGIN
--    select dp.IDPeriodo   
--		,dp.IDEmpleado
--		,cp.Descripcion as Periodo    
--		,cp.IDTipoNomina as IDTipoNomina    
--		,tn.Descripcion as TipoNomina    
--		,tn.IDCliente as IDCliente    
--		,cc.NombreComercial as Cliente    
--		,tn.IDPeriodicidadPago as IDPeriodicidadPago    
--		,pp.Descripcion as PeriodicidadPago    
--		,dp.IDConcepto    
--		,ccp.Codigo    
--		,ccp.Descripcion as Concepto    
--		,ccp.IDTipoConcepto    
--		,tc.Descripcion as TipoConcepto    
--		,ccp.OrdenCalculo    
--		,dp.Descripcion    
--		,dp.CantidadMonto as CantidadMonto    
--		,CONVERT (INT,CASE WHEN ccp.IDConcepto IN (@IDConceptoRD011,@IDConceptoRD012) THEN (dp.CantidadDias*-1)
--			  WHEN CCP.IDConcepto=@IDConceptoRD010 THEN 0.00
--			  ELSE dp.CantidadDias END)
--		 as CantidadDias    
--		,dp.CantidadVeces as CantidadVeces    
--		,dp.CantidadOtro1 as CantidadOtro1    
--		,dp.CantidadOtro2 as CantidadOtro2    
--		,dp.ImporteGravado as ImporteGravado    
--		,dp.ImporteExcento as ImporteExcento    
--		,dp.ImporteOtro as ImporteOtro    
--		,dp.ImporteTotal1 as ImporteTotal1    
--		,dp.ImporteTotal2 ImporteTotal2        
--		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales  
--		-- ,CASE WHEN CCP.Codigo in ('JM101') THEN (SELECT isnull(ImporteTotal1,0) from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodo and IDEmpleado = dp.IDEmpleado and IDConcepto = @IDConceptoJM009) 
--		-- 	WHEN CCP.Codigo in ('JM102','JM104','JM105','JM106') THEN isnull(dp.ImporteTotal1,0) / (m.SalarioDiario/8.0)  
--		-- 	WHEN CCP.Codigo in ('JM103') THEN isnull(dp.ImporteTotal1,0) / (m.SalarioDiario/8.0) /2.0 
--		-- 	WHEN CCP.Codigo in ('JM111') THEN CASE WHEN (DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) <= 10 THEN (CAST((DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) as Decimal(18,2)) * 2) 
--		-- 				ELSE ((((DATEDIFF(DAY,CF.FechaAntiguedad, CF.FechaBaja)/365.0) - 10.0) *15.0)+20)
--		-- 				END
--		-- 	WHEN CCP.Codigo in ('JM112') THEN isnull(dp.CantidadVeces,0) 
--		-- 	ELSE 0.00 
--		-- 	END as [HOURS]
--		-- ,CASE WHEN CCP.Codigo in ('JM101','JM102','JM104','JM105','JM106') THEN(m.SalarioDiario/8.0) 
--		-- WHEN  CCP.Codigo in ('JM103') THEN (m.SalarioDiario/8.0) * 2
--		-- ELSE 0.00 END as [RATE]  
--	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
--		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
--		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
--		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
--		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
--		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
--		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
--		inner join RH.tblEmpleadosMaster M with(nolock) on dp.IDEmpleado = m.IDEmpleado
--		LEFT JOIN Nomina.tblControlFiniquitos cf with(nolock) on cf.IDEmpleado = dp.IDEmpleado and cf.IDPeriodo = dp.IDPeriodo
--	where cp.IDPeriodo = @IDPeriodo    
--		and ccp.Impresion = 1    
--		and dp.IDEmpleado = @IDEmpleado    
--        and tc.IDTipoConcepto = 1 
--        and dp.ImporteTotal1 <>0
--		-- and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
--		-- and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
--		-- and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
--		-- and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
--	ORDER BY ccp.OrdenCalculo ASC   
--    RETURN 
--    END

--	if (@Exclude is not null and @Codigo is not null)
--	begin
--		update tr
--			set tr.ImporteTotal1 = tr.ImporteTotal1 - excludes.ImporteTotal1
--		from  #tempResultado tr 
--			join (select dp.IDEmpleado,SUM(dp.ImporteTotal1) as ImporteTotal1
--					from [Nomina].[tblDetallePeriodo] dp with (nolock) 
--						INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
--					where dp.IDPeriodo = @IDPeriodo and ccp.Codigo in (select ITEM from App.Split(@Exclude,','))
--					group by dp.IDEmpleado
--				) as excludes on  tr.IDEmpleado = excludes.IDEmpleado
--		where tr.Codigo = @Codigo
--	end

--	IF(@IDTipoConcepto = '5')    
--	BEGIN    
--		SELECT * FROM #tempResultado    
--		WHERE ImporteTotal1 > 0    
--	ORDER BY OrdenCalculo ASC  
--	END    
--	ELSE    
--	BEGIN    
--		SELECT * FROM #tempResultado   
--		WHERE ImporteTotal1 > 0    
		
--		ORDER BY OrdenCalculo ASC  
--	END 
	
--	DROP TABLE #tempResultado;
--END




BEGIN      
    SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  

	DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

		DECLARE 
			@Finiquito bit
            ,@General bit
			,@IDFiniquito int      
;

 --   Select @Finiquito = ID,@General = General from nomina.tblCatPeriodos c
	--left join Nomina.tblcontrolfiniquitos cf on cf.idperiodo = @IDPeriodo
	--where c.finiquito = 1
       
	   select @IDFiniquito=cf.IDFiniquito from nomina.tblCatPeriodos c
			left join Nomina.tblcontrolfiniquitos cf on cf.idperiodo = c.IDPeriodo
				where c.finiquito = 1 and cf.IDPeriodo = @IDPeriodo and  IDEmpleado=@IDEmpleado
      
	  --select*from Nomina.tblControlFiniquitos

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
