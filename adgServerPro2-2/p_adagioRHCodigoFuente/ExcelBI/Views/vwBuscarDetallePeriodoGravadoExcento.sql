USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   view [ExcelBI].[vwBuscarDetallePeriodoGravadoExcento] as
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
		,e.Sucursal as Oficina	
		,crp.RegistroPatronal as [Registro Patronal]	
		,e.Area	
		,e.Departamento as Depto	
		,'Gravable' as Grupo	
		--,'' as [Agrupador 1]	
		--,'' as [Agrupador 2]	
		--,'' as [Agrupador 3]	
		,e.CentroCosto as [Centro Costo]	
		,e.Puesto	
		,e.IDEmpresa
		,e.Empresa
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
		,e.TipoRegimen as Regimen	
		,0.00 as [Sdi Tope]	
		,0.00 as [Sdi Indemniza]	
		,e.TipoContrato as [Tipo Contrato]
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		--,case when tcc.[Tipo Concepto] = 'CARGAS SOCIALES' then '07-'+tcc.[Tipo Concepto] 
		--	else App.fnAddString(2,isnull(ccp.IDTipoConcepto, '00'), '0',1)+'-'+tcc.[Tipo Concepto] end as TipoConcepto      
		,App.fnAddString(2,tcc.CodigoTipoConcepto, '0',1)+'-'+tcc.[Tipo Concepto] as TipoConcepto    
		--,COALESCE(tcc.[Tipo Concepto], 'DESCONOCIDO')  as TipoConcepto           
		,ccp.OrdenCalculo    
		,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
		,dp.IDReferencia
		,e.SalarioIntegrado
		,ISNULL(dp.ImporteGravado, 0) as ImporteGravado      
		,ISNULL(dp.ImporteExcento, 0) as ImporteExcento      
		,ISNULL(dp.ImporteOtro, 0) as ImporteOtro      
		,ISNULL(dp.ImporteGravado, 0) as ImporteTotal1      
		,ISNULL(dp.ImporteTotal2, 0) ImporteTotal2          
		,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
		,ISNULL(dp.ImporteGravado, 0) as Total    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT JOIN Nomina.tblCatPeriodos cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
		LEFT JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
		INNER JOIN [dbo].[TblConceptosCodigoFuente]  tcc on tcc.IDConcepto = ccp.IDConcepto and tcc.[Tipo Concepto] != 'OMITIR'
		INNER JOIN RH.tblEmpleadosMaster e with (nolock)  on e.IDEmpleado = dp.IDEmpleado  
			LEFT JOIN RH.tblCatRegPatronal crp with (nolock) on crp.IDRegPatronal = e.IDRegPatronal
		JOIN [Nomina].[tblCatMeses] meses with (nolock) on meses.IDMes = cp.IDMes
	where
		--cp.IDPeriodo = 24 and 
		
		ISNULL(cp.Cerrado, 0) = 1 and 
		cp.Ejercicio = 2025 and
		ISNULL(dp.ImporteGravado, 0) != 0 
		and tc.IDTipoConcepto = 1 and
		e.IDEmpresa = 3
		
	UNION ALL
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
		,e.Sucursal as Oficina	
		,crp.RegistroPatronal as [Registro Patronal]	
		,e.Area	
		,e.Departamento as Depto	
		,'Gravable' as Grupo	
		--,'' as [Agrupador 1]	
		--,'' as [Agrupador 2]	
		--,'' as [Agrupador 3]	
		,e.CentroCosto as [Centro Costo]	
		,e.Puesto	
		,e.IDEmpresa
		,e.Empresa
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
		,e.TipoRegimen as Regimen	
		,0.00 as [Sdi Tope]	
		,0.00 as [Sdi Indemniza]	
		,e.TipoContrato as [Tipo Contrato]
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		--,case when tcc.[Tipo Concepto] = 'CARGAS SOCIALES' then '07-'+tcc.[Tipo Concepto] 
		--	else App.fnAddString(2,isnull(ccp.IDTipoConcepto, '00'), '0',1)+'-'+tcc.[Tipo Concepto] end as TipoConcepto      
		,App.fnAddString(2,tcc.CodigoTipoConcepto, '0',1)+'-'+tcc.[Tipo Concepto] as TipoConcepto    
		--,COALESCE(tcc.[Tipo Concepto], 'DESCONOCIDO')  as TipoConcepto         
		,ccp.OrdenCalculo    
		,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
		,dp.IDReferencia
		,e.SalarioIntegrado
		--,(ISNULL(dp.ImporteGravado, 0)	+ ISNULL(dp.ImporteGravado, 0)	) * -1 as ImporteGravado      
		--,(ISNULL(dp.ImporteExcento, 0)	+ ISNULL(dp.ImporteExcento, 0)	) * -1 as ImporteExcento      
		--,(ISNULL(dp.ImporteOtro, 0)		+ ISNULL(dp.ImporteOtro, 0)		) * -1 as ImporteOtro      
		--,(ISNULL(dp.ImporteTotal1, 0)	+ ISNULL(dp.ImporteTotal1, 0)	) * -1 as ImporteTotal1      
		--,(ISNULL(dp.ImporteTotal2, 0)	+ ISNULL(dp.ImporteTotal2, 0)	) * -1 as ImporteTotal2          
		,(ISNULL(dp.ImporteGravado, 0)	) * -1 as ImporteGravado      
		,(ISNULL(dp.ImporteExcento, 0)	) * -1 as ImporteExcento      
		,(ISNULL(dp.ImporteOtro, 0)		) * -1 as ImporteOtro      
		,(ISNULL(dp.ImporteTotal1, 0)	) * -1 as ImporteTotal1      
		,(ISNULL(dp.ImporteTotal2, 0)	) * -1 as ImporteTotal2          
		,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
		,ISNULL(dp.ImporteGravado, 0) as Total    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT JOIN Nomina.tblCatPeriodos cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
		LEFT JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto   
		INNER JOIN [dbo].[TblConceptosCodigoFuente]  tcc on tcc.IDConcepto = ccp.IDConcepto and tcc.[Tipo Concepto] != 'OMITIR'   
		INNER JOIN RH.tblEmpleadosMaster e with (nolock)  on e.IDEmpleado = dp.IDEmpleado  
			LEFT JOIN RH.tblCatRegPatronal crp with (nolock) on crp.IDRegPatronal = e.IDRegPatronal
		JOIN [Nomina].[tblCatMeses] meses with (nolock) on meses.IDMes = cp.IDMes
	where ccp.Codigo in ('300', '300A', '300B', '300C') and
	
		ISNULL(cp.Cerrado, 0) = 1 
		and cp.Ejercicio = 2025  and
		e.IDEmpresa = 3
	UNION ALL
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
		,e.Sucursal as Oficina	
		,crp.RegistroPatronal as [Registro Patronal]	
		,e.Area	
		,e.Departamento as Depto	
		,'Excento' as Grupo	
		--,'' as [Agrupador 1]	
		--,'' as [Agrupador 2]	
		--,'' as [Agrupador 3]	
		,e.CentroCosto as [Centro Costo]	
		,e.Puesto	
		,e.IDEmpresa
		,e.Empresa
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
		,e.TipoRegimen as Regimen	
		,0.00 as [Sdi Tope]	
		,0.00 as [Sdi Indemniza]	
		,e.TipoContrato as [Tipo Contrato]
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Codigo+'-'+ccp.Descripcion+ ' Excento' as Concepto      
		,ccp.IDTipoConcepto      
		--,case when tcc.[Tipo Concepto] = 'CARGAS SOCIALES' then '07-'+tcc.[Tipo Concepto] 
		--	else App.fnAddString(2,isnull(ccp.IDTipoConcepto, '00'), '0',1)+'-'+tcc.[Tipo Concepto] end as TipoConcepto      
		,App.fnAddString(2,tcc.CodigoTipoConcepto, '0',1)+'-'+tcc.[Tipo Concepto] as TipoConcepto    
		--,COALESCE(tcc.[Tipo Concepto], 'DESCONOCIDO')  as TipoConcepto   
		,ccp.OrdenCalculo    
		,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
		,dp.IDReferencia
		,e.SalarioIntegrado
		,ISNULL(dp.ImporteGravado, 0) as ImporteGravado      
		,ISNULL(dp.ImporteExcento, 0) as ImporteExcento      
		,ISNULL(dp.ImporteOtro, 0) as ImporteOtro      
		,ISNULL(dp.ImporteExcento, 0) as ImporteTotal1      
		,ISNULL(dp.ImporteTotal2, 0) ImporteTotal2          
		,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
		,ISNULL(dp.ImporteExcento, 0) as Total    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT JOIN Nomina.tblCatPeriodos cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
		LEFT JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
		INNER JOIN [dbo].[TblConceptosCodigoFuente]  tcc on tcc.IDConcepto = ccp.IDConcepto and tcc.[Tipo Concepto] != 'OMITIR'  
		INNER JOIN RH.tblEmpleadosMaster e with (nolock)  on e.IDEmpleado = dp.IDEmpleado  
			LEFT JOIN RH.tblCatRegPatronal crp with (nolock) on crp.IDRegPatronal = e.IDRegPatronal
		JOIN [Nomina].[tblCatMeses] meses with (nolock) on meses.IDMes = cp.IDMes
	where
		--cp.IDPeriodo = 24 and 
		
		ISNULL(cp.Cerrado, 0) = 1 and ISNULL(dp.ImporteExcento, 0) != 0    
		and tc.IDTipoConcepto = 1
		and cp.Ejercicio = 2025  and
		e.IDEmpresa = 3
	UNION ALL
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
		,e.Sucursal as Oficina	
		,crp.RegistroPatronal as [Registro Patronal]	
		,e.Area	
		,e.Departamento as Depto	
		,'ISR Retenido' as Grupo	
		--,'' as [Agrupador 1]	
		--,'' as [Agrupador 2]	
		--,'' as [Agrupador 3]	
		,e.CentroCosto as [Centro Costo]	
		,e.Puesto	
		,e.IDEmpresa
		,e.Empresa
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
		,e.TipoRegimen as Regimen	
		,0.00 as [Sdi Tope]	
		,0.00 as [Sdi Indemniza]	
		,e.TipoContrato as [Tipo Contrato]
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Codigo+'-'+ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		--,case when tcc.[Tipo Concepto] = 'CARGAS SOCIALES' then '07-'+tcc.[Tipo Concepto] 
		--	else App.fnAddString(2,isnull(ccp.IDTipoConcepto, '00'), '0',1)+'-'+tcc.[Tipo Concepto] end as TipoConcepto      
		,App.fnAddString(2,tcc.CodigoTipoConcepto, '0',1)+'-'+tcc.[Tipo Concepto] as TipoConcepto    
		--,COALESCE(tcc.[Tipo Concepto], 'DESCONOCIDO')  as TipoConcepto       
		,ccp.OrdenCalculo    
		,case when dp.Descripcion = '' then ' ' else coalesce(dp.Descripcion,' ') end as Descripcion
		,dp.IDReferencia
		,e.SalarioIntegrado
		,ISNULL(dp.ImporteGravado, 0) as ImporteGravado      
		,ISNULL(dp.ImporteExcento, 0) as ImporteExcento      
		,ISNULL(dp.ImporteOtro, 0) as ImporteOtro      
		,ISNULL(dp.ImporteTotal1, 0) as ImporteTotal1      
		,ISNULL(dp.ImporteTotal2, 0) ImporteTotal2          
		,ISNULL(dp.ImporteAcumuladoTotales, 0) as ImporteAcumuladoTotales       
		,ISNULL(dp.ImporteTotal1, 0) as Total    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT JOIN Nomina.tblCatPeriodos cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
		LEFT JOIN [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER JOIN [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER JOIN [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto   
		INNER JOIN [dbo].[TblConceptosCodigoFuente]  tcc on tcc.IDConcepto = ccp.IDConcepto and tcc.[Tipo Concepto] != 'OMITIR'   
		INNER JOIN RH.tblEmpleadosMaster e with (nolock)  on e.IDEmpleado = dp.IDEmpleado  
			LEFT JOIN RH.tblCatRegPatronal crp with (nolock) on crp.IDRegPatronal = e.IDRegPatronal
		JOIN [Nomina].[tblCatMeses] meses with (nolock) on meses.IDMes = cp.IDMes
	where
		
		ISNULL(cp.Cerrado, 0) = 1 and ISNULL(dp.ImporteTotal1, 0) != 0   
		and tc.IDTipoConcepto = 2
		and ccp.IDCodigoSAT = 2
		and cp.Ejercicio = 2025  and
		e.IDEmpresa = 3
	
GO
