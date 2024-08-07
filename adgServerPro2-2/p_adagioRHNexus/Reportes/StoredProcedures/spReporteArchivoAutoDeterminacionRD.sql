USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Reportes].[spReporteArchivoAutoDeterminacionRD]--2,'2018-12-27',8,0    
(    
 
 @dtFiltros [Nomina].[dtFiltrosRH]  readonly,
 @IDUsuario int      
)    
AS    
BEGIN 

	DECLARE 
		@empleados [RH].[dtEmpleados]      
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date
        ,@IDCliente int 
        ,@Ejercicio int
        ,@IDMes int
        ,@IDPais int
        
    SET @IDCliente = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
						else 0 
    END                    
    SET @Ejercicio = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))  
						else 0                     

	END  
    SET @IDMes = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))  
						else 0                     

	END  
    
    SELECT @IDPais=IDPais FROM SAT.tblCatPaises WHERE Codigo='DOM'

    

	
    insert into @periodo      
	select  *     
		--IDPeriodo      
		--,IDTipoNomina      
		--,Ejercicio      
		--,ClavePeriodo      
		--,Descripcion      
		--,FechaInicioPago      
		--,FechaFinPago      
		--,FechaInicioIncidencia      
		--,FechaFinIncidencia      
		--,Dias      
		--,AnioInicio      
		--,AnioFin      
		--,MesInicio      
		--,MesFin      
		--,IDMes      
		--,BimestreInicio      
		--,BimestreFin      
		--,Cerrado      
		--,General      
		--,Finiquito      
		--,isnull(Especial,0)      
	from Nomina.tblCatPeriodos With (nolock)      
	where      
		(((IDTipoNomina in (SELECT IDTipoNomina FROM Nomina.tblCatTipoNomina WHERE IDCliente=@IDCliente))                       
		and (IDMes in (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
		)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))   
		and isnull(Cerrado,0) = 1
    
      
 

    select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

    insert into @empleados                  
	exec [RH].[spBuscarEmpleados]  @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
    
    
    
	 -- HEADER 
	
	DECLARE @MES VARCHAR(2);

    IF(LEN(@IDMes)=1)
    BEGIN
        SET @MES=CONCAT('0',CAST(@IDMes AS varchar(2)))
    END
    ELSE 
    BEGIN
        SET @MES=CAST(@IDMes AS varchar(2))
    END
    
    if object_id('tempdb..#tempHeader1') is not null 
    drop table #tempHeader1;    

	create table #tempHeader1(Respuesta nvarchar(max)); 
    
    
    insert into #tempHeader1(Respuesta)   
	select  
		[App].[fnAddString](1,'E','',1) --Tipo Registro
       +[App].[fnAddString](2,'AM','',2) --Proceso
       +[App].[fnAddString](11,'105045044',' ',1) --Clave del empleador
       +[App].[fnAddString](6,CONCAT(@MES,CAST(@Ejercicio AS VARCHAR(4))),'',2) --Periodo de autodeterminacion
		
	 -- HEADER 
     

	 -- CUERPO DE EMPLEADOS
	
    if object_id('tempdb..#tempBajas') is not null 
    drop table #tempBajas;    
    if object_id('tempdb..#tempEmpleadosPasaporte') is not null 
    drop table #tempEmpleadosPasaporte;    
    -- if object_id('tempdb..#tempEmpledos') is not null 
    -- drop table #tempEmpleados;
    if object_id('tempdb..#tempSalarioSS') is not null 
    drop table #tempSalariosSS;    
    if object_id('tempdb..#tempSalariosISR') is not null 
    drop table #tempSalariosISR;    
    if object_id('tempdb..#tempOtrasRemuneraciones') is not null 
    drop table #tempOtrasRemuneraciones;
    if object_id('tempdb..#tempExentos') is not null 
    drop table #tempExentos;        

    DECLARE 
        @IDConceptoRD122 INT--Reembolso
       ,@IDConceptoRD134 INT --Incentivos
	   ,@IDConceptoRD133  INT --Bonificacion (Reparto Utilidades)
       ,@IDConceptoRD135 INT --Incentivo a tercero
       ,@IDConceptoRD136 INT --Incentivo Prepago
       ,@IDConceptoRD142 INT --SalarioNavideño
       ,@IDConceptoRD152 INT --Cesantia
       ,@IDConceptoRD153 INT --Preaviso
       ,@IDConceptoRD138 INT --Comisiones Inflight
       ,@IDConceptoRD139 INT --Pool Comissions
       ,@IDConceptoRD140 INT --Comisiones representantes
       ,@IDConceptoRD141 INT --Over Comissions
	   ,@IDConceptoRD144  INT --Gratificaciones
       ,@IDConceptoRD099 INT --Amortizaciones de ISR

       
       ;

    SELECT @IDConceptoRD122=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD122'
	SELECT @IDConceptoRD133=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD133'
    SELECT @IDConceptoRD134=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD134'
    SELECT @IDConceptoRD135=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD135'
    SELECT @IDConceptoRD136=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD136'
    SELECT @IDConceptoRD142=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD142'
    SELECT @IDConceptoRD152=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD152'
    SELECT @IDConceptoRD153=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD153'
    SELECT @IDConceptoRD138=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD138'
    SELECT @IDConceptoRD139=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD139'
    SELECT @IDConceptoRD140=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD140'
    SELECT @IDConceptoRD141=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD141'
	SELECT @IDConceptoRD144=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD144'
    SELECT @IDConceptoRD099=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD099'



	
    create table #tempEmpleadosPasaporte(
        IDEmpleado int,
        ClaveEmpleado varchar(max),
        RFC VARCHAR(max)
        ); 

