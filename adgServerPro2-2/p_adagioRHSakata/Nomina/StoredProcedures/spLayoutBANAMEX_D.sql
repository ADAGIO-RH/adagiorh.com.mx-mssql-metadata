USE [p_adagioRHSakata]
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
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = SUBSTRING(Descripcion,1,20) , @ClavePeriodo = ClavePeriodo                
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
		+[App].[fnAddString](20,ISNULL('NOM01',''),'',2)     
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
		+[App].[fnAddString](3,'002','0',1)
		+[App].[fnAddString](2,'01','0',1) 
		+[App].[fnAddString](3,'001','0',1) -- MONEDA MXN
/**/		+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1) 
		+[App].[fnAddString](2,'40','0',1)
		+[App].[fnAddString](20,pe.Interbancaria,'0',1) -- Tipo pago -- 01 Cheque a cuenta -- 03 Tarjeta -- 40 CLABE /*MODIFICAR*/
/**/		+[App].[fnAddString](16,REPLACE(SUBSTRING('001042589',1,7),'_',''),'',2)
		+[App].[fnAddString](55,(isnull(E.Nombre,'')+isnull(e.SegundoNombre,'')+','+isnull(e.Paterno,'')+'/'+isnull(e.Materno,'')) COLLATE Cyrillic_General_CI_AI,'',2)   
		+[App].[fnAddString](35,'NOMINA','',2) 
		+[App].[fnAddString](35,'NOMINA1','',2) 
		+[App].[fnAddString](35,'NOMINA1','',2) 
		+[App].[fnAddString](35,'NOMINA1','',2) 
		+[App].[fnAddString](4,pe.IDBancario,'0',2)
		+[App].[fnAddString](2,'00','0',1)
		+[App].[fnAddString](152,'','',2)
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
	-- CUERPO DE EMPLEADOS
	-- HEADER 2
	
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
	
	if object_id('tempdb..#tempHeader2') is not null drop table #tempHeader2;    
	create table #tempHeader2(Respuesta nvarchar(max)); 

	insert into #tempHeader2(Respuesta)   
	select     
		[App].[fnAddString](1,'2','0',1)     
		+[App].[fnAddString](1,'1','0',1)     
		+[App].[fnAddString](3,'001','0',1)     
/**/		+[App].[fnAddString](18, replace(cast(isnull(@SumAll,0) as varchar(max)),'.','') ,'0',1)   
		+[App].[fnAddString](2,'01','0',1)   
		+[App].[fnAddString](20,@NoCuenta,'0',1)     
/**/		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1)     
			 
	-- HEADER 2

	-- FOOTER
	      
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
	create table #tempFooter(Respuesta nvarchar(max));    
  
	insert into #tempFooter(Respuesta)  
	select     
		[App].[fnAddString](1,'4','0',1)     
		+[App].[fnAddString](3,'001','0',1)     
/**/		+[App].[fnAddString](6,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) 
/**/		+[App].[fnAddString](18, replace(cast(isnull(@SumAll,0) as varchar(max)),'.','') ,'0',1)    
		+[App].[fnAddString](6,'1','0',1)     
/**/		+[App].[fnAddString](18, replace(cast(isnull(@SumAll,0) as varchar(max)),'.','') ,'0',1)    
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
