USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
		NO MOVER
		DIANA
		POLIZA DE AVILAB
		NO MOVER / QUITAR
	*/
	create PROC [Reportes].[spPolizaContableAvilab_bk](    
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
	
		set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
			THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
			else 0  
		END 

		/* Se buscan el periodo seleccionado */    
		insert into @periodo  
		select   
			 IDPeriodo  
			,IDTipoNomina  
			,Ejercicio  
			,ClavePeriodo  
			,Descripcion  
			,FechaInicioPago  
			,FechaFinPago  
			,FechaInicioIncidencia  
			,FechaFinIncidencia  
			,Dias  
			,AnioInicio  
			,AnioFin  
			,MesInicio  
			,MesFin  
			,IDMes  
			,BimestreInicio  
			,BimestreFin  
			,Cerrado  
			,General  
			,Finiquito  
			,isnull(Especial,0)  
		from Nomina.tblCatPeriodos  
			where ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
				or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))       
		
		     
		select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  

		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
		insert into @empleados        
			exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

		if object_id('tempdb..#encabezado') is not null        
			drop table #encabezado

		if object_id('tempdb..#tempConceptos') is not null        
			drop table #tempConceptos   
  
       
		if object_id('tempdb..#tempData') is not null        
			drop table #tempData 

		if object_id('tempdb..#percepciones') is not null        
			drop table #percepciones 

		if object_id('tempdb..#deducciones') is not null        
			drop table #deducciones


				if object_id('tempdb..#TempTable') is not null        
							drop table #TempTable


				create table #TempTable
				(
					cadena Varchar(max)
				);

				DECLARE @divPaginas int = 5;
				DECLARE @numPaginas int = 1;
				DECLARE @MyCursor CURSOR;
				DECLARE @MyField int;
				BEGIN
					SET @MyCursor = CURSOR FOR
					select  IDDepartamento from 
					p_adagioRHAvilab.RH.tblCatDepartamentos
					/*Obtiene ID de departamenos para iterarlos en el ciclo.*/

					OPEN @MyCursor 
					FETCH NEXT FROM @MyCursor 
					INTO @MyField
					 
					WHILE @@FETCH_STATUS = 0
					BEGIN

					/*Inicia el ciclo*/

					--Comienza encabezado de pagina--
					if(@divPaginas = 5)
					begin
						
						insert into #TempTable
						(cadena)
						values
							('')
							,([App].[fnAddString]( 50 , 'AVILAB' ,' ',1))
							,((SELECT  
							[App].[fnAddString](10,'Poliza No ',' ',2) +
							[App].[fnAddString](11,SUBSTRING (ISNULL(p.ClavePeriodo,''), 12,14) , '' ,1) +
							[App].[fnAddString](10 , ' F' , ' ' ,2) +
							[App].[fnAddString]( 5 , 'Afe' , ' ' ,1) +
							[App].[fnAddString](47 , ISNULL (p.Descripcion,'') + ' ', ' ' ,1) +
							[App].[fnAddString](62 , ISNULL (p.ClavePeriodo,'') , ' ' ,2)
							FROM @periodo p))
							,((select [App].[fnAddString](100 , '','=',1)FROM @periodo p))						
							,((select[App].[fnAddString](52 , '- '+@numPaginas+' -' ,' ',1) + '                      'FROM @periodo p))
							,((select[App].[fnAddString](75 , GETDATE() ,' ',1)AS ENCABEZADO FROM @periodo p	))
						
						set @divPaginas = 0;
						SET @numPaginas = @numPaginas + 1
					end;
					--Termina Encabezado de pagina--
					--Comienza Cuerpo de periodo --
					IF EXISTS (SELECT * 
					FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento 
										and Departamentos.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
					) 
					BEGIN

					SET @divPaginas = @divPaginas + 1 

					   INSERT INTO #TempTable
					(cadena)
					select
					('           Departamento      '+dp.Codigo+'        *****  '+dp.Descripcion)
				   from RH.tblCatDepartamentos dp
				   WHERE DP.IDDepartamento = @MyField

				    INSERT INTO #TempTable
					(cadena)
					VALUES
					('')
				
					Insert Into #TempTable
					SELECT 					
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Departamentos.CuentaContable,' '),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , SUBSTRING (ISNULL ( Departamentos.CuentaContable,' '),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , ISNULL ( Conceptos.CuentaCargo , ' ' ) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString](10 , ISNULL(Conceptos.Codigo,' ') ,' ',  2 ) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Conceptos.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ) ,0 ) ,' ',  2 )
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento 
										and Departamentos.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
							( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS') and Conceptos.CuentaCargo is not null
							 
						GROUP BY 
								Empleados.IDDepartamento,
								Departamentos.Codigo,
								Conceptos.Descripcion,
								Departamentos.CuentaContable,
								Conceptos.CuentaCargo,
								Conceptos.Codigo,
								Periodo.Descripcion,
								Periodo.General

					Insert Into #TempTable
					SELECT top 1			
							concat('           Total de Empleados : ', count( Empleados.IdEmpleado))
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento 
										and Departamentos.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
							 tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'
							 
						GROUP BY 
								Empleados.IDDepartamento,
								Departamentos.Codigo,
								Conceptos.Descripcion,
								Departamentos.CuentaContable,
								Conceptos.CuentaCargo,
								Conceptos.Codigo,
								Periodo.Descripcion,
								Periodo.General
								
					INSERT INTO #TempTable
					(cadena)
					VALUES
					('                                   --------------------')

					

					
					END
					
					
						/*Termina el ciclo*/
						

						FETCH NEXT FROM @MyCursor 
						INTO @MyField 
					END; 

					CLOSE @MyCursor ;
					DEALLOCATE @MyCursor;
				END;

				INSERT INTO #TempTable
						SELECT 
							[App].[fnAddString]( 3 , Substring(ISNULL ( Conceptos.CuentaAbono , ' ' ),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , Substring(ISNULL ( Conceptos.CuentaAbono , ' ' ),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , Substring(ISNULL ( Conceptos.CuentaAbono , ' ' ),6,9) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString]( 4 ,ISNULL ( Conceptos.Codigo, ' ' ) ,' ',2) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Conceptos.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ) ,0 ) ,' ',  2 )
			
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento  -- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
							 tiposConceptos.Descripcion = 'DEDUCCION'
						GROUP BY 
						Conceptos.CuentaAbono
						,Conceptos.Codigo
						,Conceptos.Descripcion
								

								INSERT INTO #TempTable
					(cadena)
					VALUES
					('')
					,('')


								Insert Into #TempTable
					SELECT 					
							
							concat('                       TOTAL CARGOS: ',ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ) ,0 ))	
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento 	-- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
							 tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'							 



					INSERT INTO #TempTable
						SELECT 							
							concat('                       TOTAL ABONOS: ',ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ) ,0 ))
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento  -- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
							 tiposConceptos.Descripcion = 'DEDUCCION'



			Insert Into #TempTable
					SELECT			
							concat('           Total de Empleados : ', count(distinct Empleados.IdEmpleado) )
						FROM 	 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
							
											

		

				select * from #TempTable


				/*select temp.IDEmpleado, e.IDEmpleado, e.ClaveEmpleado, e.Nombre, e.Paterno
				from @empleados temp
				join Rh.tblEmpleados e on temp.IDEmpleado = e.IDEmpleado*/

				/*SELECT 
				 Departamentos.CuentaContable
				,Departamentos.IDDepartamento,
					Departamentos.Descripcion,
					'test'
							/*[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Departamentos.CuentaContable,' '),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , SUBSTRING (ISNULL ( Departamentos.CuentaContable,' '),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , ISNULL ( Conceptos.CuentaCargo , ' ' ) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString](10 , ISNULL(Conceptos.Codigo,' ') ,' ',  2 ) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Conceptos.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ) ,0 ) ,' ',  2 )*/
						FROM 
							Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
								INNER JOIN @periodo Periodo 
									on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
								INNER JOIN @empleados Empleados 
									on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
								INNER JOIN RH.tblCatDepartamentos Departamentos  
									on Departamentos.IDDepartamento = Empleados.IDDepartamento 
										and Departamentos.IDDepartamento = 4 -- JOIN PARA DEPARTAMENTOS
								INNER JOIN Nomina.tblCatConceptos Conceptos 
									on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
								INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
									on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
						WHERE 
						
							 tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'
							 
							 
						GROUP BY 
								Empleados.IDDepartamento,
								Departamentos.Codigo,
								Conceptos.Descripcion,
								Departamentos.CuentaContable,
								Conceptos.CuentaCargo,
								Conceptos.Codigo,
								Periodo.Descripcion,
								Periodo.General,
								Departamentos.IDDepartamento,
								Departamentos.Descripcion*/

		--SELECT 
		--	CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION'THEN 
		--		[Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaCargo , 2, 
		--			  SUBSTRING ( Conceptos.CuentaCargo  , CHARINDEX ('-' , Conceptos.CuentaCargo   +'-' ) + 1, LEN (Conceptos.CuentaCargo ) + 1 ) )

		--		 WHEN tiposConceptos.Descripcion = 'INFORMATIVO'THEN 
		--		 [Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaCargo , 2, 
		--			  SUBSTRING ( CentrosCostos.CuentaContable , CHARINDEX ('-' , CentrosCostos.CuentaContable +'-') + 1, LEN (CentrosCostos.CuentaContable) + 1 ) )

		--		 WHEN tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'THEN Conceptos.CuentaCargo
		--		 END AS CUENTA,
		--	CentrosCostos.Codigo as NORMA_REPARTO,
		--	ISNULL ( SUBSTRING(CentrosCostos.CuentaContable, 1 , CHARINDEX(' ', CentrosCostos.CuentaContable + ' ' ) -1) , 'SIN CUENTA' ) AS CCOSTO,
		--	--ISNULL ( CentrosCostos.Codigo, '' ) + ' ' + ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION , 
		--	ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION , 
		--	ISNULL ( Periodo.Descripcion,'') as NOMBRELARGO,
		--	Conceptos.Codigo AS IDCONCEPTO,
		--	Conceptos.Descripcion AS DESCRICPION_CONCEPTO ,
		--	CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION' THEN 'P' 
		--		 WHEN tiposConceptos.Descripcion = 'DEDUCCION' THEN 'D' 
		--		 ELSE 'C'
		--		 END AS TIPOCONCEPTO,
		--	SUM ( detallePeriodo.ImporteTotal1 ) AS DEBITO,
		--	0 AS CREDITO,
		--	periodo.ClavePeriodo as IDPERIODO,
		--	Ra.RFC as Subcontratante

		--INTO #percepciones
		--FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
		--	INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
		--		INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
		--			INNER JOIN #beneficiarios beneficiarios on  beneficiarios.IdEmpleado = Empleados.IdEmpleado -- JOIN PARA FILTRAR BENEFICIARIOS
		--				INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
		--					INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto -- JOIN PARA CENTROS DE COSTO
		--						INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		--							INNER JOIN RH.tblCatRazonesSociales Ra on Ra.IDRazonSocial = beneficiarios.IDRazonSocial
		--WHERE ( ( ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'
		--		OR ( tiposConceptos.Descripcion = 'INFORMATIVO' AND Conceptos.Codigo IN ( '508', '509', '510', '507','540' ,'530' ) ) ) AND
		--			( Conceptos.CuentaCargo <> '' OR Conceptos.CuentaCargo IS NOT NULL ) )
		--		AND detallePeriodo.Importetotal1 <> 0 )
		--GROUP BY tiposConceptos.Descripcion,
		--		 CentrosCostos.Codigo,
		--		 CentrosCostos.Descripcion,
		--		 CentrosCostos.CuentaContable,
		--		 Conceptos.CuentaCargo,
		--		 Empleados.CentroCosto, 
		--		 Conceptos.Descripcion, 
		--		 Conceptos.IDConcepto,
		--		 Conceptos.Codigo,
		--		 periodo.Descripcion,
		--		 periodo.ClavePeriodo,
		--		 Ra.RFC
		--ORDER BY  empleados.CentroCosto, Conceptos.IDConcepto
GO
