USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoUltimoContrato](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)
as
	declare 
		@empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2020-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null    
	;

	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')  

	SET DATEFIRST 7;      
      
	select top 1 
		@IDIdioma = dp.Valor      
	from Seguridad.tblUsuarios u with (nolock)     
		Inner join App.tblPreferencias p with (nolock)      
			on u.IDPreferencia = p.IDPreferencia      
		Inner join App.tblDetallePreferencias dp with (nolock)      
			on dp.IDPreferencia = p.IDPreferencia      
		Inner join App.tblCatTiposPreferencias tp with (nolock)      
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL; 
	
	select 
		@FechaIni  = getdate()
		,@FechaFin = getdate()
	
	insert @empleados
	exec RH.spBuscarEmpleados 
		@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@FechaIni		= @FechaIni
		,@FechaFin		= @FechaFin
		,@dtFiltros		= @dtFiltros
		,@IDUsuario		= @IDUsuario

	Select  
		e.ClaveEmpleado AS Clave,
		e.NOMBRECOMPLETO as Nombre,
		e.Departamento,
		e.Sucursal,
		e.Puesto,
		e.Division,
		contratos.Codigo,    
		contratos.Descripcion as [Tipo Contrato],
		isnull(contratos.Descripcion,'') as [Tipo Trabajador],     
		contratos.Descripcion ,    
		format(cast(contratos.FechaIni as date),'dd-MM-yyyy') as [Fecha Inicio],    
		format(cast(contratos.FechaFin as date),'dd-MM-yyyy') as [Fecha Fin],    
		isnull(contratos.Duracion,0) as Duracion,    
		contratos.Descripcion as [Tipo Documento]
	from (select        
				CE.IDContratoEmpleado,    
				CE.IDEmpleado,    
				isnull(CE.IDTipoContrato,0) as IDTipoContrato,    
				TC.Codigo,    
				TC.Descripcion as TipoContrato,
				isnull(CE.IDTipoTrabajador,0) as IDTipoTrabajador,     
				isnull(tt.Descripcion,'') as TipoTrabajador,     
				isnull(CE.IDDocumento,0) as IDDocumento,    
				D.Descripcion ,    
				cast(CE.FechaIni as date) as FechaIni,    
				cast(CE.FechaFin as date) as FechaFin,    
				isnull(ce.Duracion,0) as Duracion,    
				ISNULL(ce.IDTipoDocumento,0) as IDTipoDocumento,    
				td.Descripcion as TipoDocumento,  
				cast(isnull(d.EsContrato,0) as bit) as EsContrato,
				[Row] = ROW_NUMBER()OVER(partition by IDEmpleado order by FechaIni desc)
			from RH.tblContratoEmpleado CE with (nolock) 
				left join Sat.tblCatTiposContrato TC with (nolock)    
					on CE.IDTipoContrato = TC.IDTipoContrato    
				left join RH.tblCatDocumentos D with (nolock)    
					on CE.IDDocumento = D.IDDocumento    
				left join RH.tblCatTipoDocumento td with (nolock)    
					on td.IDTipoDocumento = ce.IDTipoDocumento    
				left join IMSS.tblCatTipoTrabajador tt with (nolock)
					on tt.IDTipoTrabajador = ce.IDTipoTrabajador
			where cast(isnull(d.EsContrato,0) as bit) = 1
			) as contratos
		join @empleados e on contratos.IDEmpleado = e.IDEmpleado
	where contratos.[Row] = 1
	order by e.ClaveEmpleado
GO
