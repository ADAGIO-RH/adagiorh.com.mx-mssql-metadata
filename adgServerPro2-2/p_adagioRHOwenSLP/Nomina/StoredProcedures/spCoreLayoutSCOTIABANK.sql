USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spCoreLayoutSCOTIABANK](    
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

        --PARAMETROS  
        ,@NoCliente varchar(5)  
        ,@NoArchivoDia varchar(2)  
        ,@CuentaCargo varchar(16)  
        ,@ReferenciaEmpresa varchar(11)  
        ,@FormaPago varchar(2)  
        ,@ConceptoPago varchar(2)  
        ,@ConceptoPagoDescripcion varchar(40)  
        ,@ReferenciaPago int  
    ;

    if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
    if object_id('tempdb..#tempHeader2') is not null drop table #tempHeader2;    
    if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
    if object_id('tempdb..#tempempleados') is not null drop table #tempempleados;    
    if object_id('tempdb..#tempempleadosMarcables') is not null drop table #tempempleadosMarcables;    
    if object_id('tempdb..#tempFooter1') is not null drop table #tempFooter1;    
    if object_id('tempdb..#tempFooter2') is not null drop table #tempFooter2;    
    
    create table #tempHeader1(Respuesta nvarchar(max));    
    create table #tempHeader2(Respuesta nvarchar(max));    
    create table #tempResp(Respuesta nvarchar(max));     
    create table #tempempleados(Respuesta nvarchar(max)); 
    create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int,IDBanco int
	   , CuentaBancaria Varchar(18)); 
    create table #tempFooter1(Respuesta nvarchar(max));    
    create table #tempFooter2(Respuesta nvarchar(max));
 
 	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                  
	from @periodo                  
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros ,@IDUsuario= @IDUsuario   
    
    select  @NoCliente = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No Cliente'  
  
    select  @NoArchivoDia = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'No Archivo del dia'  
  
    select  @CuentaCargo = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Cuenta de Cargo'  
     
    select  @ReferenciaEmpresa = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Referencia Empresa'  
     
    select  @FormaPago = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Forma pago'  
     
    select  @ConceptoPago = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Concepto de Pago'  
  
    select  @ConceptoPagoDescripcion = lpp.Valor  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Descripcion Concepto de Pago'  
   
    select  @ReferenciaPago = case when ISNULL(lpp.Valor,0) = 0 THEN 0 else CAST(ISNULL(lpp.Valor,0) as int)END  
    from Nomina.tblLayoutPago lp  
        inner join Nomina.tblLayoutPagoParametros lpp on lp.IDLayoutPago = lpp.IDLayoutPago  
        inner join Nomina.tblCatTiposLayoutParametros ctlp on ctlp.IDTipoLayout = lp.IDTipoLayout  
            and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
    where lp.IDLayoutPago = @IDLayoutPago and ctlp.Parametro = 'Referencia de Pago'  

    insert into #tempHeader1(Respuesta)   
    select     
      [App].[fnAddString](4,'EEHA','0',1)     
      +[App].[fnAddString](5,@NoCliente,'0',1)     
      +[App].[fnAddString](2,@NoArchivoDia,'0',1)     
      +[App].[fnAddString](27,'0','0',1)     
      +[App].[fnAddString](332,'',' ',1)     
  
    insert into #tempHeader2(Respuesta)  
    select     
        [App].[fnAddString](4,'EEHB','0',1)     
        +[App].[fnAddString](17,@CuentaCargo,'0',1)     
        +[App].[fnAddString](10,@ReferenciaEmpresa,'0',1)     
        +[App].[fnAddString](3,'0','0',1)     
        +[App].[fnAddString](336,'',' ',1)     
     
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
        insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago, IDBanco, CuentaBancaria)
        SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,
				case when pe.IDBanco = tl.IDBanco then isnull(replace( pe.Cuenta,' ',''), replace( pe.Tarjeta,' ','')) 
				else replace( pe.Interbancaria,' ','') end 
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
  
    insert into #tempempleados(Respuesta)  
    select     
        [App].[fnAddString](4,'EEDA','0',1)     
        +[App].[fnAddString](2,@FormaPago,'0',1)     
        +[App].[fnAddString](2,'00','0',1)     
        +[App].[fnAddString](15,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)    
        +[App].[fnAddString](8,isnull(format(@FechaDispersion,'yyyyMMdd'),''),'',2)    
        +[App].[fnAddString](2,isnull(@ConceptoPago,''),'',2)    
        +[App].[fnAddString](20,e.ClaveEmpleado,'',2)    
        +[App].[fnAddString](13,'','',2)  --e.RFC  
        +[App].[fnAddString](40,RTrim(isnull(e.NOMBRECOMPLETO,''))COLLATE Cyrillic_General_CI_AI,'',2)    
        +[App].[fnAddString](6,isnull('000000',''),'0',2)    
        --+[App].[fnAddString](10,isnull('1',''),'0',1)    
        +[App].[fnAddString](10,isnull((@ReferenciaPago + ROW_NUMBER()OVER(ORDER BY e.IDEmpleado asc)),'0'),'0',1)    
        +[App].[fnAddString](30,isnull(case when pe.IDBanco = tl.IDBanco then isnull(replace( pe.Cuenta,' ',''), replace( pe.Tarjeta,' ','')) else replace( pe.Interbancaria,' ','') end ,'0'),'0',1)    
        +[App].[fnAddString](5,isnull('00000','0'),'0',1)    
        +[App].[fnAddString](40,'','',2)   
        +[App].[fnAddString](1,isnull(case when pe.IDBanco = tl.IDBanco then case when pe.Cuenta is not null THEN 1 ELSE 3 END else 9 end,'0'),'0',1)  
        +[App].[fnAddString](1,'','',2)   
        +[App].[fnAddString](8,cast('00000044' as varchar(8)),'0',1)    
        +[App].[fnAddString](3,isnull(b.Codigo,'0'),'0',1)    
  
        +[App].[fnAddString](3,'001','0',1)    
        +[App].[fnAddString](50,isnull(@ConceptoPagoDescripcion,''),' ',2)    
        +[App].[fnAddString](60,'1',' ',2)    
        +[App].[fnAddString](25,isnull('0','0'),'0',1)    
        +[App].[fnAddString](22,isnull('',''),'',1)      
    FROM  @empleados e     
        INNER JOIN Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo   
        INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado
        LEFT JOIN Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
        INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
        INNER JOIN Nomina.tblCatTiposLayout tl on lp.IDTipoLayout = tl.IDTipoLayout   
        INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo        
            and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
            and dp.IDEmpleado = e.IDEmpleado    
    where  pe.IDLayoutPago = @IDLayoutPago    
  
    Declare @SumAll Decimal(16,2)  
  
    select @SumAll =  SUM(case when lp.ImporteTotal = 1 then isnull(dp.ImporteTotal1,0) else isnull(dp.ImporteTotal2,0) end)
    FROM @empleados e    
        INNER join Nomina.tblCatPeriodos p on  p.IDPeriodo = @IDPeriodo   
        INNER JOIN RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado  
        LEFT JOIN Sat.tblCatBancos b on pe.IDBanco = b.IDBanco    
        INNER JOIN  Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago    
        INNER JOIN Nomina.tblCatTiposLayout tl on tl.TipoLayout = 'SCOTIABANK'    
            and lp.IDTipoLayout = tl.IDTipoLayout    
        INNER JOIN Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo    
            and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
            and dp.IDEmpleado = e.IDEmpleado    
    where pe.IDLayoutPago = @IDLayoutPago    
     
    insert into #tempFooter1(Respuesta)  
    select     
        [App].[fnAddString](4,'EETB','0',1)     
        +[App].[fnAddString](7,(select count(*) from #tempempleados),'0',1)     
        +[App].[fnAddString](17, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)     
        +[App].[fnAddString](219,'0','0',1)     
        +[App].[fnAddString](123,'',' ',1)     
  
    insert into #tempFooter2(Respuesta)  
    select     
        [App].[fnAddString](4,'EETA','0',1)     
        +[App].[fnAddString](7,(select count(*) from #tempempleados),'0',1)     
        +[App].[fnAddString](17,replace(cast(@SumAll as varchar(max)),'.','') ,'0',1)      
        +[App].[fnAddString](219,'0','0',1)     
        +[App].[fnAddString](123,'',' ',1)     
  
  
    insert into #tempResp(Respuesta)  
    select respuesta from #tempHeader1  
    union all  
    select respuesta from #tempHeader2  
    union all  
    select respuesta from #tempempleados  
    union all  
    select respuesta from #tempFooter1  
    union all  
    select respuesta from #tempFooter2  
     
    select * from #tempResp    
END
GO