---Determinando colaboradores con ultimo movimiento de baja
    select m.*,ROW_NUMBER()OVER(partition by m.idempleado order by m.fecha desc) RN
	   into #tempBajas
	  from @empleados  E
		inner join IMSS.tblMovAfiliatorios M
		 on E.IDEmpleado = M.IDEmpleado
		 --and M.IDTipoMovimiento in (Select  IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'B')
		 and m.Fecha >= e.FechaAntiguedad
		 and m.Fecha <= @fechaFinPeriodo
         ORDER BY IDEmpleado DESC
			
	delete #tempBajas
	    where RN > 1
    delete #tempBajas
	    where IDTipoMovimiento<>(Select  IDTipoMovimiento 
                                        from IMSS.tblCatTipoMovimientos
                                        where Codigo = 'B')



---Son todas las percepciones  menos las que digan incentivo,gratificacion,reembolso,salario de navidad,cesantia y preaviso
    select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as TotalSalariosSS
		into #tempSalariosSS
		from nomina.tblDetallePeriodo dp            
			inner join nomina.tblCatConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			LEFT join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
            inner join @empleados e 
                on e.IDEmpleado=dp.IDEmpleado       
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'     
			AND DP.IDConcepto NOT IN (
                @IDConceptoRD122--Reembolso
				,@IDConceptoRD133--Bonificacion (Reparto Utilidades)
                ,@IDConceptoRD134--Incentivos
                ,@IDConceptoRD135--Incentivo a tercero
                ,@IDConceptoRD136--Incentivo prepago
                ,@IDConceptoRD142--Salario Navideño
				,@IDConceptoRD144--Gratificacion
                ,@IDConceptoRD152--Cesantia
                ,@IDConceptoRD153--Preaviso

                ) AND DP.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
		group by dp.IDEmpleado
        order by dp.IDEmpleado asc    

---Todo lo que genera impuesto ISR menos comisiones e incentivos 
    select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as TotalSalarioISR
		into #tempSalariosISR
		from nomina.tblDetallePeriodo dp            
			inner join nomina.tblCatConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			LEFT join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
            inner join @empleados e 
                on e.IDEmpleado=dp.IDEmpleado       
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'     
			AND DP.IDConcepto NOT IN (
                @IDConceptoRD122--Reembolso
				,@IDConceptoRD133--Bonificacion (Reparto Utilidades)
                ,@IDConceptoRD134--Incentivos
                ,@IDConceptoRD135--Incentivo a tercero
                ,@IDConceptoRD136--Incentivo prepago
                ,@IDConceptoRD138--Comisiones Inflight
                ,@IDConceptoRD139--Pool Comissions
                ,@IDConceptoRD140--Comisiones representantes
                ,@IDConceptoRD141--Over Comissions
				,@IDConceptoRD144--Gratificaciones
                ) AND DP.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
		group by dp.IDEmpleado 
        order by dp.IDEmpleado asc       

