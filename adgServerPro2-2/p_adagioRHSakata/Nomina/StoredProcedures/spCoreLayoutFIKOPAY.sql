USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE @dt [Nomina].[dtFiltrosRH]

	EXEC [Nomina].[spCoreLayoutFIKOPAY]628,'2018-12-27',13,@dt,0,1    
*/

CREATE  PROCEDURE [Nomina].[spCoreLayoutFIKOPAY]--2,'2018-12-27',13,null,0,1    
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
		,@CuentaOrigen Varchar(max) --Razon Social
		,@Concepto Varchar(max) --Cliente
	

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
	  
	select  @CuentaOrigen = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock)  
		on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock)  
		on ctlp.IDTipoLayout = lp.IDTipoLayout  
		and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Cuenta Origen'  

	select @Concepto = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock)  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock)  
		on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock)  
		on ctlp.IDTipoLayout = lp.IDTipoLayout  
		and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Concepto'  



	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int, IDBanco int, CuentaBancaria Varchar(18));
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago,   IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,CAST(Coalesce(pe.Interbancaria,pe.Tarjeta) as varchar(max))
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p with (nolock)    
				on p.IDPeriodo = @IDPeriodo   
			INNER JOIN RH.tblPagoEmpleado pe with (nolock)    
				on pe.IDEmpleado = e.IDEmpleado
			left join Sat.tblCatBancos b with (nolock)  
				on pe.IDBanco = b.IDBanco    
			INNER JOIN  Nomina.tblLayoutPago lp with (nolock)    
				on lp.IDLayoutPago = pe.IDLayoutPago    
			inner join Nomina.tblCatTiposLayout tl with (nolock)    
				--on tl.TipoLayout = 'SCOTIABANK'    
				on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp with (nolock)    
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


	 -- CUERPO
	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
    
	create table #tempBody(
	[Cuenta origen (CLABE/Tarjeta/Teléfono)] Varchar(MAX)
	,[Cuenta destino CLABE/Tarjeta/Teléfono] Varchar(MAX)
	,[Tipo] Varchar(MAX)
	,[Nombre] Varchar(MAX)
	,[Entidad] Varchar(MAX)
	,[Concepto] Varchar(MAX)
	,[Referencia númerica] Varchar(MAX)
	,[Importe Sin IVA] Varchar(MAX)
	,[IVA ] Varchar(MAX)
	); 

	insert into #tempBody(
		[Cuenta origen (CLABE/Tarjeta/Teléfono)] 
		,[Cuenta destino CLABE/Tarjeta/Teléfono]
		,[Tipo] 
		,[Nombre] 
		,[Entidad] 
		,[Concepto] 
		,[Referencia númerica] 
		,[Importe Sin IVA] 
		,[IVA ] 
	)   
	select
	   @CuentaOrigen
	   ,CAST(Coalesce(pe.Interbancaria,pe.Tarjeta) as varchar(max))
	   ,Coalesce(Case when pe.Interbancaria is not null then 'CLABE' end,Case when pe.Tarjeta is not null then 'TARJETA' end)
	   ,REPLACE(RTRIM(LTRIM(COALESCE(e.Nombre,'')+ CASE WHEN ISNULL(e.SegundoNombre,'') <> '' THEN ' '+COALESCE(e.SegundoNombre,'') ELSE '' END +' '+COALESCE(e.Paterno,'')+' '+COALESCE(e.Materno,''))),'  ',' ')
	   ,ISNULL(b.Descripcion,'SIN BANCO')
	   ,@Concepto
	   ,''
	   ,CAST(ISNULL(dp.ImporteTotal1,'0') as varchar(max))
	   ,''
	 FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p with (nolock)    
			on p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe with (nolock)    
			on pe.IDEmpleado = e.IDEmpleado
		left join Sat.tblCatBancos b with (nolock)  
			on pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp with (nolock)    
			on lp.IDLayoutPago = pe.IDLayoutPago    
		inner join Nomina.tblCatTiposLayout tl with (nolock)    
		--on tl.TipoLayout = 'SCOTIABANK'    
			on lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp with (nolock)    
			on dp.IDPeriodo = @IDPeriodo    
				--and lp.IDConcepto = dp.IDConcepto    
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago  
	
	
	select * from #tempBody 
	
END
GO
