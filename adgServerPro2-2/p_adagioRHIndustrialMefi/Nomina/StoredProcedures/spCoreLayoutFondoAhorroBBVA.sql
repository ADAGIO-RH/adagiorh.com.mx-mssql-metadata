USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spCoreLayoutFondoAhorroBBVA](    
	@IDPeriodo int,    
	@FechaDispersion date,    
	@IDLayoutPago int,
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@MarcarPagados bit = 0,     
	@IDUsuario int  
)    
AS    
BEGIN    
	declare     
		@empleados [RH].[dtEmpleados]      
		,@ListaEmpleados Nvarchar(max)    
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date
		,@IDTipoNomina int 

		--PARAMETROS  
		,@TipoDeServicio	  varchar(max)
		,@ConsecutivoDelDia	  varchar(max)
		,@Contrato  		  varchar(max)

		,@ConceptoAportacionEmpresa		varchar(10) = '308'
		,@ConceptoAportacionTrabajador	varchar(10) = '309'

		,@dtFiltros2 [Nomina].[dtFiltrosRH]
	;

	insert @dtFiltros2
	select * from @dtFiltros

	-- Cuando se genera un Layout no fondo de ahorro no toma en cuenta la lista de empleados que tenga el @dtFiltros
	if exists (select top 1 1
				from Nomina.tblLayoutPago lp with (nolock) 
					inner join Nomina.tblCatTiposLayout ctp with (nolock) on lp.IDTipoLayout = ctp.IDTipoLayout
				where lp.IDLayoutPago = @IDLayoutPago and ctp.TipoLayout like '%FONDO AHORRO%'
	)
	begin
		delete @dtFiltros2
	end

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                  
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros2,@IDUsuario = @IDUsuario    

	delete e
	from @empleados e
		left join (
			select DP.*
			from Nomina.tblDetallePeriodo DP
				Inner join @periodo P on DP.IDPeriodo = P.IDPeriodo
				Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
			where c.Codigo = @ConceptoAportacionEmpresa and DP.ImporteTotal1 > 0.00
		) ddd on ddd.IDEmpleado = e.IDEmpleado
	where ddd.IDDetallePeriodo is null

	update e 
		set e.[RowNumber] = ee.[Row]
	from @empleados e
		join (
			select IDEmpleado,[Row] = ROW_NUMBER()over(order by paterno, materno, nombre asc)
			from @empleados
		) ee on e.IDEmpleado = ee.IDEmpleado

	--select [RowNumber],IDEmpleado, NombreCompleto from @empleados order by RowNumber
	IF object_ID('TEMPDB..#TempTotalEmpresa') IS NOT NULL DROP TABLE #TempTotalEmpresa
	IF object_ID('TEMPDB..#TempTotalEmpleado') IS NOT NULL DROP TABLE #TempTotalEmpleado
	IF object_ID('TEMPDB..#TempTotalDeApartaciones') IS NOT NULL DROP TABLE #TempTotalDeApartaciones

	Select DP.IDEmpleado as IDEmpleado,  
		ISNULL(DP.ImporteTotal1,0) as  ImporteTotal1  
	INTO #TempTotalEmpresa
	from Nomina.tblDetallePeriodo DP with (nolock)  
		Inner join @empleados e on DP.IDEmpleado = e.IDEmpleado
		Inner join @periodo P on DP.IDPeriodo = P.IDPeriodo-- AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
	where c.Codigo = @ConceptoAportacionEmpresa
	--group by dp.IDEmpleado

	Select DP.IDEmpleado as IDEmpleado,  
		ISNULL(DP.ImporteTotal1,0) as  ImporteTotal1  
	INTO #TempTotalEmpleado
	from Nomina.tblDetallePeriodo DP with (nolock)  
		Inner join @empleados e on DP.IDEmpleado = e.IDEmpleado
		Inner join @periodo P on DP.IDPeriodo = P.IDPeriodo-- AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
	where c.Codigo = @ConceptoAportacionTrabajador
	--group by dp.IDEmpleado

	Select empleado.IDEmpleado as IDEmpleado,  
		ISNULL(empleado.ImporteTotal1,0) as  TotalEmpleado,  
		ISNULL(empresa.ImporteTotal1,0) as  TotalEmpresa,
		ISNULL(empleado.ImporteTotal1,0)+ISNULL(empresa.ImporteTotal1,0) as TotalGeneral
	INTO #TempTotalDeApartaciones
	from #TempTotalEmpleado empleado
		join #TempTotalEmpresa empresa on empleado.IDEmpleado = empresa.IDEmpleado

	--select * from #TempTotalDeApartaciones

	select  @TipoDeServicio = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock) 
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  and ctlp.Parametro = 'Tipo de servicio'  
  
	select  @ConsecutivoDelDia = lpp.Valor  
	from Nomina.tblLayoutPago lp with (nolock) 
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock)  on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Consecutivo del dia'  
  
	select  @Contrato = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp with (nolock) on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp with (nolock) on ctlp.IDTipoLayout = lp.IDTipoLayout  
			and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Contrato'  
     
    if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
    create table #tempHeader1(Respuesta nvarchar(max),ID int);    
  
	insert into #tempHeader1(Respuesta,ID)   
	select     
	   [App].[fnAddString](2,'01','0',1)											--TIPO DE REGISTRO    
	  +[App].[fnAddString](2,@TipoDeServicio,'0',1)									--IDENTIFICADOR DE SERVICIO    
	  +[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2)	--FECHA DE ENVIO DE INFORMACIÓN  
	  +[App].[fnAddString](3,@ConsecutivoDelDia,'0',1)								--CONSECUTIVO DEL DIA
	  +[App].[fnAddString](7,@Contrato,'0',1)										--CONTRATO
	  +[App].[fnAddString](6,'000000','0',1)										--SUBCONTRATO
	  +[App].[fnAddString](302,'',' ',1)											--FILLER    
	  ,0
    
     
	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
	create table #tempResp(Respuesta nvarchar(max), ID int);    
     
	if object_id('tempdb..#tempempleados') is not null drop table #tempempleados;    
	create table #tempempleados(Respuesta varchar(max), ID int);  

	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
		insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p with (nolock)  on p.IDPeriodo = @IDPeriodo      
			INNER JOIN  Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = @IDLayoutPago    
			INNER JOIN Nomina.tblCatTiposLayout tl with (nolock) on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp with (nolock) on dp.IDPeriodo = @IDPeriodo    
				and lp.IDConcepto = dp.IDConcepto    
				and dp.IDEmpleado = e.IDEmpleado    

		MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
		USING #tempempleadosMarcables AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);

	END
	
	insert into #tempempleados(Respuesta,ID)  
	select     
		 [App].[fnAddString](2,'02','0',1)   -- TIPO DE REGISTRO  
		+[App].[fnAddString](2,@TipoDeServicio,'0',1) -- IDENTIFICADOR DE SERVICIO    
		+[App].[fnAddString](9,cast(e.RowNumber as varchar(5)),'0',1)  -- CONSECUTIVO DE DETALLE   
		+[App].[fnAddString](20,e.ClaveEmpleado,'',2)    
		+[App].[fnAddString](40,isnull(ltrim(Rtrim(e.Paterno)),''),' ',2)    
		+[App].[fnAddString](40,isnull(ltrim(Rtrim(e.Materno)),''),' ',2)    
		+[App].[fnAddString](40,isnull(ltrim(Rtrim(e.Nombre)) ,'')+ case when isnull(e.SegundoNombre,'') != '' then ' '+isnull(ltrim(Rtrim(e.Nombre)) ,'') else '' end,' ',2)    
		+[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2)    
		+[App].[fnAddString](15,replace(cast(isnull(a.TotalEmpleado, 0) as varchar(max)),'.',''),'0',1)      
		+[App].[fnAddString](15,replace(cast(isnull(a.TotalEmpresa, 0) as varchar(max)),'.',''),'0',1)      
		+[App].[fnAddString](120,'0','0',2)    
		+[App].[fnAddString](1,'',' ',2)   
		+[App].[fnAddString](14,'0','0',2)    
		+[App].[fnAddString](3,' ','',2)   
		,e.RowNumber
	FROM  @empleados e     
		INNER join #TempTotalDeApartaciones a on e.IDEmpleado = a.IDEmpleado   
     
    if object_id('tempdb..#tempFooter1') is not null drop table #tempFooter1;    
    if object_id('tempdb..#tempTotalesFooter') is not null drop table #tempTotalesFooter;    
    
    create table #tempFooter1(Respuesta nvarchar(max), ID int);    
  
	select SUM(TotalEmpleado) GrandTotalEmpleado
		,SUM(TotalEmpresa) GrandTotalEmpresa
		,SUM(TotalGeneral) as GrandTotal
		,count(*) as TotalRegistros
	INTO #tempTotalesFooter
	from #TempTotalDeApartaciones

	insert into #tempFooter1(Respuesta,ID)  
	select    
		 [App].[fnAddString](2,'09','0',1)     
		+[App].[fnAddString](2,@TipoDeServicio,'0',1) -- IDENTIFICADOR DE SERVICIO    
		+[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2) 
		+[App].[fnAddString](3,@ConsecutivoDelDia,'0',1) --CONSECUTIVO DEL DIA
		+[App].[fnAddString](8,cast(TotalRegistros as varchar(8)),'0',1)  -- CONSECUTIVO DE DETALLE   
		+[App].[fnAddString](15,replace(cast(isnull(GrandTotalEmpleado, 0) as varchar(max)),'.',''),'0',1)      
		+[App].[fnAddString](15,replace(cast(isnull(GrandTotalEmpresa, 0) as varchar(max)),'.',''),'0',1) 
		+[App].[fnAddString](120,'0','0',2)    
		+[App].[fnAddString](15,replace(cast(isnull(GrandTotal, 0) as varchar(max)),'.',''),'0',1) 
		+[App].[fnAddString](142,'',' ',1)     
		,(select max(ID)+1 from #tempEmpleados)
	from #tempTotalesFooter
  
	insert into #tempResp(Respuesta,ID)  
	select respuesta,ID from #tempHeader1  
	union all  
	select respuesta,ID from #tempempleados  
	union all  
	select respuesta,ID from #tempFooter1  

	select Respuesta from #tempResp order by ID asc
    
END
GO
