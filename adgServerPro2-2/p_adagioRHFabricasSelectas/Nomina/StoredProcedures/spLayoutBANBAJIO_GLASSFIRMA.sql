USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	NO MOVER
	ARTURO
	NO MOVER / QUITAR
	IMPORTANTE HRSJ
*/
CREATE PROCEDURE  [Nomina].[spLayoutBANBAJIO_GLASSFIRMA]--2,'2018-12-27',8,0    
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
		,@TotalPagado int
		--,@NombreArchivo Nvarchar(max)  

	-- PARAMETROS
	,@GrupoAfinidad Varchar(12)
	,@SecArchivo Varchar(4)
	,@NoCuenta Varchar(20)
	-- PARAMETROS


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
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Grupo Afinidad'  

	select @SecArchivo = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'Secuencia Archivo'  

	select @NoCuenta = lpp.Valor  
	from Nomina.tblLayoutPago lp  
		inner join Nomina.tblLayoutPagoParametros lpp  
			on lp.IDLayoutPago = lpp.IDLayoutPago  
		inner join Nomina.tblCatTiposLayoutParametros ctlp  
			on ctlp.IDTipoLayout = lp.IDTipoLayout  
				and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	where lp.IDLayoutPago = @IDLayoutPago  
		and ctlp.Parametro = 'No. Cuenta' 
	 -- CARGAR PARAMETROS EN VARIABLES

	if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
		create table #tempResp(Respuesta nvarchar(max),RN int);   


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
				on lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp    
				on dp.IDPeriodo = @IDPeriodo    
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

	-- HEADER 
	if object_id('tempdb..#tempHeader1') is not null drop table #tempHeader1;    
	create table #tempHeader1(Respuesta nvarchar(max), RN int); 

	insert into #tempHeader1(Respuesta, RN)
select  
	[App].[fnAddString](2, '01', '0', 1)           -- TIPO DE REGISTRO
   +[App].[fnAddString](7, Row_Number() OVER (ORDER BY (SELECT 1)), '0', 1)    -- NÚMERO DE SECUENCIA
   +[App].[fnAddString](3, '030', '0', 1)          -- BANCO RECEPTOR
   +[App].[fnAddString](1, 'S', '0', 1)            -- SENTIDO
   +[App].[fnAddString](2, '90', '0', 1)           -- CÓDIGO - DE NÓMINA
   +[App].[fnAddString](1, '0', '0', 1)            -- FILLER
   +[App].[fnAddString](7, ISNULL(@GrupoAfinidad, '0000000'), '0', 1) -- GRUPO DE AFINIDAD ASIGNADO POR BANCO DEL BAJIO A LA EMPRESA
   +[App].[fnAddString](8, ISNULL(CONVERT(varchar, GETDATE(), 112), '00000000'), '0', 1) -- FECHA DE GENERACIÓN
   +[App].[fnAddString](20, ISNULL(@NoCuenta, '0000000000'), '0', 1)     -- NÚMERO DE CUENTA DE LA EMPRESA
   +[App].[fnAddString](129, ' ', ' ', 1)          -- FILLER
   , 1 as RN;

	 -- HEADER 
	 
	 -- CUERPO DE EMPLEADOS
		Declare @SumAll Decimal(16,2)  
		
		select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
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
				and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
				and dp.IDEmpleado = e.IDEmpleado    
	where  pe.IDLayoutPago = @IDLayoutPago   

	if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max),RN int); 


	insert into #tempBody(Respuesta,RN)
