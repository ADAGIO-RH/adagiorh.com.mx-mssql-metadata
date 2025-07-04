USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoPrestamosEmpleadoImpresos] (
	@ClaveEmpleadoInicial varchar (max) = '0'
	,@IDTipoPrestamo varchar(max)		= ''    
	,@IDEstatusPrestamo varchar(max)	= ''    
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@Titulo Varchar(max)    
		,@TOTALMONTO float
		,@TOTALDESCUENTO float
		,@TOTALSALDO float
        ,@ClaveEmpleadoFinal varchar(max)
	;

	IF object_ID('TEMPDB..#TempPrestamos') IS NOT NULL DROP TABLE #TempPrestamos
	IF object_ID('TEMPDB..#TempSaldo') IS NOT NULL DROP TABLE #TempSaldo
			
	SET DATEFIRST 7;  
  
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 
	    
	SET @Titulo = UPPER('REPORTE DE PRESTAMOS POR COLABORADOR')		

    set @ClaveEmpleadoInicial = CASE WHEN @ClaveEmpleadoInicial = '' THEN '0' ELSE @ClaveEmpleadoInicial END
    set @ClaveEmpleadoFinal = CASE WHEN @ClaveEmpleadoInicial <> '0' THEN @ClaveEmpleadoInicial ELSE 'ZZZZZZZZZZZZZZZZZZZZ' END
    


	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		@EmpleadoIni	= @ClaveEmpleadoInicial
        ,@EmpleadoFin = @ClaveEmpleadoFinal
		,@IDUsuario		= @IDUsuario     



	update E
		set E.Vigente = M.Vigente
	from RH.tblEmpleadosMaster M  WITH(NOLOCK)
		Inner join @dtEmpleados E on M.IDEmpleado = E.IDEmpleado

	select 
		 e.ClaveEmpleado as Clave
		,e.NOMBRECOMPLETO as Nombre
		,ISNULL(Puesto.Codigo,'000') + ' - ' +e.Puesto as [PUESTO]
		,ISNULL(Depto.Codigo,'000')+' - '+JSON_VALUE(Depto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS [DEPARTAMENTO]
		,ISNULL(Suc.Codigo,'000')+' - '+ e.Sucursal as [SUCURSAL]
		,ISNULL(Div.Codigo,'000') +' - '+ JSON_VALUE(Div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS [DIVISION]
		,e.TipoNomina
		,ISNULL(Clientes.Codigo,'000')+' - '+JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) AS [CLIENTE]
		,CASE WHEN e.Vigente = 1 THEN 'SI' ELSE 'NO' END [VIGENTE HOY]
		,JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoPrestacion
		,foto = cg.Valor + e.ClaveEmpleado + '.jpeg'
		,@Titulo as Titulo
		-----------------------
		,p.Codigo as CodigoPrestamo
		,isnull(p.MontoPrestamo,0) as  MontoPrestamo
		,isnull(p.Intereses,0) as Intereses 
		,p.Cuotas
		,p.CantidadCuotas
		,p.FechaCreacion
		,p.FechaInicioPago
		,tpp.Descripcion TipoPrestamo
		,ep.Descripcion EstatusPrestamo
		,(isnull(p.MontoPrestamo,0) + isnull(p.Intereses,0))  - isnull((select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) as Saldo
		,p.IDPrestamo
		,pp.FechaPago
		,pp.ClavePeriodo
		,cp.Descripcion
		,pp.MontoCuota
		,CONVERT(FLOAT, 0)  AS TOTALMONTO
		,CONVERT(FLOAT, 0) AS TOTALDESCUENTO
		,CONVERT(FLOAT, 0) AS TOTALSALDO
		,p.Descripcion as [MOTIVO]
		into #tempPrestamos
		
	from @dtEmpleados e
		left join RH.tblCatClientes			c	with(nolock) on e.IDCliente = c.IDCliente
		left join RH.tblCatSucursales		Suc with (nolock) on Suc.IDSucursal = e.IDSucursal
		left join RH.tblCatDepartamentos	Depto	with (nolock) on Depto.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos			Puesto	with (nolock) on Puesto.IDPuesto = E.IDPuesto
		left join RH.tblCatDivisiones		Div with(nolock) on div.IDDivision = e.IDDivision
		left join RH.tblCatCentroCosto		CC	with(nolock) on CC.IDCentroCosto = e.IDCentroCosto
		left join RH.tblCatClasificacionesCorporativas Clasificacion with(nolock) on Clasificacion.IDClasificacionCorporativa = e.IDClasificacionCorporativa
		left join RH.tblCatClientes					clientes with(nolock) on clientes.IDCliente = e.IDCliente
		left join RH.tblCatTiposPrestaciones		tp with(nolock) on e.IDTipoPrestacion = tp.IDTipoPrestacion
		left join App.tblConfiguracionesGenerales	cg with(nolock) on cg.IDConfiguracion = 'PathFotos'
		left join Nomina.tblPrestamos				p  with(nolock) on e.IDEmpleado = p.IDEmpleado
		left join Nomina.tblCatTiposPrestamo		tpp with(nolock) on tpp.IDTipoPrestamo = p.IDTipoPrestamo
		left join Nomina.tblCatEstatusPrestamo		ep	with(nolock)on ep.IDEstatusPrestamo = p.IDEstatusPrestamo
		CROSS APPLY Nomina.fnPagosPrestamo(p.IDPrestamo) pp 
		left join Nomina.tblCatPeriodos				cp  with(nolock)on pp.IDPeriodo = cp.IDPeriodo	
	where (p.IDTipoPrestamo in ( select item from app.Split( isnull(@IDTipoPrestamo,''),',')) or isnull(@IDTipoPrestamo,'') = '')
	and(p.IDEstatusPrestamo in ( select item from app.Split( isnull(@IDEstatusPrestamo,''),',')) or isnull(@IDEstatusPrestamo,'') = '')


	SELECT @TOTALMONTO		= SUM(MontoPrestamo)	from Nomina.tblPrestamos where Codigo IN (select DISTINCT CodigoPrestamo from #tempPrestamos ) 
	SELECT @TOTALDESCUENTO	= SUM(Cuotas)			from Nomina.tblPrestamos where Codigo IN (select DISTINCT CodigoPrestamo from #tempPrestamos ) 
	
	SELECT (isnull(p.MontoPrestamo,0) + isnull(p.Intereses,0))  - isnull((select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) as SALDO
	into #TempSaldo
	from Nomina.tblPrestamos p with(nolock)
	where Codigo IN (select DISTINCT CodigoPrestamo from #tempPrestamos)

	SELECT @TOTALSALDO = SUM(SALDO) from #TempSaldo

	update p
		set 
			p.TOTALMONTO = @TOTALMONTO,
			P.TOTALDESCUENTO = @TOTALDESCUENTO,
			P.TOTALSALDO = @TOTALSALDO
	FROM #tempPrestamos P

	SELECT * FROM #tempPrestamos
GO
