USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spCoreLayoutBANAMEX_D](    
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
		,@NoCliente Varchar(12)
		,@SecArchivo Varchar(4)
		,@NombreEmpresa Varchar(36)
		,@TipoCuenta Varchar(2)
		,@NoCuenta Varchar(20)
		,@ClaveBanco Varchar(6)
	;

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario=@IDUsuario    
	
	-- CARGAR PARAMETROS EN VARIABLES
	 
	select  @NoCliente = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cliente'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Secuencia Archivo'  

	select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Nombre Empresa'  
	 
	select @TipoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Tipo Cuenta' 

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cuenta' 

	select @ClaveBanco = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Clave Banco' 

	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int, IDBanco int, CuentaBancaria Varchar(18)); 
    
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago, IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,
			case when pe.IDBanco = tl.IDBanco then 
				case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') 
				ELSE isnull(replace( pe.Tarjeta,' ',''),'') 
				END 
			else isnull(replace( pe.Interbancaria,' ',''),'') 
			end
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

	-- HEADER 1
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select     
		[App].[fnAddString](1,'1','0',1)     
		+[App].[fnAddString](12,@NoCliente,'0',1)
		+[App].[fnAddString](6,isnull(format(@FechaDispersion,'yyMMdd'),''),'',2)      
		+[App].[fnAddString](4,@SecArchivo,'0',1)     
		+[App].[fnAddString](36,@NombreEmpresa,'',2)     
		+[App].[fnAddString](20,@NombrePeriodo,'',2)     
		+[App].[fnAddString](2,'15','',2)     
		+[App].[fnAddString](1,'D','',2)     
		+[App].[fnAddString](2,'01','',2)     
	 -- HEADER 1

	 -- CUERPO DE EMPLEADOS
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select     
		[App].[fnAddString](1,'3','0',1)    
		+[App].[fnAddString](1,'0','0',1) 
		+[App].[fnAddString](3,isnull(case when pe.IDBanco = tl.IDBanco then '001' else '002' end ,'0'),'0',1) -- 001 Banamex -- 002 INTERBANCARIO
		+[App].[fnAddString](2,'01','0',1) 
		+[App].[fnAddString](3,'001','0',1) -- MONEDA MXN
		+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1) 
		+[App].[fnAddString](2,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN '01' ELSE '03' END else '40' end,'0'),'0',1) -- Tipo pago -- 01 Cheque a cuenta -- 03 Tarjeta -- 40 CLABE 
		+[App].[fnAddString](20,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') ELSE isnull(replace( pe.Tarjeta,' ',''),'') END else isnull(replace( pe.Interbancaria,' ',''),'') end,'0'),'0',1) -- Tipo pago -- 01 Cheque a cuenta -- 03 Tarjeta -- 40 CLABE 
		+[App].[fnAddString](16,@ClavePeriodo,'',2) -- PERIODO
		+[App].[fnAddString](55,(isnull(E.Nombre,'')+isnull(e.SegundoNombre,'')+','+isnull(e.Paterno,'')+'/'+isnull(e.Materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)    
		+[App].[fnAddString](140,'','',2)
		+[App].[fnAddString](6,@ClaveBanco,'',2)
		+[App].[fnAddString](152,'','',2)
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
			  
	select @CountEmpleados = count(*) from #tempBody
	-- CUERPO DE EMPLEADOS
	-- HEADER 2
	
	Declare @SumAll Decimal(16,2)  
  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
	FROM   @empleados e    
		INNER join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl on tl.TipoLayout = 'BANAMEX D'    
			and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  
	
	if object_id('tempdb..#tempHeader2') is not null drop table #tempHeader2;    
	create table #tempHeader2(Respuesta nvarchar(max)); 

	insert into #tempHeader2(Respuesta)   
	select     
		[App].[fnAddString](1,'2','0',1)     
		+[App].[fnAddString](1,'1','0',1)     
		+[App].[fnAddString](3,'001','0',1)     
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)   
		+[App].[fnAddString](2,'01','0',1)   
		+[App].[fnAddString](20,@NoCuenta,'0',1)     
		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1)     
			 
	-- HEADER 2

	-- FOOTER
	      
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
	create table #tempFooter(Respuesta nvarchar(max));    
  
	insert into #tempFooter(Respuesta)  
	select     
		[App].[fnAddString](1,'4','0',1)     
		+[App].[fnAddString](3,'001','0',1)     
		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) 
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)    
		+[App].[fnAddString](6,'1','0',1)     
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)    
	-- FOOTER

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