select     
     [App].[fnAddString](2, '02', '0', 1)                                        -- TIPO DE REGISTRO
    + [App].[fnAddString](7, Row_Number() OVER (ORDER BY (SELECT 1) ASC) + 1, '0', 1)   -- NÚMERO DE SECUENCIA
    + [App].[fnAddString](2, '90', '0', 1)                                        -- CÓDIGO DE OPERACIÓN
    + [App].[fnAddString](8, ISNULL(CONVERT(varchar, @FechaDispersion, 112), '00000000'), '0', 1) -- FECHA DE PRESENTACIÓN
    + [App].[fnAddString](3, '000', '0', 1)                                       -- FILLER - CEROS
    + [App].[fnAddString](3, '030', '0', 1)                                       -- BANCO
    + [App].[fnAddString](15, REPLACE(CAST(ISNULL(CASE 
                              WHEN lp.ImporteTotal = 1 
                                  THEN dp.ImporteTotal1 
                              ELSE dp.ImporteTotal2 
                              END, 0) AS varchar(max)), '.', ''), '0', 1)         -- IMPORTE A DEPOSITAR
    + [App].[fnAddString](8, ISNULL(CONVERT(varchar, @FechaDispersion, 112), '00000000'), '0', 1) -- FECHA DE APLICACIÓN
    + [App].[fnAddString](2, '00', '0', 1)                                        -- FILLER - CEROS
    + [App].[fnAddString](20, ISNULL(@NoCuenta, '0000000000'), '0', 1)            -- NÚMERO DE CUENTA DE LA EMPRESA
    + [App].[fnAddString](1, ' ', ' ', 1)                                         -- FILLER - ESPACIO
    + [App].[fnAddString](2, '00', '0', 1)                                        -- FILLER - CEROS
    + [App].[fnAddString](20, ISNULL(pe.Cuenta, '99999999999999999999'), '0', 1)  -- NÚMERO DE CUENTA DEL EMPLEADO
    + [App].[fnAddString](1, ' ', ' ', 1)                                         -- FILLER - ESPACIO
    + [App].[fnAddString](7, ISNULL(e.ClaveEmpleado, '0000000'), '0', 1)          -- NÚMERO DE NÓMINA DEL EMPLEADO
    + [App].[fnAddString](40, 'DEPOSITO DE NOMINA', ' ', 2)                       -- LEYENDA
    + [App].[fnAddString](30, '0', '0', 2)                                        -- NÚMERO DE TARJETA
    + [App].[fnAddString](10, '0000000000', '0', 1)                               -- FILLER - CEROS
    , CAST(Row_Number() OVER (ORDER BY (SELECT 1) ASC) + 1 AS int)
from @empleados e
    inner join Nomina.tblCatPeriodos p on p.IDPeriodo = @IDPeriodo
    inner join RH.tblPagoEmpleado pe on pe.IDEmpleado = e.IDEmpleado
    left join Sat.tblCatBancos b on pe.IDBanco = b.IDBanco
    inner join Nomina.tblLayoutPago lp on lp.IDLayoutPago = pe.IDLayoutPago
    inner join Nomina.tblCatTiposLayout tl on lp.IDTipoLayout = tl.IDTipoLayout
    inner join Nomina.tblDetallePeriodo dp on dp.IDPeriodo = @IDPeriodo
        and dp.IDConcepto = case when ISNULL(p.Finiquito, 0) = 0 
                                 then lp.IDConcepto 
                                 else lp.IDConceptoFiniquito 
                            end
        and dp.IDEmpleado = e.IDEmpleado
where pe.IDLayoutPago = @IDLayoutPago;
   

	select @CountEmpleados = count(*) from #tempBody
	-- CUERPO DE EMPLEADOS

	-- FOOTER    
	if object_id('tempdb..#tempFooter') is not null drop table #tempFooter;    
	create table #tempFooter(Respuesta nvarchar(max), RN int);    
  
	insert into #tempFooter(Respuesta, RN)  
	select     
		 [App].[fnAddString](2,'09','0',1)             --IMP (COL (1)  , '09'); //TIPO DE REGISTRO - INICIO DE ENCABEZADO    
		+[App].[fnAddString](7,@CountEmpleados+2,'0',1)      --IMP (COL (3)  , DER (_secuencia,7)); //NUMERO DE SECUENCIA
		+[App].[fnAddString](2,'90','0',1)             --IMP (COL (10) , '90'); //CODIGO - DE NOMINA
		+[App].[fnAddString](7,@CountEmpleados,'0',1)  --IMP (COL (12) , DER (_no_operaciones,7)); //NUMERO DE OPERACIONES
		+[App].[fnAddString](18,replace(cast(isnull(@SumAll,0)   as varchar(max)),'.',''),'0',1)    -- IMP (COL (19) , DER(PESOS (_totalPago), 18))			//IMPORTE TOTAL
		+[App].[fnAddString](145,'',' ',1)             --IMP (COL (181), ' '); //FILLER
		, @CountEmpleados+2
	-- FOOTER

	--NOMBRE ARCHIVO
	-- SELECT @NombreArchivo = concat('D',@GrupoAfinidad,@SecArchivo,Format((MONTH(@FechaDispersion)*.10),'0.#'),DAY(@FechaDispersion),'.txt');
	--NOMBRE ARCHIVO

	-- SALIDA



	--insert into #tempResp(Respuesta)  
		SELECT R.respuesta 
		FROM (
		select respuesta, RN from #tempHeader1  
		union all    
			select respuesta, RN from #tempBody  
				union all
					select respuesta, RN from #tempFooter
					) R
		ORDER BY R.RN asc
	--select * from #tempResp
	
	-- SALIDA

END
GO
