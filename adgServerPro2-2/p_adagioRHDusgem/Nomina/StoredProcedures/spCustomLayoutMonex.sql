USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spCustomLayoutMonex](  
	@IDPeriodo int,  
	@FechaDispersion date,  
	@IDLayoutPago int,  
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly, 
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
	;
  
    if object_id('tempdb..#tempResp') is not null drop table #tempResp;  
	if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
  
    create table #tempResp(Respuesta nvarchar(max));  
	create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int); 

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                  
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario    
   
	IF((Select top 1 Finiquito from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo) = 0)  
	BEGIN  
		if(isnull(@MarcarPagados,0) = 1)
		BEGIN 
			insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
			SELECT e.IDEmpleado,
				   p.IDPeriodo, 
				   lp.IDLayoutPago
			FROM  @empleados e  
				INNER join Nomina.tblCatPeriodos p	
					on  p.IDPeriodo = @IDPeriodo  
				INNER JOIN RH.tblPagoEmpleado pe	
					on pe.IDEmpleado = e.IDEmpleado  
				INNER JOIN  Nomina.tblLayoutPago lp 
					on lp.IDLayoutPago = pe.IDLayoutPago  
				inner join Nomina.tblCatTiposLayout tl  
					on tl.TipoLayout = 'MONEX'  
						and lp.IDTipoLayout = tl.IDTipoLayout  
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

		insert INTO #tempResp(Respuesta)  
		select   
			 [App].[fnAddString](18,ISNULL(pe.Interbancaria,''),'0',1) 
			+','
			+cast(isnull(case when lp.ImporteTotal = 1 THEN dp.ImporteTotal1 ELSE dp.ImporteTotal2 END,0) as varchar(max))
			+','
			+'sandy.chavez@duero.com.mx'  
			+','
			--+case when len(p.Descripcion) > 40 then SUBSTRING(p.Descripcion,1,40) else ISNULL(p.Descripcion,'') end
			+SUBSTRING(case when @IDTipoNomina IN (2,3) then 'SEMANA '+RIGHT(ISNULL(p.ClavePeriodo,''),2)+' '+ e.Sucursal else 'QUINCENA '+RIGHT(ISNULL(p.ClavePeriodo,''),2)+' '+ e.Sucursal end,1,40)
			+','
			+[App].[fnAddString](7,format (@FechaDispersion,'ddMMyy'),'',2)
		FROM  @empleados e  
			INNER join Nomina.tblCatPeriodos p	on  p.IDPeriodo = @IDPeriodo  
			INNER JOIN RH.tblPagoEmpleado pe	on pe.IDEmpleado = e.IDEmpleado  
			INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago  
			inner join Nomina.tblCatTiposLayout tl	on tl.TipoLayout = 'MONEX'  
				and lp.IDTipoLayout = tl.IDTipoLayout  
			INNER JOIN Nomina.tblDetallePeriodo dp	on dp.IDPeriodo = @IDPeriodo  
				--and lp.IDConcepto = dp.IDConcepto  
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado  
		where  pe.IDLayoutPago = @IDLayoutPago  
	END  
	ELSE  
	BEGIN  
		if(isnull(@MarcarPagados,0) = 1)
		BEGIN 
			insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
			SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago
			FROM  @empleados e  
				INNER join Nomina.tblCatPeriodos p  on  p.IDPeriodo = @IDPeriodo  
				INNER JOIN RH.tblPagoEmpleado pe	on pe.IDEmpleado = e.IDEmpleado  
				INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago  
				inner join Nomina.tblCatTiposLayout tl	on tl.TipoLayout = 'MONEX'  
					and lp.IDTipoLayout = tl.IDTipoLayout  
				INNER JOIN Nomina.tblDetallePeriodo dp  on dp.IDPeriodo = @IDPeriodo  
					--and lp.IDConceptoFiniquito= dp.IDConcepto  
					and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
					and dp.IDEmpleado = e.IDEmpleado  
			where pe.IDLayoutPago = @IDLayoutPago  

			MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
			USING #tempempleadosMarcables AS SOURCE
				ON TARGET.IDPeriodo = SOURCE.IDPeriodo
					and TARGET.IDEmpleado = SOURCE.IDEmpleado
					and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)  
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);
		END

		insert INTO #tempResp(Respuesta)  
		select   
			[App].[fnAddString](18,ISNULL(pe.Interbancaria,''),'0',1) 
			+','
			+cast(isnull(case when lp.ImporteTotalFiniquito = 1 THEN dp.ImporteTotal1 ELSE dp.ImporteTotal2 END,0) as varchar(max))
			+','
			+'sandy.chavez@duero.com.mx'  
			+','
			--+case when len (p.Descripcion) > 40 then SUBSTRING(p.Descripcion,1,40) else p.Descripcion end
			+SUBSTRING(case when @IDTipoNomina IN (2,3) then 'SEMANA '+RIGHT(ISNULL(p.ClavePeriodo,''),2)+' '+ e.Sucursal else 'QUINCENA '+RIGHT(ISNULL(p.ClavePeriodo,''),2)+' '+ e.Sucursal end,1,40)
			+','
			+[App].[fnAddString](7,format (@FechaDispersion,'ddMMyy'),'',2)
		FROM  @empleados e  
			INNER join Nomina.tblCatPeriodos p on  p.IDPeriodo = @IDPeriodo  
			INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado  
			INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago  
			inner join Nomina.tblCatTiposLayout tl  on tl.TipoLayout = 'MONEX'  
				and lp.IDTipoLayout = tl.IDTipoLayout  
			INNER JOIN Nomina.tblDetallePeriodo dp  on dp.IDPeriodo = @IDPeriodo  
				--and lp.IDConceptoFiniquito= dp.IDConcepto  
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado  
		where pe.IDLayoutPago = @IDLayoutPago  
	END  
     
    select * from #tempResp  
END
GO
