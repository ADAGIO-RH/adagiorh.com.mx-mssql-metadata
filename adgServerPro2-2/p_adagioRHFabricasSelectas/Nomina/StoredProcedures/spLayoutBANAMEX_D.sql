USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spLayoutBANAMEX_D]--2,'2018-12-27',8,0    
(    
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
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'No. Cliente'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Secuencia Archivo'  

	select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
	and ctlp.Parametro = 'Nombre Empresa'  
	 
	select @TipoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Tipo Cuenta' 

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'No. Cuenta' 

	select @ClaveBanco = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Clave Banco' 

	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p    
				on p.IDPeriodo = @IDPeriodo   
			INNER JOIN RH.tblPagoEmpleado pe    
				on pe.IDEmpleado = e.IDEmpleado
			left join Sat.tblCatBancos b  
				on pe.IDBanco = b.IDBanco    
			INNER JOIN  Nomina.tblLayoutPago lp    
				on lp.IDLayoutPago = pe.IDLayoutPago    
			inner join Nomina.tblCatTiposLayout tl    
				--on tl.TipoLayout = 'SCOTIABANK'    
				on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp    
				on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
					and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
					and dp.IDEmpleado = e.IDEmpleado    
		where  pe.IDLayoutPago = @IDLayoutPago  

		MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
		USING #tempempleadosMarcables AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);
	END
	-- MARCAR EMPLEADOS COMO PAGADOS

	-- HEADER 1  Registro de Control

	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select     
		 [App].[fnAddString](1,'1','0',1)     -- Tipo de Registro (Siempre es 1)
		+[App].[fnAddString](12,@NoCliente,'0',1)  -- Numero de Identificación del cliente
		+[App].[fnAddString](6,isnull(format(@FechaDispersion,'yyMMdd'),''),'',2)     -- Fecha de Pago yyMMdd 
		+[App].[fnAddString](4,@SecArchivo,'0',1)     -- Secuencia del Archivo
		+[App].[fnAddString](36,@NombreEmpresa,'',2)    -- Nombre de la Empresa 
		+[App].[fnAddString](20,@NombrePeriodo,'',2)    -- Descripción del Archivo 
		+[App].[fnAddString](2,'15','',2)     -- Naturaleza del Archivo (Siempre será 15)
		+[App].[fnAddString](1,'D','',2)     -- Versión del Layout
		+[App].[fnAddString](2,'01','',2)     -- Tipo de cargo (01 = Cargo Global)
	
	-- FIN HEADER 1

	 -- CUERPO DE EMPLEADOS  Registro Detalles

	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select     
		 [App].[fnAddString](1,'3','0',1)  -- Tipo de Registro (Siempre es 3)  
		+[App].[fnAddString](1,'0','0',1)  -- Tipo de Operación (Siempre es 0 Abono)
		+[App].[fnAddString](3,isnull(case when pe.IDBanco = tl.IDBanco then '001' else '002' end ,'0'),'0',1) --Metodo de pago 001= Banamex, 002 Interbancario
		+[App].[fnAddString](2,'01','0',1) -- Tipo de Pago (01 = Abono / Nomina)
		+[App].[fnAddString](3,'001','0',1) -- Clave de la moneda (001 = Pesos M.N)
		+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1) -- Importe
		+[App].[fnAddString](2,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN '01' ELSE '03' END else '40' end,'0'),'0',1) -- Tipo Cuenta abono:  01 = Cheque a cuenta, 03 = Plasticos,  40 CLABE 
		+[App].[fnAddString](20,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') ELSE isnull(replace( pe.Tarjeta,' ',''),'') END else isnull(replace( pe.Interbancaria,' ',''),'') end,'0'),'0',1) -- Tipo pago -- 01 Cheque a cuenta -- 03 Tarjeta -- 40 CLABE 
		+[App].[fnAddString](16,@ClavePeriodo,'',2) -- Referencia del pago (PERIODO)
		
		--+[App].[fnAddString](55,(isnull(E.Nombre,'')+isnull(e.SegundoNombre,'')+','+isnull(e.Paterno,'')+'/'+isnull(e.Materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)    -- Beneficiario
		+[App].[fnAddString](55,(isnull(E.Nombre,'')+CASE WHEN e.SegundoNombre is null THEN '' ELSE ' '+e.SegundoNombre END+','+isnull(e.Paterno,'')+'/'+isnull(e.Materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)    -- Beneficiario
		


		+[App].[fnAddString](35,'','',2) -- Referencia 1
		+[App].[fnAddString](35,'','',2) -- Referencia 2
		+[App].[fnAddString](35,'','',2) -- Referencia 3
		+[App].[fnAddString](35,'','',2) -- Referencia 4
		+[App].[fnAddString](4,@ClaveBanco,'',2)  -- Clave del Banco
		+[App].[fnAddString](2,'00','',2)  -- Plazo (00 = Mismo día)
		+[App].[fnAddString](14,'','',2) -- RFC 
		+[App].[fnAddString](8,'','',2) -- IVA
		+[App].[fnAddString](80,'','',2) -- Para uso futuro
		+[App].[fnAddString](50,'','',2) -- Para uso futuro
	FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p    
			on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe    
			on pe.IDEmpleado = e.IDEmpleado
		left join Sat.tblCatBancos b  
			on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp    
			on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl    
			--on tl.TipoLayout = 'SCOTIABANK'    
			on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago    
	--SELECT * from  @empleados  e
			  
	select @CountEmpleados = count(*) from #tempBody
	
	--FIN  CUERPO DE EMPLEADOS
	
	
	Declare @SumAll Decimal(16,2)  
  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
	FROM   @empleados e    
		INNER join Nomina.tblCatPeriodos p    
			on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe    
			on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b  
			on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp    
			on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl    
			on tl.TipoLayout = 'BANAMEX D'    
				and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  
	
	-- HEADER 2 Registro Global

	if object_id('tempdb..#tempHeader2') is not null drop table #tempHeader2;    
	create table #tempHeader2(Respuesta nvarchar(max)); 

	insert into #tempHeader2(Respuesta)   
	select     
		 [App].[fnAddString](1,'2','0',1)    -- Tipo de registro (Siempre es 2) 
		+[App].[fnAddString](1,'1','0',1)    -- Tipo de operación (Cargo = 1) 
		+[App].[fnAddString](3,'001','0',1)  -- Clave de la moneda (001 = Pesos M.N)   
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)  -- Importe a Cargar   
		+[App].[fnAddString](2,'01','0',1)   -- Tipo de cuenta (01 = Cheques) 
		+[App].[fnAddString](20,@NoCuenta,'0',1)    -- Numero de Cuenta 
		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1)    --Número total de abonos del archivo 
			 
	-- FIN HEADER 2

	-- FOOTER
	      
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
	create table #tempFooter(Respuesta nvarchar(max));    
  
	insert into #tempFooter(Respuesta)  
	select     
		 [App].[fnAddString](1,'4','0',1)    -- Tipo de Registro (Siempre es 4) 
		+[App].[fnAddString](3,'001','0',1)  -- Clave de la moneda (001 = Pesos M.N)   
		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) -- Numero de abonos
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)    -- Importe total de abonos
		+[App].[fnAddString](6,'1','0',1)     -- Numero de cargos 
		+[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)    -- Importe total de cargos
	-- FIN FOOTER

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
