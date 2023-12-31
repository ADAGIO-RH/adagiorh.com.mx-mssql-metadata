USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoIncapacidadesMoti] (
	@dtFiltros Nomina.dtFiltrosRH readonly            
	,@IDUsuario int = 1
) as
	declare 
		 @empleados [RH].[dtEmpleados]   
		,@FechaIni date 
		,@FechaFin date 
		,@ClaveEmpleadoInicial varchar(20) = '0'
		,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
	;

	SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')  
	SET @ClaveEmpleadoFinal = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')  
	SET @FechaIni = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
	SET @FechaFin = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  

	--Cliente, 
	--Razón Social, 
	--División, 
	--Región, 
	--Centro de Costo, 
	--Departamento,
	--Área, 
	--Sucursal, 
	--Puesto, 
	--Clasificación Corporativa, 
	--Prestación

	--IF OBJECT_ID('tempdb..#tempEmpleados') IS NOT NULL  
	--DROP TABLE #tempEmpleados   
  
insert into @empleados                
	exec [RH].[spBuscarEmpleados] --@FechaIni=@FechaIni, @Fechafin = @FechaIni, 
	@dtFiltros = @dtFiltros,@EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal, @IDUsuario = @IDUsuario    



	/*select 
	   -- E.RegPatronal  as [REGISTRO PATRONAL]
	 --,E.ClaveEmpleado AS CLAVE
	    E.NOMBRECOMPLETO AS NOMBRE
	   ,isnull(IE.Duracion,0) as [DIAS_INCAPACIDAD]
	   ,ISNULL(E.SalarioDiarioReal,0) * 30 AS [Salario_Moti_Mensual]
	   ,(Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) as [DIAS_A_PAGAR]
	   ,ISNULL(e.SalarioDiarioReal,0) as [S.D._Moti]
	   ,ISNULL(E.SalarioDiario,0) as [S.D.IPO]
	   ,ISNULL(E.SalarioIntegrado,0) as [S.D.I.IMSS]
	   ,((Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) * ISNULL(E.SalarioDiarioReal,0)) *  0.6 AS [Total_Incapacidad]
	   ,((Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) * ISNULL(E.SalarioIntegrado,0)) *  0.6 AS [IMSS_Paga]
	   ,(((Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) * ISNULL(E.SalarioDiarioReal,0)) *  0.6) -
	    (((Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) * ISNULL(E.SalarioIntegrado,0)) *  0.6) as [Diferencia] 
	   --,E.IMSS AS IMSS
	 --  ,UPPER(IE.Numero) as NUMERO
	 --  ,FORMAT(IE.Fecha,'dd/MM/yyyy')  as [FECHA INICIO]
	 --  ,FORMAT(DATEADD(DAY,case when IE.Duracion > 0 THEN IE.Duracion - 1 else 0 end,IE.Fecha),'dd/MM/yyyy') as [FECHA FIN]
	 --  ,UPPER(TI.Descripcion) as [TIPO INCAPACIDAD]
	 --  ,UPPER(TRI.Nombre) as [TIPO RIESGO]
	 --  ,CI.Nombre as [CLASIFICACION INCAPCIDAD]
	 --  ,
	 --  ,E.RazonSocial AS [RAZON SOCIAL]
	 --  ,E.Division AS DIVISION
	 --  ,E.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
	 --  ,E.CentroCosto AS [CENTRO COSTO]
	 --  ,E.Departamento AS DEPARTAMENTO
		--,E.Sucursal AS SUCURSAL
		--,E.Puesto AS PUESTO
		--,E.TiposPrestacion AS [TIPO PRESTACION]
		--,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
		--,case when E.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]

	from Asistencia.tblIncapacidadEmpleado IE
		INNER JOIN @empleados E
			on IE.IDEmpleado = E.IDEmpleado
		Left join SAT.tblCatTiposIncapacidad TI
			on TI.IDTIpoIncapacidad = IE.IDTipoIncapacidad
		Left join IMSS.tblCatClasificacionesIncapacidad CI
			on CI.IDClasificacionIncapacidad = IE.IDClasificacionIncapacidad
		Left join IMSS.tblCatTipoRiesgoIncapacidad TRI
			on IE.IDTipoRiesgoIncapacidad = TRI.IDTipoRiesgoIncapacidad 

	WHERE IE.IDIncapacidadEmpleado in (
		SELECT Distinct IDIncapacidadEmpleado
		FROM Asistencia.tblIncidenciaEmpleado 
		where IDIncidencia = 'I' 
			and Fecha Between @FechaIni and @FechaFin
		)
		 and ((IE.IDTipoIncapacidad in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoIncapacidad' and isnull(Value,'')<>''))) 
	ORDER BY  E.RegPatronal ASC
	   ,E.ClaveEmpleado ASC*/

	   IF object_ID('TEMPDB..#TempIncapacidades') IS NOT NULL DROP TABLE #TempIncapacidades

	select 
	    ROW_NUMBER() over(order by e.ClaveEmpleado) as [Numero]
		,e.IDEmpleado
		, ie.IDTipoIncapacidad
	   ,E.NOMBRECOMPLETO AS [Nombre_Completo]
	   ,isnull(IE.Duracion,0) as [Dias_Incapacidad]
	   ,ISNULL(E.SalarioDiarioReal,0) * 30 AS [Salario_Moti_Mensual]
	   ,(Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) as [Dias_a_Pagar_en_el_Periodo]
	   ,CASE WHEN (Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) > 3 THEN 
	    ((Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) - 3) ELSE 0 END as [Dias_a_Pagar_por_Complemento_Moti]
	   ,ISNULL(e.SalarioDiarioReal,0) as [S.D._Moti]
	   ,ISNULL(E.SalarioDiario,0) as [S.D.]
	   ,ISNULL(E.SalarioIntegrado,0) as [S.D.I.IMSS]
	   ,ISNULL(TI.Descripcion,'') as [Tipo_Incapacidad]
	  into #TempIncapacidades
	from Asistencia.tblIncapacidadEmpleado IE
		INNER JOIN @empleados E
			on IE.IDEmpleado = E.IDEmpleado
		Left join SAT.tblCatTiposIncapacidad TI
			on TI.IDTIpoIncapacidad = IE.IDTipoIncapacidad
		Left join IMSS.tblCatClasificacionesIncapacidad CI
			on CI.IDClasificacionIncapacidad = IE.IDClasificacionIncapacidad
		Left join IMSS.tblCatTipoRiesgoIncapacidad TRI
			on IE.IDTipoRiesgoIncapacidad = TRI.IDTipoRiesgoIncapacidad 

	WHERE IE.IDIncapacidadEmpleado in (
		SELECT Distinct IDIncapacidadEmpleado
		FROM Asistencia.tblIncidenciaEmpleado 
		where IDIncidencia = 'I'
				and Fecha Between @FechaIni and @FechaFin
		) and ((IE.IDTipoIncapacidad in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoIncapacidad' and isnull(Value,'')<>''))) 
	ORDER BY  E.RegPatronal ASC
	   ,E.ClaveEmpleado ASC
	   ,IE.IDTipoIncapacidad ASC


	   IF object_ID('TEMPDB..#TempTotalIncapacidades') IS NOT NULL DROP TABLE #TempTotalIncapacidades

	   select 
	    IDEmpleado
	   , IDTipoIncapacidad
	   , [Nombre_Completo]
	   , SUM([Dias_Incapacidad]) as [Dias_Incapacidad]
	   , [Salario_Moti_Mensual]
	   , SUM([Dias_a_Pagar_en_el_Periodo]) as [Dias_a_Pagar_en_el_Periodo]
	   , SUM([Dias_a_Pagar_por_Complemento_Moti]) as [Dias_a_Pagar_por_Complemento_Moti]
	   , [S.D._Moti]
	   , [S.D.]
	   , [S.D.I.IMSS]
	   , [Tipo_Incapacidad]
	   into #TempTotalIncapacidades
	   from #TempIncapacidades
	   group by IDEmpleado
			   , IDTipoIncapacidad
			   , [Nombre_Completo]
			   , [Salario_Moti_Mensual]
			   , [S.D._Moti]
			   , [S.D.]
			   , [S.D.I.IMSS]
			   , [Tipo_Incapacidad]

	   select ROW_NUMBER() over(order by [Nombre_Completo]) as [Numero]
	   , [Nombre_Completo]
	   , [Dias_Incapacidad]
	   , [Salario_Moti_Mensual]
	   , [Dias_a_Pagar_en_el_Periodo]
	   , [Dias_a_Pagar_por_Complemento_Moti]
	   , [S.D._Moti]
	   , [S.D.]
	   , [S.D.I.IMSS]
	   , [Tipo_Incapacidad]
	   , CASE WHEN IDTipoIncapacidad = 1 THEN ([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioDiarioReal,0)
	         WHEN IDTipoIncapacidad = 2 THEN 
				  CASE WHEN ([Dias_a_Pagar_en_el_Periodo]) > 3 then
							((([Dias_a_Pagar_en_el_Periodo] -3) * ISNULL(E.SalarioDiarioReal,0)) *  0.6 )
				  else 0 end 
			 WHEN IDTipoIncapacidad = 3 THEN ([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioDiarioReal,0)
		ELSE 0 END as [Total_Incapacidad]
	   , CASE WHEN IDTipoIncapacidad = 1 THEN ([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioIntegrado,0)
	         WHEN IDTipoIncapacidad = 2 THEN 
				  CASE WHEN ([Dias_a_Pagar_en_el_Periodo]) > 3 then
							((([Dias_a_Pagar_en_el_Periodo]) -3 ) * ISNULL(E.SalarioIntegrado,0)) *  0.6 
				  else 0 end 
			 WHEN IDTipoIncapacidad = 3 THEN ([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioIntegrado,0)
		ELSE 0 END AS [IMSS_Paga]
	   , CASE WHEN IDTipoIncapacidad = 1 THEN ([Dias_a_Pagar_en_el_Periodo]) * (ISNULL(E.SalarioDiarioReal,0) - ISNULL(e.SalarioDiario,0))
	         WHEN IDTipoIncapacidad = 2 THEN 
				  CASE WHEN ([Dias_a_Pagar_en_el_Periodo]) >= 3 then
							((([Dias_a_Pagar_en_el_Periodo]) -3 ) * (ISNULL(E.SalarioDiarioReal,0) - ISNULL(E.SalarioDiario,0)) *  0.6 )
				  else 0 end 
			 WHEN IDTipoIncapacidad = 3 THEN (([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioDiarioReal,0)) - (([Dias_a_Pagar_en_el_Periodo]) * ISNULL(E.SalarioDiario,0))
		ELSE 0.00 END as [TOTAL PAGADO COMPLEMENTO]
	   , '' as [Diferencia] 
	   from #TempTotalIncapacidades inca
	   INNER JOIN @empleados E
			on inca.IDEmpleado = E.IDEmpleado

GO
