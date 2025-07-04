USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Empleados
--Departamentos
--Sucursales
--Puestos
--Prestaciones
--Clientes
--TiposContratacion
--RazonesSociales
--RegPatronales
--Divisiones
--ClasificacionesCorporativas
--NombreClaveFilter

--exec  Reportes.spReporteBasicoIncapacidadesImpresos  @Clientes = '1',@FechaIni = '2019-10-01',@FechaFin = '2019-11-12',@IDUsuario=1
CREATE proc [Reportes].[spReporteBasicoIncapacidadesImpresos] (
	 @Departamentos				  varchar(max) = ''
	,@Sucursales				  varchar(max) = ''
	,@Puestos					  varchar(max) = ''
	,@Prestaciones				  varchar(max) = ''
	,@Clientes					  varchar(max) = ''
	,@TiposContratacion			  varchar(max) = ''
	,@RazonesSociales			  varchar(max) = ''
	,@RegPatronales				  varchar(max) = ''
	,@Divisiones				  varchar(max) = ''
	,@ClasificacionesCorporativas varchar(max) = ''
	,@TipoIncapacidad			  varchar(max) = ''
	,@FechaIni date 			  
	,@FechaFin date 			  
	,@ClaveEmpleadoInicial varchar(20) = '0'
	,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
	,@IDUsuario int
) as


	select 
		@ClaveEmpleadoInicial = case when @ClaveEmpleadoInicial is null or @ClaveEmpleadoInicial = '' then '0' else @ClaveEmpleadoInicial end
		,@ClaveEmpleadoFinal = case when @ClaveEmpleadoFinal is null or @ClaveEmpleadoFinal = '' then 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzz' else @ClaveEmpleadoFinal end
		
	DECLARE  
		@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

 	declare 
		@empleados [RH].[dtEmpleados]   
		,@dtFiltros Nomina.dtFiltrosRH
		,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE DE INCAPACIDADES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	;

	insert @dtFiltros(Catalogo,Value)
	values
		 ('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Clientes)
		,('TiposContratacion',@TiposContratacion)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('ClasificacionesCorporativas',@ClasificacionesCorporativas)
		,('TipoIncapacidad',@TipoIncapacidad)

	insert into @empleados                
	exec [RH].[spBuscarEmpleados] --@FechaIni=@FechaIni, @Fechafin = @FechaIni, 
		@dtFiltros = @dtFiltros,@EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal, @IDUsuario = @IDUsuario      


	select 
		@Titulo as Titulo
	   ,E.RegPatronal 
	   ,E.ClaveEmpleado
	   ,E.NOMBRECOMPLETO
	   ,E.IMSS
	   ,UPPER(IE.Numero) as Numero
	   ,isnull(IE.Duracion,0) as Duracion
	   ,IE.Fecha as FechaInicio
	   ,DATEADD(DAY,case when IE.Duracion > 0 THEN IE.Duracion - 1 else 0 end,IE.Fecha) as FechaFin
	   ,UPPER(TI.Descripcion) as TipoIncapacidad
	   ,UPPER(TRI.Nombre) as TipoRiesgoIncapacidad
	   ,CI.Nombre as ClasificacionIncapacidad
	   ,(Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) as DiasPeriodo
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
GO
