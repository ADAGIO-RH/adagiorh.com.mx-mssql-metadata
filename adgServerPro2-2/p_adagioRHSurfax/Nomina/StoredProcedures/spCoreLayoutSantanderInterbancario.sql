USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spCoreLayoutSantanderInterbancario](    
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
	;

 	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros  ,@IDUsuario= @IDUsuario  

	-- CARGAR PARAMETROS EN VARIABLES

	select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Nombre Empresa'  

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No. Cuenta' 

	-- CARGAR PARAMETROS EN VARIABLES

	-- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int,IDBanco int
	   , CuentaBancaria Varchar(18)); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago,  IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,
			CASE WHEN b.Codigo ='014' and isnull(pe.Cuenta,'')<> '' THEN isnull(pe.Cuenta,'')
															WHEN b.Codigo ='014' and isnull(pe.Tarjeta,'')<> '' THEN replace(pe.Tarjeta,'_','')
															WHEN b.Codigo ='014' and isnull(pe.Interbancaria,'')<> '' THEN isnull(pe.Interbancaria,'')
															WHEN b.Codigo <>'014' and isnull(pe.Tarjeta,'')<> '' THEN replace(pe.Tarjeta,'_','')
															WHEN b.Codigo <>'014' and isnull(pe.Interbancaria,'')<> '' THEN isnull(pe.Interbancaria,'')
															ELSE isnull(pe.Interbancaria,'')
															END
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
	 -- CUERPO DE EMPLEADOS

	Declare @SumAll Decimal(16,2)  
  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then isnull(dp.ImporteTotal1,0) else isnull(dp.ImporteTotal2,0) end)  
	FROM  @empleados e    
		INNER join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl on tl.TipoLayout = 'SANTANDER INTERBANCARIO'    
			and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
		and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
		and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  

	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select     
		[App].[fnAddString](16,@NoCuenta,'',2)  
		+[App].[fnAddString](20,CASE WHEN b.Codigo ='014' and isnull(pe.Cuenta,'')<> '' THEN isnull(pe.Cuenta,'')
															WHEN b.Codigo ='014' and isnull(pe.Tarjeta,'')<> '' THEN replace(pe.Tarjeta,'_','')
															WHEN b.Codigo ='014' and isnull(pe.Interbancaria,'')<> '' THEN isnull(pe.Interbancaria,'')
															WHEN b.Codigo <>'014' and isnull(pe.Tarjeta,'')<> '' THEN replace(pe.Tarjeta,'_','')
															WHEN b.Codigo <>'014' and isnull(pe.Interbancaria,'')<> '' THEN isnull(pe.Interbancaria,'')
															ELSE isnull(pe.Interbancaria,'')
															END,'',2) --Numero de Cuenta
		+[App].[fnAddString](5,isnull(b.ClaveTransferSantander,''),'',1)
		+[App].[fnAddString](40,(COALESCE(E.Nombre,'')+' '+COALESCE(e.SegundoNombre,'')+' '+COALESCE(e.Paterno,'')) COLLATE Cyrillic_General_CI_AI,'',2) --Nombre
		+[App].[fnAddString](4,isnull('0000',''),'',1)
		+[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
		+[App].[fnAddString](5,'00000','',1) 
		+[App].[fnAddString](30,'PAGO DE NOMINA','',1) 
		+[App].[fnAddString](90,'','',1) 
	FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado
		inner join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago    

	select @CountEmpleados = count(*) from #tempBody

	-- CUERPO DE EMPLEADOS

	-- FOOTER
	
	-- FOOTER

	-- SALIDA

	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    create table #tempResp(Respuesta nvarchar(max), orden int identity(1,1));   

	insert into #tempResp(Respuesta)  
	select respuesta from #tempBody  

	select Respuesta from #tempResp order by orden asc
	 -- SALIDA
END
GO
