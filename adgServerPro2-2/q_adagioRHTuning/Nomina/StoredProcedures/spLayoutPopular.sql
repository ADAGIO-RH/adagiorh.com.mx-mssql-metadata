USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spLayoutPopular]--2,'2018-12-27',8,0    
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
		,@RNC Varchar(15)
        ,@NombreCompania Varchar(35)
		,@SecArchivo Varchar(7)
        ,@TipoServicio Varchar(2) ----Por default lo dejaremos como 01 Nomina Automatica
		,@TipoCuenta Varchar(2)
        ,@MonedaDestino Varchar(3)
        ,@CodigoBancoDestino varchar(8)
        ,@DigitoVerificadorBancoDestino varchar(1)
        ,@CodigoOperacion varchar(2)
        ,@NumeroReferencia varchar(12)

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
 
	select  @RNC = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'RNC'  
    
    
    select  @NombreCompania = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Nombre Compañia'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Secuencia Archivo'

    select @TipoServicio= lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Tipo de Servicio' 


	select  @MonedaDestino = lpp.Valor  
	from Nomina.tblLayoutPago lp  
	inner join Nomina.tblLayoutPagoParametros lpp  
		on lp.IDLayoutPago = lpp.IDLayoutPago  
	inner join Nomina.tblCatTiposLayoutParametros ctlp  
		on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  and ctlp.Parametro = 'Moneda Destino'  

	select @TipoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Tipo Cuenta Destino' 


    select @CodigoBancoDestino = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Codigo Banco Destino' 

    select @DigitoVerificadorBancoDestino= lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Digito Verificador Banco Destino' 

    select @CodigoOperacion= lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Codigo de operacion' 


    select @NumeroReferencia= lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Numero de referencia' 



	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null    
    drop table #tempempleadosMarcables;    
    
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
			on tl.TipoLayout = 'POPULAR'    
				and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  

	-- select @CountEmpleados = count(*) from @empleados e

