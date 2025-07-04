USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoIncapacidades] (
	@dtFiltros Nomina.dtFiltrosRH readonly            
	,@IDUsuario int = 1
) as
	declare 
		@empleados [RH].[dtEmpleados]   
		,@FechaIni date 
		,@FechaFin date 
		,@ClaveEmpleadoInicial varchar(20) = '0'
		,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzz'
	;

	SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')  
	SET @ClaveEmpleadoFinal = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')  
	SET @FechaIni = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
	SET @FechaFin = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  
  
	insert into @empleados                
	exec [RH].[spBuscarEmpleados] --@FechaIni=@FechaIni, @Fechafin = @FechaIni, 
		@dtFiltros = @dtFiltros,@EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal, @IDUsuario = @IDUsuario    

	select 
	   E.RegPatronal  as [REGISTRO PATRONAL]
	   ,E.ClaveEmpleado AS CLAVE
	   ,E.NOMBRECOMPLETO AS NOMBRE
	   ,E.IMSS AS IMSS
	   ,UPPER(IE.Numero) as NUMERO
	   ,isnull(IE.Duracion,0) as DURACION
	   ,FORMAT(IE.Fecha,'dd/MM/yyyy')  as [FECHA INICIO]
	   ,FORMAT(DATEADD(DAY,case when IE.Duracion > 0 THEN IE.Duracion - 1 else 0 end,IE.Fecha),'dd/MM/yyyy') as [FECHA FIN]
	   ,UPPER(TI.Descripcion) as [TIPO INCAPACIDAD]
	   ,UPPER(TRI.Nombre) as [TIPO RIESGO]
	   ,CI.Nombre as [CLASIFICACION INCAPCIDAD]
	   ,(Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) as [DIAS PERIODO]
		,E.RazonSocial AS [RAZON SOCIAL]
		,E.Division AS DIVISION
		,E.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
		,E.CentroCosto AS [CENTRO COSTO]
		,E.Departamento AS DEPARTAMENTO
		,E.Sucursal AS SUCURSAL
		,E.Puesto AS PUESTO
		,E.TiposPrestacion AS [TIPO PRESTACION]
		,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
		,case when EE.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
	from Asistencia.tblIncapacidadEmpleado IE
		INNER JOIN @empleados E
			on IE.IDEmpleado = E.IDEmpleado
		INNER JOIN RH.tblEmpleadosMaster EE
			on EE.IDEmpleado = E.IDEmpleado
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
	ORDER BY  E.RegPatronal ASC ,E.ClaveEmpleado ASC
GO
