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
	CREATE PROC [Reportes].[spPolizaContableAvilab](    
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
		select   *
			-- IDPeriodo  
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

		if object_id('tempdb..#polizaPercepciones') is not null        
			drop table #polizaPercepciones 

		SELECT				
			Departamentos.CuentaContable,						
			Conceptos.CuentaCargo,
			Conceptos.Codigo,
			Conceptos.Descripcion,							
			detallePeriodo.ImporteTotal1,
			Departamentos.IDDepartamento,
			Empleados.IDEmpleado,
			Periodo.Descripcion AS PERIODO,
			Periodo.General
		INTO #polizaPercepciones
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo 
				on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados 
				on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
			INNER JOIN RH.tblCatDepartamentos Departamentos  
				on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
			INNER JOIN Nomina.tblCatConceptos Conceptos 
				on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
			INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
				on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
			WHERE ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS') 
			AND Conceptos.CuentaCargo is not null
							 

		if object_id('tempdb..#polizaDeducciones') is not null        
			drop table #polizaDeducciones

			SELECT 
				Departamentos.CuentaContable,						
				Conceptos.CuentaAbono,
				Conceptos.Codigo,
				Conceptos.Descripcion,							
				detallePeriodo.ImporteTotal1,
				Departamentos.IDDepartamento,
				Empleados.IDEmpleado,
				Periodo.Descripcion AS PERIODO,
				Periodo.General
			INTO #polizaDeducciones
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
							AND Conceptos.CuentaAbono is not null

				if object_id('tempdb..#polizaInformativos') is not null        
				drop table #polizaInformativos 

			SELECT				
				Conceptos.CuentaAbono,						
				Conceptos.CuentaCargo,
				Conceptos.Codigo,
				Conceptos.Descripcion,							
				detallePeriodo.ImporteTotal1,
				Departamentos.IDDepartamento,
				Empleados.IDEmpleado,
				Periodo.Descripcion AS PERIODO,
				Periodo.General
			INTO #polizaInformativos
			FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
				INNER JOIN @periodo Periodo 
					on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados 
					on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
				INNER JOIN RH.tblCatDepartamentos Departamentos  
					on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
				INNER JOIN Nomina.tblCatConceptos Conceptos 
					on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
				INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
					on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
				WHERE ( tiposConceptos.Descripcion = 'INFORMATIVO')
					and Conceptos.Codigo='518'
					--AND Conceptos.CuentaCargo is not null



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
					FROM #polizaPercepciones Percepciones
						where Percepciones.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
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
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Percepciones.CuentaContable,' '),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , SUBSTRING (ISNULL ( Percepciones.CuentaContable,' '),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , ISNULL ( Percepciones.CuentaCargo , ' ' ) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString](10 , ISNULL(Percepciones.Codigo,' ') ,' ',  2 ) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Percepciones.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( Percepciones.ImporteTotal1 ) ,0 ) ,' ',  2 )
							FROM #polizaPercepciones Percepciones						
						WHERE 
						   (Percepciones.IDDepartamento = @MyField) -- WHERE PARA DEPARTAMENTOS
						   GROUP BY 
							Percepciones.IDDepartamento,
							Percepciones.Codigo,
							Percepciones.Descripcion,
							Percepciones.CuentaContable,
							Percepciones.CuentaCargo,
							Percepciones.Codigo,
							Percepciones.Descripcion,
							Percepciones.General
							
					Insert Into #TempTable
					SELECT top 1			
							concat('           Total de Empleados : ', count( Percepciones.IdEmpleado))
						FROM #polizaPercepciones Percepciones						
						WHERE 
						   (Percepciones.IDDepartamento = @MyField) -- WHERE PARA DEPARTAMENTOS
						   GROUP BY 
							Percepciones.IDDepartamento,
							Percepciones.Codigo,
							Percepciones.Descripcion,
							Percepciones.CuentaContable,
							Percepciones.CuentaCargo,
							Percepciones.Codigo,
							Percepciones.Descripcion
								
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
							[App].[fnAddString]( 3 , Substring(ISNULL ( Deducciones.CuentaAbono , ' ' ),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , Substring(ISNULL ( Deducciones.CuentaAbono , ' ' ),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , Substring(ISNULL ( Deducciones.CuentaAbono , ' ' ),6,9) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString]( 4 ,ISNULL ( Deducciones.Codigo, ' ' ) ,' ',2) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Deducciones.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( case when deducciones.Codigo='302' then ((SUM ( Deducciones.ImporteTotal1 ))-(select sum (ImporteTotal1) from #polizaInformativos group by CuentaAbono,Codigo,Descripcion)) else SUM ( Deducciones.ImporteTotal1 ) end,0 ) ,' ',  2 )	--doria solicito que cuando sea el concepto 302 le quite lo del concepto 518
			
						FROM 
							#polizaDeducciones Deducciones
						
						GROUP BY 
						Deducciones.CuentaAbono
						,Deducciones.Codigo
						,Deducciones.Descripcion
				

				insert into #TempTable
						SELECT 
							[App].[fnAddString]( 3 , Substring(ISNULL ( Informativos.CuentaAbono , ' ' ),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , Substring(ISNULL ( Informativos.CuentaAbono , ' ' ),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , Substring(ISNULL ( Informativos.CuentaAbono , ' ' ),6,9) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString]( 4 ,ISNULL ( Informativos.Codigo, ' ' ) ,' ',2) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Informativos.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( Informativos.ImporteTotal1 ) ,0 ) ,' ',  2 )
			
						FROM 
							#polizaInformativos Informativos
						GROUP BY 
						Informativos.CuentaAbono
						,Informativos.Codigo
						,Informativos.Descripcion
								
	

					INSERT INTO #TempTable
					(cadena)
					VALUES
					('')
					,('')


					Insert Into #TempTable
					SELECT 												
					concat('                       TOTAL CARGOS: ',ISNULL ( SUM ( Percepciones.ImporteTotal1 ) ,0 ))	
				FROM 
					#polizaPercepciones Percepciones



					INSERT INTO #TempTable
					SELECT 							
						concat('                       TOTAL ABONOS: ',ISNULL ( SUM ( Deducciones.ImporteTotal1 ) ,0 ))
					FROM 
						#polizaDeducciones Deducciones


					--INSERT INTO #TempTable
					--SELECT 							
					--	concat('                       TOTAL ABONOS: ',ISNULL ( SUM ( Informativos.ImporteTotal1 ) ,0 ))
					--FROM 
					--	#polizaInformativos Informativos


			Insert Into #TempTable
					SELECT			
							concat('           Total de Empleados : ', count(distinct t1.IdEmpleado) )
						FROM 	 
						(select * from #polizaDeducciones
						union
						select * from #polizaPercepciones
						union 
						select * from #polizaInformativos
						) t1
							

				select * from #TempTable

		
GO