select @CountEmpleados=count(*)
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
			on tl.TipoLayout = 'POPULAR'    
				and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  


	 -- HEADER 1
	  if object_id('tempdb..#tempHeader1') is not null    
			drop table #tempHeader1;    
    
			create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select  
		[App].[fnAddString](1,'H','',1) --Tipo Registro
		+[App].[fnAddString](15,@RNC,' ',2) -- ID Compañia (RNC)
		+[App].[fnAddString](35,@NombreCompania,' ',2) --Nombre Compañia
		+[App].[fnAddString](7,@SecArchivo,'0',1) --Consecutivo de archivo
        +[App].[fnAddString](2,ISNULL(@TipoServicio,'01'),'',2) --Tipo de servicio
        +[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2) --Fecha de Dispersión
		+[App].[fnAddString](24,'','0',2) --Filler Cantidad Debitos y monto total debito (no aplican)
		+[App].[fnAddString](11,ISNULL(@CountEmpleados,'????'),'0',1) --Cantidad Creditos
		+[App].[fnAddString](13, ISNULL(replace(cast(@SumAll as varchar(max)),'.',''),'???') ,'0',1) --Monto Total Creditos
		+[App].[fnAddString](15,'0','0',1) --Filler Numero de MID O Afiliacion
		+[App].[fnAddString](8,isnull(format(GETDATE(),'yyyyMMdd'),''),'',2) --Fecha de Envío
        +[App].[fnAddString](4,isnull(format(GETDATE(),'HHmm'),''),'',2) --Hora Envio
        +[App].[fnAddString](40,'',' ',2)--Email (dejar en blanco)
        +[App].[fnAddString](1,'',' ',2) --Estatus Dejar en blanco
        +[App].[fnAddString](136,'',' ',2)--Filler

	 -- HEADER 1

	 -- CUERPO DE EMPLEADOS
	if object_id('tempdb..#tempBody') is not null 
    drop table #tempBody;    
	
    create table #tempBody(Respuesta nvarchar(max),orden int identity(1,1));     

	insert into #tempBody(Respuesta)   
	select     
		[App].[fnAddString](1,'N','',1) --Tipo de registro (siempre lleva una N)
		+[App].[fnAddString](15,@RNC,' ',2) -- ID Compañia (RNC)
		+[App].[fnAddString](7,@SecArchivo,'0',1) --Consecutivo de archivo
        +[App].[fnAddString](7,ROW_NUMBER() OVER(ORDER BY e.idempleado asc),'0',1) --Secuencia de transaccion
        --+[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT 0))+1,'0',1) --Contador (Num de fila) 
        +[App].[fnAddString](20,ISNULL(pe.Cuenta,'?'),' ',2) --Secuencia de transaccion
        +[App].[fnAddString](1,ISNULL(@TipoCuenta,'2'),'',2) --Tipo de cuenta destino default cuenta de ahorros
        +[App].[fnAddString](3,ISNULL(@MonedaDestino,'214'),'',2) --Moneda Destino Default pesos dominicanos
        +[App].[fnAddString](8,ISNULL(@CodigoBancoDestino,'10101070'),'',2) --Codigo Banco Destino
        +[App].[fnAddString](1,ISNULL(@DigitoVerificadorBancoDestino,'8'),'',2) --Digito Verificador Banco Destino 8
        +[App].[fnAddString](2,ISNULL(@CodigoOperacion,'32'),'',2) --Codigo de operación
        +[App].[fnAddString](13,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Monto transaccion
        +[App].[fnAddString](2,'CE','',2) --Tipo de identificacion CEDULA
        +[App].[fnAddString](15,e.RFC,' ',2) --Tipo de identificacion CEDULA
        +[App].[fnAddString](35,concat(isnull(e.Nombre,''),' ',ISNULL(e.Paterno,''),(CASE WHEN ISNULL(e.Materno,'') <> '' THEN ' '+ISNULL(e.Materno,'') ELSE '' END)),' ',2) --NOMBRE BENEFICIARIO 
        +[App].[fnAddString](12,ISNULL(@NumeroReferencia,'2022-62'),' ',2) --Numero de referencia
        +[App].[fnAddString](40,CONCAT('Salario ',p.Descripcion),' ',2) --Descripcion pago
        +[App].[fnAddString](4,'',' ',2) --Fecha de vencimiento (NO APLICA)
        +[App].[fnAddString](1,'',' ',2) --Forma de contacto (NO APLICA)
        +[App].[fnAddString](40,'',' ',2) --EMAIL BENEFICIARIO (NO APLICA)
        +[App].[fnAddString](12,'','0',2) --FAX DEL BENEFICIARIO
        +[App].[fnAddString](2,'','0',2) --PROCESO DE PAGO
        +[App].[fnAddString](15,'',' ',2) --Numero de autorizacion (dejar en blanco)
        +[App].[fnAddString](3,'',' ',2) --Codigo Retorno Remoto (dejar en blanco)
        +[App].[fnAddString](3,'',' ',2) --Codigo Razon Remoto Remoto (dejar en blanco)
        +[App].[fnAddString](3,'',' ',2) --Codigo Razon Interno (dejar en blanco)
        +[App].[fnAddString](1,'',' ',2) --Procesador Transaccion (dejar en blanco)
        +[App].[fnAddString](2,'',' ',2) --Estatus Transaccion
        +[App].[fnAddString](52,'',' ',2) --Filler
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
			on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago    
	order by e.IDEmpleado asc
	
---- CUERPO DE EMPLEADOS

	 -- SALIDA



    if object_id('tempdb..#tempResp') is not null    
		drop table #tempResp;    
    
    create table #tempResp(Respuesta nvarchar(max), orden int identity(1,1));   

	 insert into #tempResp(Respuesta)  
	 select respuesta from #tempHeader1  
	 

     insert into #tempResp(Respuesta)  
	 select respuesta 
     from #tempBody  
     order by orden asc
	  


	 select Respuesta from #tempResp order by orden asc


	-- if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
		
	-- create table #tempResp(Respuesta nvarchar(max)); 
	 
	-- insert into #tempResp(Respuesta)  
	-- select respuesta from #tempHeader1 
	-- UNION ALL 
	-- select respuesta from #tempBody

	-- select * from #tempResp

	 -- SALIDA
END
GO
