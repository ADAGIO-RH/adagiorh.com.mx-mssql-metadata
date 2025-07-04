USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleado]--4114,17,'5'    
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
     
	  DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
    
    
	select dp.IDPeriodo   
		,dp.IDEmpleado
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
		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
		and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
	ORDER BY ccp.OrdenCalculo ASC    
    
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
