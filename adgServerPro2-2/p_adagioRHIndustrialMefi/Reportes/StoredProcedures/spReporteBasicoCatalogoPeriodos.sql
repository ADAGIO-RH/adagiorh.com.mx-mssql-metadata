USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [Reportes].[spReporteBasicoCatalogoPeriodos] (
	@dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
) as

	declare 
		@IDIdioma varchar(20),
		@IDCliente int,
		@IDTipoNomina int,
		@Ejercicio int
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')	

	set @Ejercicio = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) else 0 END  
	
	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) else 0 END  
  
	set @IDCliente = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDCliente'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDCliente'),',')) else 0 END  

	select 
		--p.IDPeriodo
		--,p.IDTipoNomina
		 JSON_VALUE(clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as [CLIENTE]
		,tn.Descripcion	AS [TIPO DE NÓMINA]
		,p.Ejercicio	AS EJERCICIO
		,p.ClavePeriodo AS [CLAVE PERIODO]
		,p.Descripcion	AS PERIODO
		,FORMAT(p.FechaInicioPago, 'dd/MM/yyyy')		AS [FECHA INICIO DE PAGO]
		,FORMAT(p.FechaFinPago, 'dd/MM/yyyy')			AS [FECHA FIN DE PAGO]
		,FORMAT(p.FechaInicioIncidencia, 'dd/MM/yyyy')	AS [FECHA INICIO DE INCIDENCIAS]
		,FORMAT(p.FechaFinIncidencia, 'dd/MM/yyyy')		AS [FECHA FIN DE INCIDENCIAS]
		,p.Dias AS DÍAS
		,CASE WHEN ISNULL(p.AnioInicio, 0) = 1 THEN 'SI' ELSE 'NO' END	AS [INICIO DE AÑO]
		,CASE WHEN ISNULL(p.AnioFin, 0) = 1 THEN 'SI' ELSE 'NO' END		AS [FIN DE AÑO]
		,CASE WHEN ISNULL(p.MesInicio, 0) = 1 THEN 'SI' ELSE 'NO' END	AS [INICIO DE MES]
		,CASE WHEN ISNULL(p.MesFin, 0) = 1 THEN 'SI' ELSE 'NO' END		AS [FIN DE MES]
		,JSON_VALUE(mes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [MES DE ACUMULACIÓN]
		,CASE WHEN ISNULL(p.BimestreInicio, 0) = 1 THEN 'SI' ELSE 'NO' END	AS [INICIO DE BIMESTRE]
		,CASE WHEN ISNULL(p.BimestreFin, 0) = 1 THEN 'SI' ELSE 'NO' END		AS [FIN DE BIMESTRE]
		,CASE WHEN ISNULL(p.Cerrado, 0) = 1 THEN 'SI' ELSE 'NO' END		AS [CERRADO]
		,CASE WHEN ISNULL(p.General, 0) = 1 THEN 'SI' ELSE 'NO' END		AS [GENERAL]
		,CASE WHEN ISNULL(p.Finiquito, 0) = 1 THEN 'SI' ELSE 'NO' END	AS [FINIQUITO]
		,CASE WHEN ISNULL(p.Especial, 0) = 1 THEN 'SI' ELSE 'NO' END	AS [ESPECIAL]
	from Nomina.tblCatPeriodos p
		join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = p.IDTipoNomina
		join RH.tblCatClientes clientes on clientes.IDCliente = tn.IDCliente
		join Nomina.tblCatMeses mes on mes.IDMes = p.IDMes
	where (p.IDTipoNomina = @IDTipoNomina or isnull(@IDTipoNomina, 0) = 0)
		and (tn.IDCliente = @IDCliente or isnull(@IDCliente, 0) = 0)		
		and (tn.IDCliente = @IDCliente or isnull(@IDCliente, 0) = 0)		
		and (p.Ejercicio = @Ejercicio or isnull(@Ejercicio, 0) = 0)
GO
