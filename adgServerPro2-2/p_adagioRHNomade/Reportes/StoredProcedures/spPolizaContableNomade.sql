USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
		NO MOVER
		DIANA
		POLIZA DE NOMADE
		NO MOVER / QUITAR
	*/
	CREATE PROC [Reportes].[spPolizaContableNomade](    
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
			SUBSTRING (Periodo.ClavePeriodo,8,13) as ClavePeriodo,
			Periodo.FechaFinPago as FechaPago,
			CASE WHEN Periodo.General = 1 THEN 'NOM' 
					 ELSE 'FIN' end AS Tipoperiodo,
			SUBSTRING(Departamentos.Descripcion,1,3) AS NombreDepartamento,
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
			WHERE ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' OR tiposConceptos.Descripcion = 'INFORMATIVO') 
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
				SUBSTRING (Periodo.ClavePeriodo,8,13) as ClavePeriodo,
				Periodo.FechaFinPago as FechaPago,
				CASE WHEN Periodo.General = 1 THEN 'NOM' 
					 ELSE 'FIN' end AS Tipoperiodo,
				SUBSTRING(Departamentos.Descripcion,1,3) AS NombreDepartamento,
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
							(tiposConceptos.Descripcion = 'DEDUCCION' OR tiposConceptos.Descripcion = 'INFORMATIVO' OR tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO')
							AND Conceptos.CuentaAbono is not null

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
					p_adagioRHNomade.RH.tblCatDepartamentos
					/*Obtiene ID de departamenos para iterarlos en el ciclo.*/

					OPEN @MyCursor 
					FETCH NEXT FROM @MyCursor 
					INTO @MyField
					 
					WHILE @@FETCH_STATUS = 0
					BEGIN

					/*Inicia el ciclo*/

					--Comienza encabezado de pagina--
				/*	if(@divPaginas = 5)
					begin
						
						insert into #TempTable
						(cadena)
						values
							('')
							,([App].[fnAddString]( 2 , '29' ,' ',1))
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
					end;*/
					--Termina Encabezado de pagina--

					--Comienza Cuerpo de periodo --
					IF EXISTS (SELECT * 
					FROM #polizaPercepciones Percepciones
						where Percepciones.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
					) 
					BEGIN

					SET @divPaginas = @divPaginas + 1 

				/*	INSERT INTO #TempTable
					--(cadena)
					select
					('           Departamento      '+dp.Codigo+'        *****  '+dp.Descripcion)
				   from RH.tblCatDepartamentos dp
				   WHERE DP.IDDepartamento = @MyField*/

				 /*   INSERT INTO #TempTable
					(cadena)
					VALUES
					('')*/
				
					Insert Into #TempTable
					SELECT 					
							[App].[fnAddString]( 2 ,'29','',1) +
							[App].[fnAddString]( 7 , SUBSTRING (ISNULL ( Percepciones.CuentaContable,''),1,7) ,'',2) +
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Percepciones.CuentaCargo,''),1,3) ,' ',2) +
							[App].[fnAddString]( 3 , '000','',2 ) +
							[App].[fnAddString]( 9 , convert (varchar, Percepciones.FechaPago,12),'',2 ) +
							[App].[fnAddString]( 1 , ' ','',1 ) +
							[App].[fnAddString]( 4 , Percepciones.Tipoperiodo,' ',2 ) +
							[App].[fnAddString]( 7 , Percepciones.ClavePeriodo,' ',2) +
							[App].[fnAddString]( 4 , ISNULL(Percepciones.NombreDepartamento,'') ,' ',  2 ) +
							[App].[fnAddString]( 20 ,SUBSTRING (Percepciones.Descripcion,1,20),' ',2 ) +
							[App].[fnAddString]( 16 , replace (cast(ISNULL (SUM ( Percepciones.ImporteTotal1 ) ,0 ) as varchar(max)),'.','') ,'0',  1 )
							--[App].[fnAddString]( 16 ,               ISNULL (SUM ( Percepciones.ImporteTotal1 ) ,0 ) ,'0',  1 )
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
							Percepciones.General,
							percepciones.FechaPago,
							Percepciones.Tipoperiodo,
							Percepciones.ClavePeriodo,
							Percepciones.NombreDepartamento

			/*		Insert Into #TempTable
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
							Percepciones.Descripcion,
							Percepciones.FechaPago,
							Percepciones.Tipoperiodo,
							Percepciones.ClavePeriodo,
							Percepciones.NombreDepartamento
								
					INSERT INTO #TempTable
					(cadena)
					VALUES
					('                                   --------------------')
								*/
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
							[App].[fnAddString]( 2 ,'29','',1) +
							[App].[fnAddString]( 10 , SUBSTRING (ISNULL ( Deducciones.CuentaAbono,''),1,10) ,' ',2) +
							[App].[fnAddString]( 3 , '000','',2 ) +
							[App].[fnAddString]( 9 , convert (varchar, Deducciones.FechaPago,12),'',2 ) +
							[App].[fnAddString]( 1 , ' ','',1 ) +
							[App].[fnAddString]( 4 , Deducciones.Tipoperiodo,' ',2 ) +
							[App].[fnAddString]( 7 , Deducciones.ClavePeriodo,' ',2) +
							[App].[fnAddString](24 ,SUBSTRING (Deducciones.Descripcion,1,23),'',2 ) +
							[App].[fnAddString]( 1 , '1','',1 ) +
						  --[App].[fnAddString]( 16 , ISNULL ( SUM ( Deducciones.ImporteTotal1 ) ,0 ) ,'0',  1 )
							[App].[fnAddString]( 15 , replace (cast(ISNULL (SUM ( Deducciones.ImporteTotal1 ) ,0 ) as varchar(max)),'.','') ,'0',  1 )
			
						FROM 
							#polizaDeducciones Deducciones
						GROUP BY 
						 Deducciones.CuentaAbono
						,Deducciones.Codigo
						,Deducciones.Descripcion
						,Deducciones.FechaPago
						,Deducciones.Tipoperiodo
						,Deducciones.ClavePeriodo
								

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


			Insert Into #TempTable
					SELECT			
							concat('           Total de Empleados : ', count(distinct t1.IdEmpleado) )
						FROM 	 
						(select * from #polizaDeducciones
						union
						select * from #polizaPercepciones) t1
							

				select * from #TempTable
GO
