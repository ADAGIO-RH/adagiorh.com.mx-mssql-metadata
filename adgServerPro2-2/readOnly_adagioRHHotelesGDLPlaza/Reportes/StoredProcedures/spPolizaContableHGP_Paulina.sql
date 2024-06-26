USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
		NO MOVER
		DIANA
		POLIZA DE HGP
		NO MOVER / QUITAR
	*/
	CREATE PROC [Reportes].[spPolizaContableHGP_Paulina](    
		 @dtFiltros Nomina.dtFiltrosRH readonly    
		,@IDUsuario int    
		,@Sucursales varchar(max)		= ''
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
		,@FechaIni Date
		,@RazonSocial int   
		,@periodoSeleccionado int

	
		set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
			THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
			else 0  
		END 
		SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))

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

        
		if object_id('tempdb..#tempData') is not null        
			drop table #tempData 

		if object_id('tempdb..#polizaPercepciones') is not null        
			drop table #polizaPercepciones 

		SELECT				
			CentroCostos.CuentaContable as CuentaCC,
			Sucursales.CuentaContable as CuentaSucursal,					
			Conceptos.CuentaCargo,
			Conceptos.CuentaAbono,
			Conceptos.Codigo,
			Conceptos.Descripcion,	
			Sucursales.IDSucursal,	
			CentroCostos.IDCentroCosto,						
			detallePeriodo.ImporteTotal1,
			Empleados.IDEmpleado,
			Periodo.Descripcion AS PERIODO,
			Periodo.General,
			Periodo.Finiquito,
			Periodo.Especial
		INTO #polizaPercepciones
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo 
				on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados 
				on Empleados.IdEmpleado = detallePeriodo.IdEmpleado		-- JOIN CONTRA EMPLEADOS
			INNER JOIN rh.tblCatCentroCosto CentroCostos					
				on CentroCostos.IDCentroCosto = Empleados.IDCentroCosto   --Join contra Centro de Costos
			INNER JOIN RH.tblCatSucursales Sucursales
				on Sucursales.IDSucursal = Empleados.IDSucursal --Join contra Sucursales
			INNER JOIN Nomina.tblCatConceptos Conceptos 
				on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
			INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
				on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
			WHERE ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS') 
			--AND Conceptos.CuentaCargo is not null
	
	--------------------------------------------------------------------------------------------------------------------						 

		if object_id('tempdb..#polizaDeducciones') is not null        
			drop table #polizaDeducciones

			SELECT				
				CentroCostos.CuentaContable as CuentaCC,
				Sucursales.CuentaContable as CuentaSucursal,					
				Conceptos.CuentaCargo,
				Conceptos.CuentaAbono,
				Conceptos.Codigo,
				Conceptos.Descripcion,	
				Sucursales.IDSucursal,	
				CentroCostos.IDCentroCosto,					
				detallePeriodo.ImporteTotal1,
				Empleados.IDEmpleado,
				Periodo.Descripcion AS PERIODO,
				Periodo.General,
				Periodo.Finiquito,
				Periodo.Especial
			INTO #polizaDeducciones
					FROM 
						Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
							INNER JOIN @periodo Periodo 
								on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
							INNER JOIN @empleados Empleados 
								on Empleados.IdEmpleado = detallePeriodo.IdEmpleado		-- JOIN CONTRA EMPLEADOS
							INNER JOIN rh.tblCatCentroCosto CentroCostos					
								on CentroCostos.IDCentroCosto = Empleados.IDCentroCosto   --Join contra Centro de Costos
							INNER JOIN RH.tblCatSucursales Sucursales
								on Sucursales.IDSucursal = Empleados.IDSucursal --Join contra Sucursales
							INNER JOIN Nomina.tblCatConceptos Conceptos 
								on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
								on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
					WHERE 
							tiposConceptos.Descripcion = 'DEDUCCION'
							--AND Conceptos.CuentaAbono is not null

	----------------------------------------------------------------------------------------------------------------------
	if object_id('tempdb..#polizaInformativos') is not null        
			drop table #polizaInformativos 

	SELECT				
		CentroCostos.CuentaContable as CuentaCC,
		Sucursales.CuentaContable as CuentaSucursal,					
		Conceptos.CuentaCargo as CuentaCargo,
		Conceptos.CuentaAbono,
		Conceptos.Codigo,
		Conceptos.Descripcion,	
		Sucursales.IDSucursal,	
		CentroCostos.IDCentroCosto,					
		detallePeriodo.ImporteTotal1,
		Empleados.IDEmpleado,
		Periodo.Descripcion AS PERIODO,
		Periodo.General,
		Periodo.Finiquito,
		Periodo.Especial
	INTO #polizaInformativos
	FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
							INNER JOIN @periodo Periodo 
								on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
							INNER JOIN @empleados Empleados 
								on Empleados.IdEmpleado = detallePeriodo.IdEmpleado		-- JOIN CONTRA EMPLEADOS
							INNER JOIN rh.tblCatCentroCosto CentroCostos					
								on CentroCostos.IDCentroCosto = Empleados.IDCentroCosto   --Join contra Centro de Costos
							INNER JOIN RH.tblCatSucursales Sucursales
								on Sucursales.IDSucursal = Empleados.IDSucursal --Join contra Sucursales
							INNER JOIN Nomina.tblCatConceptos Conceptos 
								on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos 
								on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
					WHERE 
							(tiposConceptos.Descripcion = 'INFORMATIVO'  
								and Conceptos.CuentaAbono <> '' 
									and Conceptos.CuentaCargo <> '' ) or (tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO'
										and Conceptos.CuentaAbono <> '' 
									 )
								

	-----------------------------------------------------------------------------------------------------------------------
				if object_id('tempdb..#TempTable') is not null        
							drop table #TempTable


				create table #TempTable
				(
					cadena Varchar(max)
				);

				DECLARE @MyCursor CURSOR;
				DECLARE @MyField int;
				BEGIN
					SET @MyCursor = CURSOR FOR
					select  IDCentroCosto from 
					p_adagioRHHotelesGDLPlaza.RH.tblCatCentroCosto
					/*Obtiene ID de Centro de Costos para iterarlos en el ciclo.*/

					OPEN @MyCursor 
					FETCH NEXT FROM @MyCursor 
					INTO @MyField
					 
					WHILE @@FETCH_STATUS = 0
					BEGIN

					/*Inicia el ciclo*/

					--Comienza Cuerpo de periodo --
					IF EXISTS (SELECT * 
					FROM #polizaPercepciones Percepciones
						where Percepciones.IDCentroCosto = @MyField -- JOIN PARA CENTRO DE COSTOS
					) 
					BEGIN

				/*	INSERT INTO #TempTable
					(cadena)
					select
					('           Centro de Costo      '+CenCos.Codigo+'        *****  '+CenCos.Descripcion)
				   from RH.tblCatCentroCosto CenCos
				   WHERE CenCos.IDCentroCosto = @MyField

				    INSERT INTO #TempTable
					(cadena)
					VALUES
					('')*/
				
					Insert Into #TempTable
					SELECT 					
							[App].[fnAddString]( 2 , ISNULL    ( '29',''),' ',2) +
							[App].[fnAddString]( 4 , SUBSTRING (ISNULL ( Percepciones.CuentaCC,''),1,4) ,' ',2) +
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Percepciones.CuentaSucursal,''),1,3) ,' ',2) +
							[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Percepciones.CuentaCargo , ''),1,3 ),' ',2) +
							[App].[fnAddString]( 3 , ISNULL    ( '000',''),'',2) +
							[App].[fnAddString]( 6 , convert(varchar, @FechaIni,12),'',2) +
							CASE WHEN Percepciones.General = 1 then
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'NOMIN',''),1,5) ,' ',2) 
								 WHEN Percepciones.Finiquito = 1 then 
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'FINIQ',''),1,5) ,' ',2) 
								WHEN Percepciones.Especial = 1 then
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'ESPEC',''),1,5) ,' ',2) 
							END +
							[App].[fnAddString](35 , ISNULL(Percepciones.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString](16 , REPLACE (ISNULL ( SUM ( Percepciones.ImporteTotal1 ) ,0 ),'.','' ),'0',  1 ) +
							[App].[fnAddString]( 1 , ISNULL    ( ' ',''),' ',2)
					FROM #polizaPercepciones Percepciones						
						WHERE 
						   (Percepciones.IDCentroCosto = @MyField) -- WHERE PARA CENTRO DE COSTOS
						GROUP BY 
							Percepciones.CuentaCC,
							Percepciones.CuentaSucursal,
							--Percepciones.IDCentroCosto,
							Percepciones.CuentaCargo,
							--Percepciones.Codigo,
							Percepciones.Descripcion,
							Percepciones.General,
							Percepciones.Finiquito,
							Percepciones.Especial
							
					--Insert Into #TempTable
					--SELECT top 1			
					--		concat('           Total de Empleados : ', count( Percepciones.IdEmpleado))
					--	FROM #polizaPercepciones Percepciones						
					--	WHERE 
					--	   (Percepciones.IDCentroCosto = @MyField) -- WHERE PARA CENTRO DE COSTOS
					--	   GROUP BY 
					--	   Percepciones.IDCentroCosto
					--	   /*Percepciones.IDSucursal
					--		Percepciones.Codigo,
					--		Percepciones.CuentaCC,
					--		Percepciones.CuentaSucursal,
					--		Percepciones.IDSucursal,
					--		Percepciones.Descripcion,
					--		Percepciones.CuentaCargo,
					--		Percepciones.Codigo,
					--		Percepciones.Descripcion*/
								
					/*INSERT INTO #TempTable
					(cadena)
					VALUES
					('                                   --------------------')*/
								
					END
									
						/*Termina el ciclo*/
						

						FETCH NEXT FROM @MyCursor 
						INTO @MyField 
					END; 

					CLOSE @MyCursor ;
					DEALLOCATE @MyCursor;
				END;

	-------------------------------------------------------------------------------------------------------------------------------------
				INSERT INTO #TempTable
						SELECT 
							[App].[fnAddString]( 2 , ISNULL    ( '29',''),' ',2) +
							case when len(Deducciones.CuentaAbono) = 13 then
								CASE WHEN Deducciones.Codigo = '308'  OR Deducciones.Codigo ='309' then --Fondo de Ahorro Empresa y Colaborador
										[App].[fnAddString] (13 ,isnull(Deducciones.CuentaAbono,''),' ',2)  
									 WHEN Deducciones.Codigo = '314' and (Deducciones.CuentaSucursal = '001' or Deducciones.CuentaSucursal = '002') THEN --CUOTA SINDICAL
										[App].[fnAddString] (7 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),1,7),' ',2) +
										[App].[fnAddString]( 3 , ISNULL ( '507',''),' ',2) +
										[App].[fnAddString] (3 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),11,13),' ',2) 
									WHEN (Deducciones.Codigo = '320' or Deducciones.Codigo = '321') and (Deducciones.CuentaSucursal = '001' or Deducciones.CuentaSucursal = '002') THEN --PRESTAMO CAJA DE AHORRO
										[App].[fnAddString] (7 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),1,7),' ',2) +
										[App].[fnAddString]( 3 , ISNULL ( '509',''),' ',2) +
										[App].[fnAddString] (3 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),11,13),' ',2) 
								ELSE
									[App].[fnAddString] (4 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),1,4),' ',2) +
									[App].[fnAddString]( 3 ,SUBSTRING (ISNULL (Deducciones.CuentaSucursal,''),1,3) ,' ',2) +
									[App].[fnAddString] (6 ,SUBSTRING (isnull(Deducciones.CuentaAbono,''),8,13),' ',2) 
								END
							ELSE
								[App].[fnAddString]( 4 , SUBSTRING (ISNULL ( Deducciones.CuentaCC,''),1,3) ,' ',2) +
								[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Deducciones.CuentaSucursal,''),1,3) ,' ',2) +
								[App].[fnAddString]( 3 , SUBSTRING (ISNULL ( Deducciones.CuentaAbono, ''),1,3 ),' ',2) +
								[App].[fnAddString]( 3 , ISNULL    ( '000',''),'',2) 
							END +
							[App].[fnAddString]( 6 , convert(varchar, @FechaIni,12),'',2)  +
							CASE WHEN Deducciones.General = 1 then
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'NOMIN',''),1,5) ,' ',2) 
								 WHEN Deducciones.Finiquito = 1 then 
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'FINIQ',''),1,5) ,' ',2) 
								 WHEN Deducciones.Especial = 1 then
									  [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'ESPEC',''),1,5) ,' ',2) 
							END +
							[App].[fnAddString](35 , ISNULL(Deducciones.Descripcion,' ') ,' ',  2 ) +
							[App].[fnAddString]( 1 , ISNULL    ( '1',''),' ',1) +
							[App].[fnAddString](15 , REPLACE (ISNULL ( SUM ( Deducciones.ImporteTotal1 ) ,0 ),'.','' ),'0',  1 ) 
							
			
						FROM 
							#polizaDeducciones Deducciones
					--	Where Deducciones.CuentaAbono <> ''
							GROUP BY 
								Deducciones.CuentaCC,
								Deducciones.CuentaSucursal,
								Deducciones.Codigo,
								--Deducciones.CuentaCargo,
								Deducciones.CuentaAbono,
								Deducciones.Descripcion,
								Deducciones.General,
								Deducciones.Finiquito,
								Deducciones.Especial

		--INSERT INTO #TempTable
		--			(cadena)
		--			VALUES
		--			('')
						
	------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO #TempTable
		SELECT 
				[App].[fnAddString]( 2 ,ISNULL    ( '29',''),' ',2) +
				[App].[fnAddString]( 4 ,ISNULL ( Informativos.CuentaCC,''),' ',2) +
				[App].[fnAddString]( 3 ,ISNULL ( Informativos.CuentaSucursal,''),' ',2) +
				[App].[fnAddString] (3 ,isnull(Informativos.CuentaCargo,''),' ',2)  +
				[App].[fnAddString]( 3 ,ISNULL( '000',''),' ',2) +
				[App].[fnAddString]( 6 ,convert(varchar, @FechaIni,12),'',2)  +
					CASE WHEN Informativos.General = 1 then
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'NOMIN',''),1,5) ,' ',2) 
						 WHEN Informativos.Finiquito = 1 then 
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'FINIQ',''),1,5) ,' ',2) 
						 WHEN Informativos.Especial = 1 then
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'ESPEC',''),1,5) ,' ',2) 
					END +
					[App].[fnAddString](35 , ISNULL(Informativos.Descripcion,' '),' ',  2 ) +
					[App].[fnAddString]( 1 , ISNULL    ( '0',''),' ',1) +
					[App].[fnAddString](15 , REPLACE (ISNULL ( SUM ( Informativos.ImporteTotal1 ) ,0 ),'.','' ),'0',  1 ) 
		FROM #polizaInformativos Informativos
		WHERE Informativos.Codigo NOT IN ('601','603')
		Group By 
			Informativos.CuentaCC,
			Informativos.CuentaSucursal,
			Informativos.Codigo,
			Informativos.CuentaCargo,
			Informativos.CuentaAbono,
			Informativos.Descripcion,
			Informativos.General,
			Informativos.Finiquito,
			Informativos.Especial
	


	INSERT INTO #TempTable
		SELECT 
				[App].[fnAddString]( 2 ,ISNULL    ( '29',''),' ',2) +
				CASE WHEN Informativos.Codigo in ('507', '508', '509','510','530','540','601','603') THEN
					[App].[fnAddString] (4 ,SUBSTRING (isnull(Informativos.CuentaAbono,''),1,4),' ',2)  +
					[App].[fnAddString]( 3 ,ISNULL ( Informativos.CuentaSucursal,''),' ',2) +
					[App].[fnAddString] (6 ,SUBSTRING (isnull(Informativos.CuentaAbono,''),8,13),' ',2)  

				ELSE 
					[App].[fnAddString] (13 ,isnull(Informativos.CuentaAbono,''),' ',2) 
				END +
					[App].[fnAddString]( 6 ,convert(varchar, @FechaIni,12),'',2)  +
					CASE WHEN Informativos.General = 1 then
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'NOMIN',''),1,5) ,' ',2) 
						 WHEN Informativos.Finiquito = 1 then 
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'FINIQ',''),1,5) ,' ',2) 
						 WHEN Informativos.Especial = 1 then
							[App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'ESPEC',''),1,5) ,' ',2) 
					END +
					[App].[fnAddString](35 , ISNULL(Informativos.Descripcion,' '),' ',  2 ) +
					[App].[fnAddString]( 1 , ISNULL    ( '1',''),' ',1) +
					[App].[fnAddString](15 , REPLACE (ISNULL ( SUM ( Informativos.ImporteTotal1 ) ,0 ),'.','' ),'0',  1 ) 
	
				--END 
		FROM #polizaInformativos Informativos
		Group By 
			Informativos.CuentaCC,
			Informativos.CuentaSucursal,
			Informativos.Codigo,
			Informativos.CuentaCargo,
			Informativos.CuentaAbono,
			Informativos.Descripcion,
			Informativos.General,
			Informativos.Finiquito,
			Informativos.Especial
	
	
	
	
	
	------------------------------------------------------------------------------------------------------------------------------------
								

				/*	INSERT INTO #TempTable
					(cadena)
					VALUES
					('')
					,('')*/


				/*	Insert Into #TempTable
					SELECT 												
					concat('                       TOTAL CARGOS: ',ISNULL ( SUM ( Percepciones.ImporteTotal1 ) ,0 ))	
				FROM 
					#polizaPercepciones Percepciones*/



				/*	INSERT INTO #TempTable
					SELECT 							
						concat('                       TOTAL ABONOS: ',ISNULL ( SUM ( Deducciones.ImporteTotal1 ) ,0 ))
					FROM 
						#polizaDeducciones Deducciones*/


		/*	Insert Into #TempTable
					SELECT			
							concat('           Total de Empleados : ', count(distinct t1.IdEmpleado) )
						FROM 	 
						(select * from #polizaDeducciones
						union
						select * from #polizaPercepciones) t1*/
							

				select * from #TempTable
GO
