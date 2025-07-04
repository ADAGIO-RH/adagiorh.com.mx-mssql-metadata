USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCoreLayoutBANAMEX_B](    
	@IDPeriodo int,    
	@FechaDispersion date,    
	@IDLayoutPago int,
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly,
	@MarcarPagados bit = 0,     
	@IDUsuario int      
)    
AS    
BEGIN 
	DECLARE 
		@empleados [RH].[dtEmpleados]      
		,@ListaEmpleados Nvarchar(max)    
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date
		,@IDTipoNomina int 
		,@NombrePeriodo Varchar(20)
		,@ClavePeriodo Varchar(16)
		,@CountEmpleados int 

		-- PARAMETROS
		,@NombreEmpresa Varchar(36) --Razon Social
		,@NoCuenta Varchar(20) --Cuenta Cargo
		,@SecArchivo Varchar(4) --Consecutivo
		,@TipoCuenta Varchar(2) --Tipo Cuenta
		,@NoCliente Varchar(12) --Cliente
		,@IDSucursal int --Cliente--Sucursal
	;	
		--,@ClaveBanco Varchar(6)

 	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos with (nolock)                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
	from @periodo                  
	              
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario=@IDUsuario      

	-- CARGAR PARAMETROS EN VARIABLES
	  
	select  @NoCliente = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cliente'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout 
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Secuencia Archivo'  

	select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout 
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Nombre Empresa'  

	 
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
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cuenta' 

	select @IDSucursal = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Sucursal' 

	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int, IDBanco int, CuentaBancaria Varchar(18)); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago, IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco, pe.tarjeta
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = @IDPeriodo   
			INNER JOIN RH.tblPagoEmpleado pe with (nolock) on pe.IDEmpleado = e.IDEmpleado
			left join Sat.tblCatBancos b with (nolock) on pe.IDBanco = b.IDBanco    
			INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago    
			inner join Nomina.tblCatTiposLayout tl with (nolock) on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp with (nolock) on dp.IDPeriodo = @IDPeriodo    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
		where  pe.IDLayoutPago = @IDLayoutPago  

		MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
		USING #tempempleadosMarcables AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
		WHEN MATCHED THEN
			update                  
		Set                       
			TARGET.IDBanco  = SOURCE.IDBanco                 
			,TARGET.CuentaBancaria   = SOURCE.CuentaBancaria            
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDLayoutPago, IDBanco, CuentaBancaria)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago, SOURCE.IDBanco, SOURCE.CuentaBancaria);

	END
	 -- MARCAR EMPLEADOS COMO PAGADOS

	 -- ENCABEZADO
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    

	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select     
		[App].[fnAddString](1,'1','0',1) --Tipo de registro                            
		+[App].[fnAddString](12,@NoCliente,'0',1) --Numero de Cliente							
		+[App].[fnAddString](6,isnull(format(@FechaDispersion,'ddMMyy'),''),'',2) --Fecha
		+[App].[fnAddString](4,@SecArchivo,'0',1) --Consecutivo
		+[App].[fnAddString](56,'DEPOSITOS POR NOMINA','',1) --Descripción
		+[App].[fnAddString](42,'05','',2) --Naturaleza del archivo
		+[App].[fnAddString](1,'B','',2) --Versión del Layout	  
		+[App].[fnAddString](1,'0','',2) --Volumen
		+[App].[fnAddString](1,'0','',2) --Caracteristicas del Archivo

	 -- ENCABEZADO

	 -- CUERPO
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select
		CASE WHEN ( e.SegundoNombre IS NULL ) OR ( isnull(e.SegundoNombre,'') = '' ) OR ( isnull(e.SegundoNombre,'') = ' ' ) THEN      
		[App].[fnAddString](1,'3','0',1) -- Tipo de Registro
		+[App].[fnAddString](1,'0','0',1)  --Tipo de Operación
		+[App].[fnAddString](3,'001','0',1) -- Clave de la moneda
		+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
		+[App].[fnAddString](2, @TipoCuenta,'',1) --Tipo de cuenta
		+[App].[fnAddString](4,'0000','',2) --Número de sucursal
		+[App].[fnAddString](20,replace(pe.tarjeta,' ',''),'0',1) --Numero de Cuenta
		+[App].[fnAddString](4,substring(e.ClaveEmpleado,2,5),'0',1) --Clave Trabajador
		+[App].[fnAddString](36,'',' ',1) --Espacios en Blanco
		+[App].[fnAddString](55,(isnull(E.paterno,'') + ' ' +isnull(e.materno,'') +' ' +isnull(e.Nombre,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre del Trabajador  
		+[App].[fnAddString](64,'',' ',1) -- Espacios en Blanco
		+[App].[fnAddString](10,'0000000000','0',2) -- Clave del estado
		ELSE
		[App].[fnAddString](1,'3','0',1) -- Tipo de Registro
		+[App].[fnAddString](1,'0','0',1)  --Tipo de Operación
		+[App].[fnAddString](3,'001','0',1) -- Clave de la moneda
		+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
		+[App].[fnAddString](2, @TipoCuenta,'',1) --Tipo de cuenta
		+[App].[fnAddString](4,'0000','',2) --Número de sucursal
		+[App].[fnAddString](20,replace(pe.tarjeta,' ',''),'0',1) --Numero de Cuenta
		+[App].[fnAddString](4,substring(e.ClaveEmpleado,2,5),'0',1) --Clave Trabajador
		+[App].[fnAddString](36,'',' ',1) --Espacios en Blanco
		+[App].[fnAddString](55,(isnull(E.paterno,'') + ' ' +isnull(e.materno,'') +' ' +isnull(e.Nombre,'') +' ' +isnull(e.SegundoNombre,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre del Trabajador  
		+[App].[fnAddString](64,'',' ',1) -- Espacios en Blanco
		+[App].[fnAddString](10,'0000000000','0',2) -- Clave del estado
		END
	FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe with (nolock) on pe.IDEmpleado = e.IDEmpleado
		left join Sat.tblCatBancos b with (nolock) on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl with (nolock) on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp with (nolock) on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago    
			 
	select @CountEmpleados = count(*) from #tempBody
	 -- CUERPO

	-- ENCABEZADO 2
	Declare @SumAll Decimal(16,2)  
  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
	FROM @empleados e    
		INNER join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe with (nolock) on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b with (nolock) on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl with (nolock) on tl.TipoLayout = 'BANAMEX B'    
			and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp with (nolock) on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  

	if object_id('tempdb..#tempHeader2') is not null    drop table #tempHeader2;    
	create table #tempHeader2(Respuesta nvarchar(max)); 

	insert into #tempHeader2(Respuesta)   
	select     
		[App].[fnAddString](1,'2','',2) -- Tipo de Registro
		+[App].[fnAddString](1,'1','',2) -- Tipo de Operación
		+[App].[fnAddString](3,'001','',2) -- Clave de la moneda
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1) --Importe total
		+[App].[fnAddString](2,'01','',2) -- Tipo de Cuenta
		+[App].[fnAddString](4,@IDSucursal,'0',1) -- Número de Sucursal
		+[App].[fnAddString](20,@NoCuenta,'0',1) -- Número de cuenta
		+[App].[fnAddString](20,'',' ',1) -- Espacios en blanco  
	 -- ENCABEZADO 2


	-- PIE
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
    
	create table #tempFooter(Respuesta nvarchar(max));    
  
	insert into #tempFooter(Respuesta)  
	select     
		[App].[fnAddString](1,'4','0',1)    -- Tipo de Registro
		+[App].[fnAddString](3,'001','0',1)   -- Clave de la moneda  
		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) -- Numero de Abonos
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)  --Importe Total de Abonos
		+[App].[fnAddString](6,'1','0',1) --Numero de cargos
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1) --Importe total de Cargos
	-- PIE

	-- SALIDA
	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    
	create table #tempResp(Respuesta nvarchar(max));   

	insert into #tempResp(Respuesta)  
	select respuesta from #tempHeader1  
	union all  
	select respuesta from #tempHeader2  
	union all  
	select respuesta from #tempBody  
	union all  
	select respuesta from #tempFooter  

	select * from #tempResp
	-- SALIDA
END
GO
