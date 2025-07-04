USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spCoreLayoutBANORTE](    
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
		,@Emisora Varchar(16)
		,@SecArchivo Varchar(4)
		,@ReferenciaEmpresa varchar(11)
		,@TipoCuenta Varchar(2)
	;

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	-- CARGAR PARAMETROS EN VARIABLES
 
	select  @Emisora = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Emisora'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Secuencia Archivo'

	select  @ReferenciaEmpresa = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  and ctlp.Parametro = 'Clave Banco'  

	select @TipoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Tipo Cuenta' 

	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    
    create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int, IDBanco int, CuentaBancaria Varchar(18)); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago,  IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,
					case when pe.IDBanco = tl.IDBanco then 
							case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') 
							ELSE isnull(replace( pe.Tarjeta,' ',''),'') 
							END 
					else isnull(replace( pe.Interbancaria,' ',''),'') 
					end
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p  on p.IDPeriodo = @IDPeriodo   
			INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado
			left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
			INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
			inner join Nomina.tblCatTiposLayout tl on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
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

	Declare @SumAll Decimal(16,2)  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
	FROM   @empleados e    
		INNER join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl on tl.TipoLayout = 'BANORTE'    
			and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp  on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  

	select @CountEmpleados = count(*) from @empleados e

	 -- HEADER 1
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
    
	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select     
		[App].[fnAddString](1,'H','0',1) --Constante H
		+[App].[fnAddString](2,'NE','0',1) -- Clave del Servicio
		+[App].[fnAddString](5,@Emisora,'0',1) --Emisora
		+[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2) --Fecha de Dispersión
		+[App].[fnAddString](2,@SecArchivo,'0',1) --Consecutivo de archivo
		+[App].[fnAddString](6,@CountEmpleados,'0',1) --Numero de Registros
		+[App].[fnAddString](15, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1) --Importe Total
		+[App].[fnAddString](6,'0','0',1) --Numero de Total de Altas Enviado
		+[App].[fnAddString](15,'0','0',1) --Importe Total de Altas Enviado
		+[App].[fnAddString](6,'0','0',1) --Numero de Total de Bajas Enviado
		+[App].[fnAddString](15,'0','0',1) --Importe Total de Bajas Enviado
		+[App].[fnAddString](6,'0','0',1) -- Numero Total de Cuentas a Verificar
		+[App].[fnAddString](1,'0','0',1) --Accion
		+[App].[fnAddString](77,'0','0',1) --Filler
	 -- HEADER 1

	 -- CUERPO DE EMPLEADOS
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select     
		[App].[fnAddString](1,'D','0',1) --Constante D
		+[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2) --Fecha de Dispersión
		+[App].[fnAddString](10,SUBSTRING (e.ClaveEmpleado,4,6),'0',1) --Clave Empleado
		+[App].[fnAddString](79,' ','',1) --Referencia del servicio
		+[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1) --Importe a pagar por trabajador
		+[App].[fnAddString](3,@ReferenciaEmpresa,'',1) --Clave Banco
		+[App].[fnAddString](2,@TipoCuenta,'',1)
		+[App].[fnAddString](18,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') ELSE isnull(replace( pe.Tarjeta,' ',''),'') END else isnull(replace( pe.Interbancaria,' ',''),'') end,'0'),'0',1) -- Tipo pago -- 01 Cheque a cuenta -- 03 Tarjeta -- 40 CLABE
		+[App].[fnAddString](1,'0','0',1) --Tipo de Movimiento
		+[App].[fnAddString](1,'','',1) --Accion
		+[App].[fnAddString](8,'0','0',1) --Relleno
		+[App].[fnAddString](17,' ','',1) --Filler
	FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado
		left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago    
	
	-- CUERPO DE EMPLEADOS

	-- SALIDA

	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
		
	create table #tempResp(Respuesta nvarchar(max)); 
	 
	insert into #tempResp(Respuesta)  
	select respuesta from #tempHeader1 
	UNION ALL 
	select respuesta from #tempBody

	select * from #tempResp

	 -- SALIDA
END
GO
