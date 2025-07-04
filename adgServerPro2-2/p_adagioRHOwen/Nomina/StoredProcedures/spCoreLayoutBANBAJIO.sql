USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spCoreLayoutBANBAJIO](    
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
		,@TotalPagado int
		--,@NombreArchivo Nvarchar(max)  

		-- PARAMETROS
		,@GrupoAfinidad Varchar(12)
		,@SecArchivo Varchar(4)
		,@NoCuenta Varchar(20)
		-- PARAMETROS
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
	select  @GrupoAfinidad = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Grupo Afinidad'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Secuencia Archivo'  

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cuenta' 
	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int, IDBanco int, CuentaBancaria Varchar(18)); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago, IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,pe.Cuenta
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

	-- HEADER 
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(Respuesta nvarchar(max)); 

	insert into #tempHeader1(Respuesta)   
	select  
		[App].[fnAddString](2,'01','0',1)           --IMP (COL (1)  , '01'); //TIPO DE REGISTRO
	   +[App].[fnAddString](7,@SecArchivo,'0',2)    --IMP (COL (3)  , DER (_secuencia,7)); //NUMERO DE SECUENCIA
	   +[App].[fnAddString](3,'030','0',1)          --IMP (COL (10) , '030'); //BANCO RECEPTOR
	   +[App].[fnAddString](1,'S','0',1)            --IMP (COL (13) , 'S'); //SENTIDO
	   +[App].[fnAddString](2,'90','0',1)           --IMP (COL (14) , '90'); //CODIGO - DE NOMINA
	   +[App].[fnAddString](1,'','0',1)             --IMP (COL (16) , '0'); //FILLER
	   +[App].[fnAddString](7,@GrupoAfinidad,'0',2) --IMP (COL (17) , DER (_gpo_afinidad,7)); //GRUPO DE AFINIDAD ASIGNADO POR BANCO DEL BAJIO A LA EMPRESA
	   +[App].[fnAddString](8,isnull(convert(varchar, getdate(), 112),''),'0',1) --IMP (COL (24) , FECHA (_fechag)); //FECHA DE GENERACION
	   +[App].[fnAddString](20,@NoCuenta,'0',1)     --IMP (COL (32) , DER (_NumCuenta,20)); //NUMERO DE CUENTA DE LA EMPRESA
	   +[App].[fnAddString](131,' ',' ',1)          --IMP (COL (181), ' '); //FILLER
	 -- HEADER 
	 
	-- CUERPO DE EMPLEADOS
	Declare @SumAll Decimal(16,2)  
		
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
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

	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select     
		 [App].[fnAddString](2,'02','0',1)                                        -- IMP (COL (1) , '02');						//TIPO DE REGISTRO
		+[App].[fnAddString](7,@SecArchivo,'0',2)                                 -- IMP (COL (3) , DER (_secuencia,7));				//NUMERO DE SECUENCIA
		+[App].[fnAddString](2,'90','0',1)                                        -- IMP (COL (10), '90');						//CODIGO DE OPERACION
		+[App].[fnAddString](8,isnull(convert(varchar, @FechaDispersion, 112),''),'0',1) -- IMP (COL (12), FECHA (_fechad));				//FECHA DE PRESENTACION
		+[App].[fnAddString](3,'000','0',1)                                       -- IMP (COL (20), '000');						//FILLER - CEROS
		+[App].[fnAddString](3,'030','0',1)                                       -- IMP (COL (23), '030');						//BANCO
		+[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 
								then dp.ImporteTotal1 
								else dp.ImporteTotal2 end,0) 
								as varchar(max)),'.',''),'0',1)                   -- IMP (COL (26), DER (PESOS(TOTAL('CHEQ')),15));		//IMPORTE A DEPOSITAR
		+[App].[fnAddString](8,isnull(convert(varchar, @FechaDispersion, 112),''),'0',1) -- IMP (COL (41), FECHA (_fechad));				//FECHA DE APLICACION
		+[App].[fnAddString](2,'00','0',1)                                        -- IMP (COL (49), '00');						//FILLER - CEROS
		+[App].[fnAddString](20,@NoCuenta,'0',1)                                  -- IMP (COL (51), DER (_NumCuenta,20));				//NUMERO DE CUENTA DE LA EMPRESA
		+[App].[fnAddString](1,'',' ',1)                                          -- IMP (COL (71), ' ');						//FILLER - ESPACIO
		+[App].[fnAddString](2,'00','0',1)                                        -- IMP (COL (72), '00');						//FILLER - CEROS
		+[App].[fnAddString](20,pe.Cuenta,'0',1)                                  -- IMP (COL (74), DER (TRAB_CUENTA,20));				//NUMERO DE CUENTA DEL EMPLEADO
		+[App].[fnAddString](1,'',' ',1)                                          -- IMP (COL (94), ' ');						//FILLER - ESPACIO
		+[App].[fnAddString](7,e.ClaveEmpleado,'0',1)                             -- IMP (COL (95), DER (TRAB_CLAVE,7));				//NUMERO DE NOMINA DEL EMPLEADO
		+[App].[fnAddString](40,'DEPOSITO DE NOMINA',' ',2)                       -- IMP (COL (102), 'DEPOSITO DE NOMINA');				//LEYENDA
		+[App].[fnAddString](30,pe.Tarjeta,'0',2)                                 -- IMP (COL (142), DER (TRAB_EXTRA3,30));				//NUMERO DE TARJETA
		+[App].[fnAddString](10,'0000000000','0',1)                               -- IMP (COL (172), '0000000000');					//FILLER - CEROS
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
	
	-- FOOTER    
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
	create table #tempFooter(Respuesta nvarchar(max));    
  
	insert into #tempFooter(Respuesta)  
	select     
		 [App].[fnAddString](2,'09','0',1)             --IMP (COL (1)  , '09'); //TIPO DE REGISTRO - INICIO DE ENCABEZADO    
		+[App].[fnAddString](7,@SecArchivo,'0',1)      --IMP (COL (3)  , DER (_secuencia,7)); //NUMERO DE SECUENCIA
		+[App].[fnAddString](2,'90','0',1)             --IMP (COL (10) , '90'); //CODIGO - DE NOMINA
		+[App].[fnAddString](7,@CountEmpleados,'0',1)  --IMP (COL (12) , DER (_no_operaciones,7)); //NUMERO DE OPERACIONES
		+[App].[fnAddString](18,replace(cast(isnull(@SumAll,0)   as varchar(max)),'.',''),'0',1)    -- IMP (COL (19) , DER(PESOS (_totalPago), 18))			//IMPORTE TOTAL
		+[App].[fnAddString](146,'',' ',1)             --IMP (COL (181), ' '); //FILLER
	-- FOOTER

	--NOMBRE ARCHIVO
	-- SELECT @NombreArchivo = concat('D',@GrupoAfinidad,@SecArchivo,Format((MONTH(@FechaDispersion)*.10),'0.#'),DAY(@FechaDispersion),'.txt');
	--NOMBRE ARCHIVO

	-- SALIDA

	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    create table #tempResp(Respuesta nvarchar(max));   

	insert into #tempResp(Respuesta)  
	select respuesta from #tempHeader1  
	union all    
	select respuesta from #tempBody  
	union all  
	select respuesta from #tempFooter

	select * from #tempResp
	
	-- SALIDA

END
GO
