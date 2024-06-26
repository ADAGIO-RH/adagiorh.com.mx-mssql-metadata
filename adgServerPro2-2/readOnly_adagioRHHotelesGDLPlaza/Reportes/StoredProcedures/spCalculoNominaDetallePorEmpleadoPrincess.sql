USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoPrincess]--4114,17,'5'    
(    
 @IDEmpleado int,    
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50),    
 @Codigo varchar(50) = null    
)    
AS    
BEGIN    
	SET NOCOUNT ON;
	IF 1=0 
	BEGIN
		SET FMTONLY OFF
	END
     
	declare 
		@ValesPercepcion varchar(20) = '135'
		,@ValesDeduccion varchar(20) = '311'
		
		,@TotalValesPercepcion decimal(18,2) = 0.00
		,@TotalValesDeduccion  decimal(18,2) = 0.00
	;

	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
    
	select 
		dp.IDEmpleado    
		,dp.IDPeriodo    
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
		--and cp.Codigo not 
	ORDER BY ccp.OrdenCalculo ASC    

 --select * from #tempResultado    
    
	IF(@IDTipoConcepto = '5')    
	BEGIN    		
		select 
			dp.IDEmpleado    
			,dp.IDPeriodo    
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
			,dp.CantidadOtro1 as CantidadOtro1    
			,dp.CantidadOtro2 as CantidadOtro2    
			,dp.ImporteGravado as ImporteGravado    
			,dp.ImporteExcento as ImporteExcento    
			,dp.ImporteOtro as ImporteOtro    
			,dp.ImporteTotal1 as ImporteTotal1    
			,dp.ImporteTotal2 ImporteTotal2        
			,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales    
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
			and (ccp.Codigo = @ValesPercepcion)
		UNION
		SELECT * FROM #tempResultado    
		WHERE ImporteTotal1 > 0    
	END    
	ELSE    
	BEGIN  
		if (@IDTipoConcepto in ('1','2'))
		begin
			delete from #tempResultado where Codigo in ('135','311') -- Eliminamos los VALES DE DESPENSA de las percepciones
		end;

		if (@Codigo = '550')
		begin
			update tr
				set tr.ImporteTotal1 = tr.ImporteTotal1 - vales.ImporteTotal1
			from  #tempResultado tr 
				join (select dp.*
					  from [Nomina].[tblDetallePeriodo] dp with (nolock) 
							INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
						where dp.IDPeriodo = @IDPeriodo and ccp.Codigo = @ValesPercepcion
					) as vales on  tr.IDEmpleado = vales.IDEmpleado
			where tr.Codigo = '550'
		end;

		if (@Codigo = '560')
		begin
			update tr
				set tr.ImporteTotal1 = tr.ImporteTotal1 - vales.ImporteTotal1
			from  #tempResultado tr 
				join (select dp.*
					  from [Nomina].[tblDetallePeriodo] dp with (nolock) 
							INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
						where dp.IDPeriodo = @IDPeriodo and ccp.Codigo = @ValesDeduccion
					) as vales on  tr.IDEmpleado = vales.IDEmpleado
			where tr.Codigo = '560'
		end;


		SELECT * FROM #tempResultado    
		ORDER BY OrdenCalculo ASC  
	END    

	DROP TABLE #tempResultado;
END
GO
