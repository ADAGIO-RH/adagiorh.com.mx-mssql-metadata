USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     view [ExcelBI].[vwBuscarDetallePeriodo] as
	select
		FORMATMESSAGE('%s [%s]', NOMBRECOMPLETO, ClaveEmpleado) as MiNombre
		,e.NOMBRECOMPLETO as [NombreColaborador]	
		,e.ClaveEmpleado
		,e.IMSS as NSS	
		,e.RFC	
		,e.CURP	
		,e.SalarioDiario*30.00 as [Sueldo Mensual]	
		,e.SalarioDiario
		,e.FechaAntiguedad as [Fecha Antigüedad]
		,e.FechaIngreso as [Fecha Ingreso]	
		,e.IDEmpresa
		,e.Empresa
		,e.Sucursal as Oficina	
		,crp.RegistroPatronal as [Registro Patronal]	
		,e.Area	
		,e.Departamento as Depto	
		,e.CentroCosto as [Centro Costo]	
		,e.Puesto	
		,e.TipoNomina as [Tipo Nómina]	
		,cp.Ejercicio
		,dp.IDPeriodo		
		,UPPER(cp.ClavePeriodo) as [ClavePeriodo]
		,coalesce(UPPER(cp.ClavePeriodo),'')+' '+coalesce(UPPER(substring(meses.Descripcion,1,3)),'')+' '+coalesce(UPPER(cp.Descripcion),'') as FullDescripcionPeriodo
		,UPPER(cp.Descripcion) as Periodo
		,meses.IDMes
		,meses.Descripcion as Mes
		,SUBSTRING(LOWER(meses.Descripcion), 1,3) MesCorto
		,FORMATMESSAGE('%s %d', SUBSTRING(LOWER(meses.Descripcion), 1,3), cp.Ejercicio) as MesAnio
		,bim.Bimestre
		,e.TipoRegimen as Regimen	
		,0.00 as [Sdi Tope]	
		,0.00 as [Sdi Indemniza]	
		,e.TipoContrato as [Tipo Contrato]
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		,case when conceptosVariables.IDConcepto is not null then 1 else 0 end as Variable
		,case when ccp.IDTipoConcepto = 1 and configISN.IDConcepto is null then 1 else 0 end ISN
		--,case when tcc.[Tipo Concepto] = 'CARGAS SOCIALES' then '07-'+tcc.[Tipo Concepto] 
		--	else App.fnAddString(2,isnull(ccp.IDTipoConcepto, '00'), '0',1)+'-'+tcc.[Tipo Concepto] end as TipoConcepto      
		,App.fnAddString(2,tcc.CodigoTipoConcepto, '0',1)+'-'+tcc.[Tipo Concepto] as TipoConcepto    
		--,COALESCE(tcc.[Tipo Concepto], 'DESCONOCIDO')  as TipoConcepto      
		,ccp.OrdenCalculo    
		,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
		,dp.IDReferencia
		,e.SalarioIntegrado
		,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoAnterior](dp.IDReferencia, dp.IDPeriodo)) else 0 end SaldoAnterior
		,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoNuevo](dp.IDReferencia, dp.IDPeriodo))	else 0 end SaldoNuevo
		,ISNULL(dp.ImporteGravado, 0) as ImporteGravado      
		,ISNULL(dp.ImporteExcento, 0) as ImporteExcento      
		,ISNULL(dp.ImporteOtro, 0) as ImporteOtro      
		,ISNULL(dp.ImporteTotal1, 0) as ImporteTotal1      
		,ISNULL(dp.ImporteTotal2, 0) ImporteTotal2          
		,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		INNER JOIN Nomina.tblCatPeriodos cp  on dp.IDPeriodo = cp.IDPeriodo      
		INNER JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto     
		INNER JOIN [dbo].[TblConceptosCodigoFuente]  tcc on tcc.IDConcepto = ccp.IDConcepto and tcc.[Tipo Concepto] != 'OMITIR'
		INNER JOIN RH.tblEmpleadosMaster e  on e.IDEmpleado = dp.IDEmpleado  
		LEFT JOIN Nomina.tblCatTiposPrestamo ctp on ctp.IDConcepto=ccp.IDConcepto
		LEFT JOIN Nomina.tblPrestamos p on p.IDEmpleado = e.IDEmpleado and p.IDPrestamo = dp.IDReferencia
		LEFT JOIN [Nomina].[tblHistorialesEmpleadosPeriodos] hep on hep.IDPeriodo = dp.IDPeriodo
			and hep.IDEmpleado = dp.IDEmpleado
		LEFT JOIN [RH].[tblCatSucursales] sucursalHEP on sucursalHEP.IDSucursal = hep.IDSucursal
		LEFT JOIN RH.tblCatRegPatronal crp on crp.IDRegPatronal = e.IDRegPatronal
		JOIN [Nomina].[tblCatMeses] meses on meses.IDMes = cp.IDMes
		JOIN (
			SELECT
				'Bim 0'+CAST(IDBimestre as varchar(1)) as Bimestre,
				Descripcion,
				CAST(value AS INT) AS IDMes
			FROM Nomina.tblCatBimestres
				CROSS APPLY
					STRING_SPLIT(Meses, ',')
		) as bim on bim.IDMes = cp.IDMes
		LEFT JOIN (
			select Value as IDConcepto from STRING_SPLIT('78,150,72,64,61,11,12', ',')
		) as conceptosVariables on conceptosVariables.IDConcepto = ccp.IDConcepto
		LEFt JOIN (
			select CAST(Value as INT) as IDConcepto, IDEstado
			from Nomina.tblConfigISN
				CROSS APPLY STRING_SPLIT(coalesce(IDConceptos, ''), ',')
		) configISN on configISN.IDEstado = sucursalHEP.IDEstadoSTPS
			and  configISN.IDConcepto = ccp.IDConcepto
	where
		cp.Ejercicio = 2025 and
		ISNULL(cp.Cerrado, 0) = 1 and 
		ISNULL(dp.ImporteAcumuladoTotales, 0) != 0 and
		e.IDEmpresa = 3
	--UNION ALL
	--select
	--	FORMATMESSAGE('%s [%s]', NOMBRECOMPLETO, ClaveEmpleado) as MiNombre
	--	,e.NOMBRECOMPLETO as [NombreColaborador]	
	--	,e.ClaveEmpleado
	--	,e.IMSS as NSS	
	--	,e.RFC	
	--	,e.CURP	
	--	,e.SalarioDiario*30.00 as [Sueldo Mensual]	
	--	,e.SalarioDiario
	--	,e.FechaAntiguedad as [Fecha Antigüedad]
	--	,e.FechaIngreso as [Fecha Ingreso]	
	--	,e.IDEmpresa
	--	,e.Empresa
	--	,e.Sucursal as Oficina	
	--	,crp.RegistroPatronal as [Registro Patronal]	
	--	,e.Area	
	--	,e.Departamento as Depto	
	--	,e.CentroCosto as [Centro Costo]	
	--	,e.Puesto	
	--	,e.TipoNomina as [Tipo Nómina]	
	--	,cp.Ejercicio
	--	,dp.IDPeriodo		
	--	,UPPER(cp.ClavePeriodo) as [ClavePeriodo]
	--	,coalesce(UPPER(cp.ClavePeriodo),'')+' '+coalesce(UPPER(substring(meses.Descripcion,1,3)),'')+' '+coalesce(UPPER(cp.Descripcion),'') as FullDescripcionPeriodo
	--	,UPPER(cp.Descripcion) as Periodo
	--	,meses.IDMes
	--	,meses.Descripcion as Mes
	--	,SUBSTRING(LOWER(meses.Descripcion), 1,3) MesCorto
	--	,FORMATMESSAGE('%s %d', SUBSTRING(LOWER(meses.Descripcion), 1,3), cp.Ejercicio) as MesAnio
	--	,bim.Bimestre
	--	,e.TipoRegimen as Regimen	
	--	,0.00 as [Sdi Tope]	
	--	,0.00 as [Sdi Indemniza]	
	--	,e.TipoContrato as [Tipo Contrato]
	--	,dp.IDConcepto      
	--	,ccp.Codigo      
	--	,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
	--	,ccp.IDTipoConcepto      
	--	,case when conceptosVariables.IDConcepto is not null then 1 else 0 end as Variable
	--	,1 ISN
	--	,App.fnAddString(2,ccp.IDTipoConcepto, '0',1)+'-'+tc.Descripcion as TipoConcepto      
	--	,ccp.OrdenCalculo    
	--	,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
	--	,dp.IDReferencia
	--	,e.SalarioIntegrado
	--	,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoAnterior](dp.IDReferencia, dp.IDPeriodo)) else 0 end SaldoAnterior
	--	,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoNuevo](dp.IDReferencia, dp.IDPeriodo))	else 0 end SaldoNuevo
	--	,ISNULL(dp.ImporteGravado, 0)*-1 as ImporteGravado      
	--	,ISNULL(dp.ImporteExcento, 0)*-1 as ImporteExcento      
	--	,ISNULL(dp.ImporteOtro, 0)	* -1 as ImporteOtro      
	--	,ISNULL(dp.ImporteTotal1, 0)* -1 as ImporteTotal1      
	--	,ISNULL(dp.ImporteTotal2, 0) *-1 as ImporteTotal2          
	--	,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
	--from [Nomina].[tblDetallePeriodo] dp with (nolock)      
	--	INNER JOIN Nomina.tblCatPeriodos cp  on dp.IDPeriodo = cp.IDPeriodo      
	--	INNER JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	--	INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	--	INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	--	INNER JOIN RH.tblEmpleadosMaster e  on e.IDEmpleado = dp.IDEmpleado  
	--	LEFT JOIN Nomina.tblCatTiposPrestamo ctp on ctp.IDConcepto=ccp.IDConcepto
	--	LEFT JOIN Nomina.tblPrestamos p on p.IDEmpleado = e.IDEmpleado and p.IDPrestamo = dp.IDReferencia
	--	LEFT JOIN [Nomina].[tblHistorialesEmpleadosPeriodos] hep on hep.IDPeriodo = dp.IDPeriodo
	--		and hep.IDEmpleado = dp.IDEmpleado
	--	LEFT JOIN [RH].[tblCatSucursales] sucursalHEP on sucursalHEP.IDSucursal = hep.IDSucursal
	--	LEFT JOIN RH.tblCatRegPatronal crp on crp.IDRegPatronal = e.IDRegPatronal
	--	JOIN [Nomina].[tblCatMeses] meses on meses.IDMes = cp.IDMes
	--	JOIN (
	--		SELECT
	--			'Bim 0'+CAST(IDBimestre as varchar(1)) as Bimestre,
	--			Descripcion,
	--			CAST(value AS INT) AS IDMes
	--		FROM Nomina.tblCatBimestres
	--			CROSS APPLY
	--				STRING_SPLIT(Meses, ',')
	--	) as bim on bim.IDMes = cp.IDMes
	--	LEFT JOIN (
	--		select Value as IDConcepto from STRING_SPLIT('52,13,14,132,134,136,18,137,20,21,22,138,139,17', ',')
	--	) as conceptosVariables on conceptosVariables.IDConcepto = ccp.IDConcepto
	--	LEFt JOIN (
	--		select CAST(Value as INT) as IDConcepto, IDEstado
	--		from Nomina.tblConfigISN
	--			CROSS APPLY STRING_SPLIT(coalesce(IDConceptos, ''), ',')
	--	) configISN on configISN.IDEstado = sucursalHEP.IDEstadoSTPS
	--		and  configISN.IDConcepto = ccp.IDConcepto
	--where
	--	ISNULL(cp.Cerrado, 0) = 1 and 
	--	ISNULL(dp.ImporteAcumuladoTotales, 0) != 0 and
	--	ccp.Codigo in ('300', '300A', '300B', '300C', '333')
	--UNION ALL
	--select
	--	FORMATMESSAGE('%s [%s]', NOMBRECOMPLETO, ClaveEmpleado) as MiNombre
	--	,e.NOMBRECOMPLETO as [NombreColaborador]	
	--	,e.ClaveEmpleado
	--	,e.IMSS as NSS	
	--	,e.RFC	
	--	,e.CURP	
	--	,e.SalarioDiario*30.00 as [Sueldo Mensual]	
	--	,e.SalarioDiario
	--	,e.FechaAntiguedad as [Fecha Antigüedad]
	--	,e.FechaIngreso as [Fecha Ingreso]	
	--	,e.IDEmpresa
	--	,e.Empresa
	--	,e.Sucursal as Oficina	
	--	,crp.RegistroPatronal as [Registro Patronal]	
	--	,e.Area	
	--	,e.Departamento as Depto	
	--	,e.CentroCosto as [Centro Costo]	
	--	,e.Puesto	
	--	,e.TipoNomina as [Tipo Nómina]	
	--	,cp.Ejercicio
	--	,dp.IDPeriodo		
	--	,UPPER(cp.ClavePeriodo) as [ClavePeriodo]
	--	,coalesce(UPPER(cp.ClavePeriodo),'')+' '+coalesce(UPPER(substring(meses.Descripcion,1,3)),'')+' '+coalesce(UPPER(cp.Descripcion),'') as FullDescripcionPeriodo
	--	,UPPER(cp.Descripcion) as Periodo
	--	,meses.IDMes
	--	,meses.Descripcion as Mes
	--	,SUBSTRING(LOWER(meses.Descripcion), 1,3) MesCorto
	--	,FORMATMESSAGE('%s %d', SUBSTRING(LOWER(meses.Descripcion), 1,3), cp.Ejercicio) as MesAnio
	--	,bim.Bimestre
	--	,e.TipoRegimen as Regimen	
	--	,0.00 as [Sdi Tope]	
	--	,0.00 as [Sdi Indemniza]	
	--	,e.TipoContrato as [Tipo Contrato]
	--	,dp.IDConcepto      
	--	,ccp.Codigo      
	--	,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
	--	,ccp.IDTipoConcepto      
	--	,case when conceptosVariables.IDConcepto is not null then 1 else 0 end as Variable
	--	,0 ISN
	--	,App.fnAddString(2,ccp.IDTipoConcepto, '0',1)+'-'+tc.Descripcion as TipoConcepto      
	--	,ccp.OrdenCalculo    
	--	,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
	--	,dp.IDReferencia
	--	,e.SalarioIntegrado
	--	,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoAnterior](dp.IDReferencia, dp.IDPeriodo)) else 0 end SaldoAnterior
	--	,case when isnull(ctp.IDTipoPrestamo, 0) != 0 then (select p.MontoPrestamo-SUM(MontoCuota) from [ExcelBI].[fnPagosPrestamoNuevo](dp.IDReferencia, dp.IDPeriodo))	else 0 end SaldoNuevo
	--	,ISNULL(dp.ImporteGravado, 0)as ImporteGravado      
	--	,ISNULL(dp.ImporteExcento, 0)as ImporteExcento      
	--	,ISNULL(dp.ImporteOtro, 0)	as ImporteOtro      
	--	,ISNULL(dp.ImporteTotal1, 0)as ImporteTotal1      
	--	,ISNULL(dp.ImporteTotal2, 0)as ImporteTotal2          
	--	,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
	--from [Nomina].[tblDetallePeriodo] dp with (nolock)      
	--	INNER JOIN Nomina.tblCatPeriodos cp  on dp.IDPeriodo = cp.IDPeriodo      
	--	INNER JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	--	INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	--	INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	--	INNER JOIN RH.tblEmpleadosMaster e  on e.IDEmpleado = dp.IDEmpleado  
	--	LEFT JOIN Nomina.tblCatTiposPrestamo ctp on ctp.IDConcepto=ccp.IDConcepto
	--	LEFT JOIN Nomina.tblPrestamos p on p.IDEmpleado = e.IDEmpleado and p.IDPrestamo = dp.IDReferencia
	--	LEFT JOIN [Nomina].[tblHistorialesEmpleadosPeriodos] hep on hep.IDPeriodo = dp.IDPeriodo
	--		and hep.IDEmpleado = dp.IDEmpleado
	--	LEFT JOIN [RH].[tblCatSucursales] sucursalHEP on sucursalHEP.IDSucursal = hep.IDSucursal
	--	LEFT JOIN RH.tblCatRegPatronal crp on crp.IDRegPatronal = e.IDRegPatronal
	--	JOIN [Nomina].[tblCatMeses] meses on meses.IDMes = cp.IDMes
	--	JOIN (
	--		SELECT
	--			'Bim 0'+CAST(IDBimestre as varchar(1)) as Bimestre,
	--			Descripcion,
	--			CAST(value AS INT) AS IDMes
	--		FROM Nomina.tblCatBimestres
	--			CROSS APPLY
	--				STRING_SPLIT(Meses, ',')
	--	) as bim on bim.IDMes = cp.IDMes
	--	LEFT JOIN (
	--		select Value as IDConcepto from STRING_SPLIT('52,13,14,132,134,136,18,137,20,21,22,138,139,17', ',')
	--	) as conceptosVariables on conceptosVariables.IDConcepto = ccp.IDConcepto
	--	LEFt JOIN (
	--		select CAST(Value as INT) as IDConcepto, IDEstado
	--		from Nomina.tblConfigISN
	--			CROSS APPLY STRING_SPLIT(coalesce(IDConceptos, ''), ',')
	--	) configISN on configISN.IDEstado = sucursalHEP.IDEstadoSTPS
	--		and  configISN.IDConcepto = ccp.IDConcepto
	--where
	--	ISNULL(cp.Cerrado, 0) = 1 and 
	--	ISNULL(dp.ImporteAcumuladoTotales, 0) != 0 and
	--	ccp.Codigo in ('300', '300A', '300B', '300C', '333')
		 
GO
