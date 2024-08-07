USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SP IMPORTANTE
	NO MOVER
	
*/

	CREATE PROC [Reportes].[spReportePolizaSurfax](    
		 @dtFiltros Nomina.dtFiltrosRH readonly    
		,@IDUsuario int    
	) as   

	declare 
		 @empleados [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@IDTipoNomina int     
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date    
		,@RazonSocial int   
		,@periodoSeleccionado int
		,@diaDehoy date
		,@diaPoliza varchar (6)
		,@referencia varchar (5)
	
		set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
			THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
			else 0  
		END 

		set @RazonSocial = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) 
			THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
			else 0  
		END 

        
		/* Se buscan el periodo seleccionado */    
		insert into @periodo  
		select *  
		from Nomina.tblCatPeriodos  
			where ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
				or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))       
		
		     
		select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo
		
		select @diaDehoy = FechaFinPago from @periodo
		Select @diaPoliza = CONVERT(varchar,@diaDehoy,12)
		set @referencia = '1RA Q'

		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
		insert into @empleados        
			exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


     if object_id('tempdb..#tempData') is not null        
		drop table #tempData 
		SELECT Conceptos.OrdenCalculo
		       ,Conceptos.Codigo                  as Clave_concepto
			   ,Conceptos.Descripcion             as concepto
			   ,Division.Descripcion              as Division
			   ,CentroCosto.Descripcion           as CentroCosto
 			   ,Conceptos.CuentaAbono             as Cuenta_Abono
			   ,Conceptos.CuentaCargo             as Cuenta_Cargo
			   ,CentroCosto.CuentaContable        as Cuenta_costo
			   ,Departamentos.CuentaContable      as Cuenta_Depto
			   ,Division.CuentaContable           as Cuenta_Contable
			   ,SUM(detallePeriodo.ImporteTotal1) as Total
		 INTO #tempData 
				FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
			INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
			INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
			INNER JOIN RH.tblCatCentroCosto CentroCosto on CentroCosto.IDCentroCosto = Empleados.IDCentroCosto
			INNER JOIN RH.tblCatDivisiones Division on Division.IDDivision = Empleados.IDDivision
			INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( ( ISNULL (Conceptos.CuentaCargo , '' ) <> '') OR ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' ))
		--( tiposConceptos.Descripcion = 'DEDUCCION' AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  
				--AND ( ISNULL (Empleados.IDRegPatronal , 0 ) = @RazonSocial ) 
				AND (Conceptos.Codigo NOT in ('601','604'))
		GROUP BY Conceptos.OrdenCalculo
		       ,Conceptos.Codigo
			   ,Conceptos.Descripcion
			   ,Division.Descripcion
			   ,CentroCosto.Descripcion
			   ,Conceptos.CuentaAbono
			   ,Conceptos.CuentaCargo
			   ,CentroCosto.CuentaContable
			   ,Departamentos.CuentaContable
			   ,Division.CuentaContable
        HAVING (SUM(detallePeriodo.ImporteTotal1) <> 0 )
		ORDER BY Conceptos.OrdenCalculo ASC,
		         Division.CuentaContable ASC  
				 
        if object_id('tempdb..#tempDataDetalle') is not null        
		drop table #tempDataDetalle 
		SELECT Conceptos.OrdenCalculo
		       ,Conceptos.Codigo                  as Clave_concepto
			   ,Conceptos.Descripcion             as concepto
			   ,Division.Descripcion              as Division
			   ,CentroCosto.Descripcion           as CentroCosto
 			   ,Conceptos.CuentaAbono             as Cuenta_Abono
			   ,Conceptos.CuentaCargo             as Cuenta_Cargo
			   ,CentroCosto.CuentaContable        as Cuenta_costo
			   ,Departamentos.CuentaContable      as Cuenta_Depto
			   ,Division.CuentaContable           as Cuenta_Contable
			   ,Empleados.ClaveEmpleado           as Clave_Trabajador
			   ,Empleados.RFC                     as Rfc
			   ,UPPER(isnull(Timbrado.UUID,''))   as UUID
			   ,detallePeriodo.ImporteTotal1      as Total
		 INTO #tempDataDetalle 
				FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
			INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
			INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
			INNER JOIN RH.tblCatCentroCosto CentroCosto on CentroCosto.IDCentroCosto = Empleados.IDCentroCosto
			INNER JOIN RH.tblCatDivisiones Division on Division.IDDivision = Empleados.IDDivision
			INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
			LEFT JOIN Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detallePeriodo.IDEmpleado		
			LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock) on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1

		WHERE ( ( ISNULL (Conceptos.CuentaCargo , '' ) <> '') OR ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' ))
		--( tiposConceptos.Descripcion = 'DEDUCCION' AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  
				--AND ( ISNULL (Empleados.IDRegPatronal , 0 ) = @RazonSocial ) 
                AND (Conceptos.Codigo in ('601','604'))
		ORDER BY Conceptos.OrdenCalculo ASC,
		         CentroCosto.Descripcion ASC,
				 CentroCosto.CuentaContable ASC,
				 Departamentos.CuentaContable ASC,
		         Division.CuentaContable ASC 
   
   --SELECT * FROM #tempData
     --union all      
   --SELECT * FROM #tempDataDetalle
 --   SELECT *
 --    FROM #tempData t
 --       WHERE  (ISNULL (t.Cuenta_cargo , '' ) <> '')

	--SELECT * 
	--FROM #tempData t
 --       WHERE  (ISNULL (t.Cuenta_Abono , '' ) <> '')

   if object_id('tempdb..#Cargo') is not null drop table #Cargo;   
		create table #Cargo(Respuesta nvarchar(max)); 
		insert into #Cargo(Respuesta)
		SELECT '001' 
			  +[App].[fnAddString] (40 , t.Clave_concepto + '-'+ t.concepto , '' , 2 )
		      +[App].[fnAddString] (40 , t.Cuenta_cargo,'', 2 )
			  +[App].[fnAddString] (18 , t.Cuenta_costo,'', 2 )
              +[App].[fnAddString] (18 , t.Cuenta_depto,'', 2 )
			  +[App].[fnAddString] (18 , t.Cuenta_contable,'', 2 )
			  +[App].[fnAddString] (17,
				RIGHT('                 ' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(17), ISNULL (  t.total , 0 ) ) ), '.','' ) ) ) , 17  )
				,''
				, 0 )
              +[App].[fnAddString] (5 ,'','', 2 )
			  +'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
			  +'    '
			  +'XXXXXXXXXXXXX '
		  FROM #tempData t
        WHERE  (ISNULL (t.Cuenta_cargo , '' ) <> '')
    --SELECT * FROM #Cargo

	if object_id('tempdb..#Abono') is not null drop table #Abono;   
		create table #Abono(Respuesta nvarchar(max)); 
		insert into #Abono(Respuesta)
		SELECT '001' 
			  +[App].[fnAddString] (40 , t.Clave_concepto + '-'+ t.concepto , '' , 2 )
			  +[App].[fnAddString] (20 , '','', 2 )
		      +[App].[fnAddString] (28 , t.Cuenta_Abono,'', 2 )
			  +[App].[fnAddString] (19 , t.Cuenta_costo,'', 2 )
			  +[App].[fnAddString] (18 , t.Cuenta_depto,'', 2 )
			  +[App].[fnAddString] (9 , t.Cuenta_contable,'', 2 )
			  +[App].[fnAddString] (17,
				RIGHT('                 ' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(17), ISNULL (  t.total , 0 ) ) ), '.','' ) ) ) , 17  )
				,''
				, 0 )
              +[App].[fnAddString] (5 ,'','', 2 )
			  +'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
			  +'    '
			  +'XXXXXXXXXXXXX '
			  
		  FROM #tempData t
        WHERE  (ISNULL (t.Cuenta_Abono , '' ) <> '')
    --SELECT * FROM #Abono
	if object_id('tempdb..#AbonoDetalle') is not null drop table #AbonoDetalle;   
		create table #AbonoDetalle(Respuesta nvarchar(max)); 
		insert into #AbonoDetalle(Respuesta)
		SELECT '001' 
			  +[App].[fnAddString] (40 , t.Clave_concepto + '-'+ t.concepto , '' , 2 )
			  +[App].[fnAddString] (20 , '','', 2 )
		      +[App].[fnAddString] (28 , t.Cuenta_Abono,'', 2 )
			  +[App].[fnAddString] (19 , t.Cuenta_costo,'', 2 )
			  +[App].[fnAddString] (18 , t.Cuenta_depto,'', 2 )
			  +[App].[fnAddString] (9 , t.Cuenta_contable,'', 2 )
			  +[App].[fnAddString] (17,
				RIGHT('                 ' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(17), ISNULL (  t.total , 0 ) ) ), '.','' ) ) ) , 17  )
				,''
				, 0 )
              +[App].[fnAddString] (5 ,'','', 2 )
			  +[App].[fnAddString] (36 , t.UUID,'', 2 )
			  +'    '
			  +[App].[fnAddString] (14 , t.Rfc,'', 2 )
			  
		  FROM #tempDataDetalle t
        WHERE  (ISNULL (t.Cuenta_Abono , '' ) <> '')



/*	if object_id('tempdb..#Datos') is not null drop table #Datos;   
		create table #Datos(Respuesta nvarchar(max)); 
		insert into #Datos(Respuesta)
		SELECT 
		      CASE WHEN (ISNULL (t.Cuenta_Cargo , '' ) <> '') THEN
						1
					END 
		 FROM #tempData t
        WHERE  (ISNULL (t.Cuenta_Abono , '' ) <> '') or (ISNULL (t.Cuenta_Cargo , '' ) <> '')
		*/

    SELECT Respuesta FROM #Abono
			union all      
    SELECT Respuesta FROM #Cargo
			union all      
    SELECT Respuesta FROM #AbonoDetalle
		


GO
