USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAltasBancariasMasivasBanamex](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)
AS
BEGIN
	DECLARE --FILTROS
		@ClaveEmpleadoInicial varchar(20) = '0000000000'
		,@ClaveEmpleadoFinal varchar(20) = 'ZZZZZZZZZZZZ'
		,@IDLayoutPago int
		,@TipoLayoutPago  Varchar(50)
		-- PARAMETROS BANCO
		,@NombreEmpresa Varchar(36) --Razon Social
		,@NoCuenta Varchar(20) --Cuenta Cargo
		,@SecArchivo Varchar(4) --Consecutivo
		,@TipoCuenta Varchar(2) --Tipo Cuenta
		,@NoCliente Varchar(12) --Cliente
		,@IDSucursal int --Sucursal
		,@FechaAlta datetime 
		,@IDUsuarioBancario Varchar(20) 
		;
		
	SELECT @IDLayoutPago = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDLayoutPago'),',')
	SELECT @ClaveEmpleadoInicial = cast(item as varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')
	SELECT @ClaveEmpleadoFinal = cast(item as varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')

	SELECT
		@TipoLayoutPago = TL.TipoLayout
	FROM Nomina.tblLayoutPago LP WITH(NOLOCK)
		inner join Nomina.tblcatTiposLayout TL WITH(NOLOCK) on LP.IDTipoLayout = TL.IDTipoLayout
	WHERE LP.IDLayoutPago = @IDLayoutPago

	IF(@TipoLayoutPago NOT LIKE '%BANAMEX%' )
	BEGIN
		RAISERROR('El layout seleccionado no corresponde con los datos requeridos para la alta masiva.',16,1)
		RETURN ;
	END
	
	-- CARGAR PARAMETROS EN VARIABLES 
	select  @NoCliente = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'No. Cliente'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Secuencia Archivo'  

	select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Nombre Empresa'  
	 
	select @TipoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Tipo Cuenta' 

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'No. Cuenta' 

	select @IDSucursal = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Sucursal' 

	
	select @IDUsuarioBancario = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'IDUsuario' 

	SELECT @FechaAlta = getdate()
	 -- CARGAR PARAMETROS EN VARIABLES

	-- ENCABEZADO
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select     
		[App].[fnAddString](4,@SecArchivo,'0',1) --Consecutivo
	   +[App].[fnAddString](10,isnull(format(@FechaAlta,'dd/MM/yyyy'),''),'',2) --Fecha
	   +[App].[fnAddString](5,isnull(format(@FechaAlta,'HH:mm'),''),'',2) --HORA
	   +[App].[fnAddString](12,@NoCliente,'0',1) --Numero de Cliente
	   +[App].[fnAddString](36,ISNULL(@NombreEmpresa,''),'',2) --NOMBRE de Cliente
	   +[App].[fnAddString](12,@IDUsuarioBancario,'0',1) --NUM REP
	   +[App].[fnAddString](36,'','',2) --NUM REP
	 -- ENCABEZADO


	  -- CUERPO
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select
		 [App].[fnAddString](1,'A','0',1) -- MOVIMIENTO
		+[App].[fnAddString](4,CASE WHEN B.Descripcion = 'BANAMEX' THEN '0000' ELSE B.Codigo END ,'0',1)  --BANCO
		+[App].[fnAddString](2,CASE WHEN B.Descripcion = 'BANAMEX' AND pe.Interbancaria is not null THEN '00' 
									WHEN B.Descripcion = 'BANAMEX' AND pe.Tarjeta is not null THEN '03'
									WHEN B.Descripcion = 'BANAMEX' AND pe.Cuenta is not null THEN '06'
									WHEN B.Descripcion <> 'BANAMEX' AND pe.Interbancaria is not null THEN '61'
									WHEN B.Descripcion <> 'BANAMEX' AND pe.Tarjeta is not null THEN '63'
							ELSE '' END,'0',1)  --TIPO CUENTA
		
		+[App].[fnAddString](4,'0000','0',1) -- PRODUCTO CONSTANTE
		+[App].[fnAddString](2,'00','0',1) -- INSTRUMENTO CONSTANTE
		+[App].[fnAddString](4,ISNULL(PE.SUCURSAL,'0'),'0',1) -- SUCURSAL
		
		+[App].[fnAddString](20,CASE WHEN B.Descripcion = 'BANAMEX' AND pe.Interbancaria is not null THEN pe.Interbancaria
									WHEN B.Descripcion = 'BANAMEX'  AND pe.Tarjeta is not null		 THEN pe.Tarjeta
									WHEN B.Descripcion = 'BANAMEX'  AND pe.Cuenta is not null		 THEN pe.Cuenta
									WHEN B.Descripcion <> 'BANAMEX' AND pe.Interbancaria is not null THEN pe.Interbancaria
									WHEN B.Descripcion <> 'BANAMEX' AND pe.Tarjeta is not null		 THEN pe.Tarjeta
							ELSE '' END,'0',1)  --TIPO CUENTA
		+[App].[fnAddString](2,'01','0',1) -- TIPO PERSONA
		+[App].[fnAddString](55,isnull(e.Nombre,'')+','+(isnull(E.paterno,'') + '/' +isnull(e.materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre del Trabajador  
		+[App].[fnAddString](20,isnull(e.Nombre,'')+isnull(e.SegundoNombre,'')+(isnull(E.paterno,'')+isnull(e.materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre del Trabajador  
		+[App].[fnAddString](3,'001','',2)   --MONEDA MX
		+[App].[fnAddString](14,'99999','0',1)   --IMPORTE MAXIMO
		+[App].[fnAddString](1,'D','',2)   --PERIODICIDAD DE PAGO
		+[App].[fnAddString](18,E.RFC,'',2)   --RFC
		+[App].[fnAddString](2,'04','',2)   --TIPO OPERACION
		+[App].[fnAddString](40,LOWER(isnull(CE.Value,'')),'',2)   --EMAIL
		+[App].[fnAddString](10,'','',2)   --TELEFONO OPCIONAL
		+[App].[fnAddString](2,'','',2)   --COMPAÑIA
	FROM  RH.tblEmpleadosMaster e     
		INNER JOIN RH.tblPagoEmpleado pe with (nolock) on pe.IDEmpleado = e.IDEmpleado
		left join Sat.tblCatBancos b with (nolock) on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl with (nolock) on lp.IDTipoLayout = tl.IDTipoLayout     
		inner join RH.tblCatTipoContactoEmpleado TCE on TCE.IDMedioNotificacion = 'Email'
		left join RH.TblContactoEmpleado CE on e.IDEmpleado = CE.IDEmpleado and ce.IDTipoContactoEmpleado = TCE.IDTipoContacto
	where  pe.IDLayoutPago = @IDLayoutPago 
		and e.ClaveEmpleado between @ClaveEmpleadoInicial and @ClaveEmpleadoFinal

	 -- SALIDA
	 if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    
	create table #tempResp(Respuesta nvarchar(max), ID int identity(1,1));   
	--select * from #tempBody

	insert into #tempResp(Respuesta)  
	select respuesta from #tempHeader1  
	UNION 
	select respuesta from #tempBody  

	select Respuesta from #tempResp order by ID ASC
	-- SALIDA
END
GO
