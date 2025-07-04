USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCoreLayoutKUSPIT]
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
		,@ClaveProgramaDispersion Varchar(max) --Razon Social
		,@NombrePrograma Varchar(max) --Cuenta Cargo
		,@ClaveClienteFondeoenUnalanaPAY Varchar(max) --Consecutivo
		,@ClienteNombre Varchar(max) --Tipo Cuenta
		,@Concepto Varchar(max) --Cliente
	;

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
	  
	select  @ClaveProgramaDispersion = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Clave Programa Dispersion'  

	select @NombrePrograma = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Nombre Programa'  

	select @ClaveClienteFondeoenUnalanaPAY = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Clave Cliente Fondeo en UnalanaPAY'  

	select @ClienteNombre = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Cliente Nombre'  

	select @Concepto = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Concepto'  
	-- CARGAR PARAMETROS EN VARIABLES

	-- MARCAR EMPLEADOS COMO PAGADOS
	
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int  ,IDBanco int
	   , CuentaBancaria Varchar(18)); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago, IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago,b.IDBanco
		,case when pe.IDBanco = tl.IDBanco then 
			case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') 
			ELSE isnull(replace( pe.Tarjeta,' ',''),'') 
			END 
			else isnull(replace( pe.Interbancaria,' ',''),'') 
		end
		FROM @empleados e     
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

	-- ENCABEZADO 2
	Declare @SumAll Decimal(18,2)  
  
	select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
	FROM @empleados e    
		INNER join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe with (nolock) on pe.IDEmpleado = e.IDEmpleado  
		left join Sat.tblCatBancos b with (nolock) on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl with (nolock) on tl.TipoLayout = 'KUSPIT'    
			and lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp with (nolock) on dp.IDPeriodo = @IDPeriodo    
			and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  

	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(rn int,Respuesta varchar(max)); 

	insert into #tempHeader1(rn,Respuesta)   
	select 1,    
		'Clave Programa Dispersion' + ','
	   +'Nombre Programa' + ','
	   +REPLACE('Fecha Elab ("AAAA-MM-DD)','"','''') + ','
	   +replace('Fecha Pago ("AAAA-MM-DD)','"','''') + ','
	   +'Clave Cliente Fondeo en UnalanaPAY' + ','
	   +'Cliente Nombre (Fondeo)' + ','
	   +'Ingreso Importe (Pesos)' + ','
	   +'Clave Beneficiario en UnalanaPAY (Usar "sin definir" para nuevos)' + ','
	   +'Nombre del Beneficiario' + ','
	   +'Clave Banco (Ver "Directorio de Bancos")' + ','
	   +'Clabe (TDD o Celular) (usar " antes de la clabe)' + ','
	   +'tipo cuenta' + ','
	   +'importe' + ','
	   +'Correo Beneficiario' + ','
	   +'Referencia' + ','
	   +'Concepto' + ','
	   +'Grupo' + ','
	   +'Id Referencia Cliente' + ','
	   +'RFC/CURP' + ','
	   +'Celular' 

	insert into #tempHeader1(rn,Respuesta)   
	select 2,    
		ISNULL(@ClaveProgramaDispersion,'') + ','
	   +ISNULL(@NombrePrograma,'') + ','
	   +''''+ISNULL(FORMAT(GETDATE(),'yyyy-MM-dd'),'') + ','
	   +''''+ISNULL(FORMAT(@FechaDispersion,'yyyy-MM-dd'),'') + ','
	   +ISNULL(@ClaveClienteFondeoenUnalanaPAY,'') + ','
	   +ISNULL(@ClienteNombre,'') + ','
	   +ISNULL(CAST(isnull(@SumAll,0.00) as varchar(max)),'0.00') + ','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	 
	 -- ENCABEZADO

	 -- CUERPO
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(RN INT IDENTITY(1,1),Respuesta nvarchar(max)); 

	insert into #tempBody(Respuesta)   
	select
		ISNULL(@ClaveProgramaDispersion,'') + ','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +','
	   +'SIN DEFINIR' + ','
	   + REPLACE(RTRIM(LTRIM(COALESCE(e.Nombre,'')+ CASE WHEN ISNULL(e.SegundoNombre,'') <> '' THEN ' '+COALESCE(e.SegundoNombre,'') ELSE '' END +' '+COALESCE(e.Paterno,'')+' '+COALESCE(e.Materno,''))),'  ',' ') + ','
	   + ISNULL(b.ClaveTransferKUSPIT,'') + ','
	   +''''+	+[App].[fnAddString](18,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN isnull(replace( pe.Cuenta,' ',''),'') ELSE isnull(replace( pe.Tarjeta,' ',''),'') END else isnull(replace( pe.Interbancaria,' ',''),'') end,'0'),'0',1) + ','
	   +isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN 'Cuenta' ELSE 'Tarjeta' END else 'clabe' end,'clabe') + ','
	   +cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)) + ','
	   +'' + ','
	   +'' + ','
	   +ISNULL(@Concepto,'OTRO') + ','
	   +','
	   +','
	   +','	
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
	
	 -- CUERPO
	create table #tempResp(RN int identity(1,1),Respuesta nvarchar(max));   

	insert into #tempResp(Respuesta)  
	select respuesta from #tempHeader1  ORDER BY rn ASC
	
	insert into #tempResp(Respuesta)  
	select  respuesta from #tempBody    ORDER BY rn ASC
	
	select  respuesta from #tempResp ORDER BY rn ASC
	-- SALIDA
END
GO
