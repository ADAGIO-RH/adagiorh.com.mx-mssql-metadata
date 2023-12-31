USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoTHANGOS]--4114,17,'5'    
(    
 @IDEmpleado int,    
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50),    
 @Codigo varchar(50) = null    
)    
AS    
BEGIN    
    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
     
	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
    
    
	select dp.IDPeriodo    
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
		and ccp.Codigo <> '198'
		and (@IDTipoConcepto = '1,3' and ccp.Codigo not in ('001','002','003','004','005','006','007','008','078','079','017','018','019','020','021',
		'022','023','030','032','033','034','010','016','035','036','062','500','501','502','503','504','505','506','507','508','509','510','511','512',
		'513','514','515','516','517','518','519','520','530','531','532','533','540','700','701','702','703','704','699','705','706')) 
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
		WHERE ImporteTotal1 > 0    
		
		ORDER BY OrdenCalculo ASC  
	END 
	
	DROP TABLE #tempResultado;
END
GO
