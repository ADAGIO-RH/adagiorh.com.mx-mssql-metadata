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
	CREATE PROC [Reportes].[spPolizaContableProvisionesAvilab](    
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

		if object_id('tempdb..#polizaProvisiones') is not null        
			drop table #polizaProvisiones 

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
		INTO #polizaProvisiones
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
			AND Conceptos.CuentaCargo is not null
							 

		if object_id('tempdb..#polizaTotalesGenerales') is not null        
			drop table #polizaTotalesGenerales

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
			INTO #polizaTotalesGenerales
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
							tiposConceptos.Descripcion = 'INFORMATIVO'
							AND Conceptos.CuentaAbono is not null
							and Conceptos.Codigo<>'518'

				--SELECT Codigo, SUM(importeTotal1) FROM #polizaTotalesGenerales GROUP BY Codigo ORDER BY Codigo

				--RETURN

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
					FROM #polizaProvisiones Provisiones
						where Provisiones.IDDepartamento = @MyField -- JOIN PARA DEPARTAMENTOS
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
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Provisiones.CuentaContable,' '),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , SUBSTRING (ISNULL ( Provisiones.CuentaContable,' '),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , ISNULL ( Provisiones.CuentaCargo , ' ' ) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString](10 , ISNULL(Provisiones.Codigo,' ') ,' ',  2 ) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Provisiones.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( Provisiones.ImporteTotal1 ) ,0 ) ,' ',  2 )
							FROM #polizaProvisiones Provisiones						
						WHERE 
						   (Provisiones.IDDepartamento = @MyField) -- WHERE PARA DEPARTAMENTOS
						   GROUP BY 
							Provisiones.IDDepartamento,
							Provisiones.Codigo,
							Provisiones.Descripcion,
							Provisiones.CuentaContable,
							Provisiones.CuentaCargo,
							Provisiones.Codigo,
							Provisiones.Descripcion,
							Provisiones.General
							
					Insert Into #TempTable
					SELECT top 1			
							concat('           Total de Empleados : ', count( Provisiones.IdEmpleado))
						FROM #polizaProvisiones Provisiones						
						WHERE 
						   (Provisiones.IDDepartamento = @MyField) -- WHERE PARA DEPARTAMENTOS
						   GROUP BY 
							Provisiones.IDDepartamento,
							Provisiones.Codigo,
							Provisiones.Descripcion,
							Provisiones.CuentaContable,
							Provisiones.CuentaCargo,
							Provisiones.Codigo,
							Provisiones.Descripcion
								
					INSERT INTO #TempTable
					(cadena)
					VALUES
					('    TOTALES GENERALES              --------------------')
								
					END
									
						/*Termina el ciclo*/
						

						FETCH NEXT FROM @MyCursor 
						INTO @MyField 
					END; 

					CLOSE @MyCursor ;
					DEALLOCATE @MyCursor;
				END;

				INSERT INTO #TempTable      --Totales Generales de Provisiones
						SELECT 
							[App].[fnAddString]( 3 , Substring(ISNULL ( Generales.CuentaAbono , ' ' ),1,3) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 2 , Substring(ISNULL ( Generales.CuentaAbono , ' ' ),4,5) ,' ',2) +
							[App].[fnAddString]( 1 , '-' , ' ' ,2) +
							[App].[fnAddString]( 4 , Substring(ISNULL ( Generales.CuentaAbono , ' ' ),6,9) ,' ',2) +
							[App].[fnAddString]( 6 , ' ',' ',2 ) +
							[App].[fnAddString]( 4 ,ISNULL ( Generales.Codigo, ' ' ) ,' ',2) +
							[App].[fnAddString]( 4 , ' ',' ',2 ) +
							[App].[fnAddString](25 , ISNULL(Generales.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 2 , ' ',' ',2 ) +
							[App].[fnAddString](40 , ISNULL ( SUM ( Generales.ImporteTotal1 ) ,0 ) ,' ',  2 )
			
						FROM 
							#polizaTotalesGenerales Generales
						GROUP BY 
						Generales.CuentaAbono
						,Generales.Codigo
						,Generales.Descripcion
								

					INSERT INTO #TempTable
					(cadena)
					VALUES
					('')
					,('')


					Insert Into #TempTable
					SELECT 												
					concat('                       TOTAL CARGOS: ',ISNULL ( SUM ( Provisiones.ImporteTotal1 ) ,0 ))	
				FROM 
					#polizaProvisiones Provisiones



					INSERT INTO #TempTable
					SELECT 							
						concat('                       TOTAL ABONOS: ',ISNULL ( SUM ( Generales.ImporteTotal1 ) ,0 ))
					FROM 
						#polizaTotalesGenerales Generales


			Insert Into #TempTable
					SELECT			
							concat('           Total de Empleados : ', count(distinct t1.IdEmpleado) )
						FROM 	 
						(select * from #polizaTotalesGenerales
						union
						select * from #polizaProvisiones) t1
							

				select * from #TempTable

		
GO