---Comisiones e incentivos
    select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as TotalOtrasRemuneraciones
		into #tempOtrasRemuneraciones
		from nomina.tblDetallePeriodo dp            
			inner join nomina.tblCatConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			LEFT join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
            inner join @empleados e 
                on e.IDEmpleado=dp.IDEmpleado       
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'     
			AND DP.IDConcepto IN (
				 @IDConceptoRD133--Bonificacion (Reparto Utilidades)
                ,@IDConceptoRD134--Incentivos
                ,@IDConceptoRD135--Incentivos a tercero
                ,@IDConceptoRD136--Incentivo Prepago
                ,@IDConceptoRD138--Comisiones inflight
                ,@IDConceptoRD139--Pool Comissions
                ,@IDConceptoRD140--Comisiones Representantes
                ,@IDConceptoRD141--Over Comissions
				,@IDConceptoRD144--Gratificaciones
                ) AND DP.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
		group by dp.IDEmpleado
        order by dp.IDEmpleado asc    

        -- SELECT * FROM #tempSalariosSS
        -- RETURN
-----Conceptos Exentos de ISR
     select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteTotal1) as TotalExentos
		into #tempExentos
		from nomina.tblDetallePeriodo dp            
			inner join nomina.tblCatConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			LEFT join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
            inner join @empleados e 
                on e.IDEmpleado=dp.IDEmpleado       
		where tc.Descripcion = 'PERCEPCION'     
			AND DP.IDConcepto IN (
                @IDConceptoRD142--Salario navideño
               ,@IDConceptoRD152--Cesantia
               ,@IDConceptoRD153--Preaviso
               ,@IDConceptoRD122--Reembolso
                ) AND DP.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
		group by dp.IDEmpleado
        order by dp.IDEmpleado asc        


    ---Agregar colaboradores que se identifiquen con Pasaporte
    insert into #tempEmpleadosPasaporte(IDEmpleado,ClaveEmpleado,RFC)
    SELECT IDEmpleado,ClaveEmpleado,RFC 
    FROM @empleados
    WHERE ClaveEmpleado IN(
        'RD00964'
    )

    if object_id('tempdb..#tempBody') is not null 
    drop table #tempBody;    
    create table #tempBody(Respuesta nvarchar(max),orden int identity(1,1));     
	
    insert into #tempBody(Respuesta)   
	select     
		[App].[fnAddString](1,'D','',1) --Tipo de registro (DETALLE)
        +[App].[fnAddString](3,'001','',2) --Clave de Nomina
        -- +[App].[fnAddString](10,e.ClaveEmpleado,'-',1) --Tipo de Documento
        +[App].[fnAddString](1,CASE WHEN ep.IDEmpleado IS null THEN 'C' ELSE  'P' END,'',2) --Tipo de Documento
        --+[App].[fnAddString](25,CASE WHEN ep.IDEmpleado IS null THEN ISNULL(e.RFC,'?????????') ELSE  ISNULL(ep.RFC,'?????????') END,' ',2) --Numero de documento
        +[App].[fnAddString](25,REPLACE(CASE WHEN ep.IDEmpleado IS null THEN ISNULL(e.RFC,'?????????') ELSE  ISNULL(ep.RFC,'?????????') END,'-',''),' ',2) --Numero de documento
        +[App].[fnAddString](50,ISNULL(e.Nombre,'')+ CASE WHEN ISNULL(e.SegundoNombre,'') <> '' THEN ' '+COALESCE(e.SegundoNombre,'') ELSE '' END,' ',2) --Nombre
        +[App].[fnAddString](40,ISNULL(e.Paterno,''),' ',2) --Paterno
        +[App].[fnAddString](40,ISNULL(E.Materno,''),' ',2) --Materno
        +[App].[fnAddString](1,ISNULL(E.Sexo,''),'',2) --SEX
        +[App].[fnAddString](8,isnull(format(e.FechaNacimiento,'ddMMyyyy'),''),'',2) --Fecha de Nacimiento
        +[App].[fnAddString](16,CAST(ISNULL(SalarioSS.TotalSalariosSS,0.00) AS VARCHAR(MAX)),'0',1) --Salario SS
        +[App].[fnAddString](16,'0.00','0',1) --Aporte Ordinario Voluntario
        +[App].[fnAddString](16,CAST(ISNULL(SalarioISR.TotalSalarioISR,0.00) AS VARCHAR(MAX)),'0',1) --Salario ISR
        +[App].[fnAddString](16,CAST(ISNULL(OtrasRemuneracions.TotalOtrasRemuneraciones,0.00) AS VARCHAR(MAX)),'0',1) --Otras Remuneraciones
        +[App].[fnAddString](11,'',' ',2) --RNC O Cedula del Agente de Retencion del ISR (NO APLICA)
        +[App].[fnAddString](16,'0.00','0',1) --Remuneracion de otros empleadores
        +[App].[fnAddString](16,'0.00','0',1) --Ingresos Exentos de ISR
        +[App].[fnAddString](16,CAST(ISNULL(SaldoAFavor.ImporteTotal1,0.00) AS VARCHAR(MAX)),'0',1) --Saldo a favor del periodo
        +[App].[fnAddString](16,CAST(ISNULL(SalarioSS.TotalSalariosSS,0.00) AS VARCHAR(MAX)),'0',1) --Salario infotep
        +[App].[fnAddString](4,CASE WHEN Bajas.IDEmpleado IS null THEN '0001' ELSE  '0004' END,'',1) --Tipo Ingreso 0001 para todos 0004 para bajas
        +CASE WHEN Exentos.IDEmpleado IS NOT null 
        THEN +'01'+[App].[fnAddString](16,CAST(ISNULL(Exentos.TotalExentos,0.00) AS VARCHAR(MAX)),'0',1) ---Conceptos ExentosISR
         ELSE ''
         END
	FROM  @empleados e
    LEFT JOIN #tempEmpleadosPasaporte ep
                ON  ep.IDEmpleado=e.IDEmpleado
    LEFT JOIN #tempSalariosSS SalarioSS
                ON  SalarioSS.IDEmpleado=e.IDEmpleado
    LEFT JOIN #tempSalariosISR SalarioISR
                ON  SalarioISR.IDEmpleado=e.IDEmpleado
    LEFT JOIN #tempOtrasRemuneraciones OtrasRemuneracions
                ON  OtrasRemuneracions.IDEmpleado=e.IDEmpleado
    LEFT JOIN #tempBajas Bajas
                ON Bajas.IDEmpleado=e.IDEmpleado                                                    
    LEFT JOIN #tempExentos Exentos
                ON Exentos.IDEmpleado=e.IDEmpleado                                                                    
    Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoRD099,@IDMes,@Ejercicio)  as SaldoAFavor               
    order by e.IDEmpleado asc

	 -- SALIDA
	-- if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
		
	-- create table #tempResp(Respuesta nvarchar(max)); 
	 
	-- insert into #tempResp(Respuesta)  
    -- select respuesta from #tempHeader1 
	-- insert into #tempResp(Respuesta)  
	-- select respuesta from #tempBody

	-- SELECT * FROM #tempResp
     if object_id('tempdb..#tempResp') is not null    
		drop table #tempResp;    
    
    create table #tempResp(Respuesta nvarchar(max), orden int identity(1,1));   

	 insert into #tempResp(Respuesta)  
	 select respuesta from #tempHeader1  
	 
     insert into #tempResp(Respuesta)  
	 select respuesta 
     from #tempBody  
     order by orden asc
	  
    if object_id('tempdb..#tempFooter') is not null 
    drop table #tempFooter;    
    create table #tempFooter(Sumario nvarchar(max),orden int identity(1,1));     

    Declare @Filas int

    SELECT @Filas=Count(*)+1
    FROM #tempResp

    insert into #tempFooter(Sumario)
    Select 
    [App].[fnAddString](1,'S','',1)
    +[App].[fnAddString](6,@Filas,'0',1)


     insert into #tempResp(Respuesta)  
	 select Sumario
     from #tempFooter  
     order by orden asc

	 select Respuesta 
     from #tempResp 
     order by orden asc

	 --SALIDA
END
GO
