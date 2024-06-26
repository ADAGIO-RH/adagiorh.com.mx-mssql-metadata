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
	CREATE PROC [Reportes].[spPolizaContableHGP](    
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

		--select @FechaIni

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

		
		if object_id('tempdb..#polizaRespuest') is not null        
			drop table #polizaPercepciones 


	SELECT   Conceptos.CuentaAbono
			,Conceptos.CuentaCargo 
			,Conceptos.Codigo as CodigoConcepto
			,Conceptos.Descripcion as ConceptoDescripcion
			,tiposConceptos.Descripcion as tiposConceptosDescripcion
			,Sucursales.IDSucursal
			,Sucursales.Codigo as CodigoSucursal
			,Sucursales.CuentaContable CuentaContableSucursal
			,CentroCostos.Codigo as CodigoCentroCosto
			,CentroCostos.CuentaContable as CuentaContableCentroCosto
			,SUM(isnull(detallePeriodo.ImporteTotal1,0)) as Total
			,Periodo.General
			,Periodo.Finiquito
			,Periodo.Especial
			,ORDEN = CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION' THEN 1
						  WHEN tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' THEN 2 
						  WHEN tiposConceptos.Descripcion = 'DEDUCCION' THEN 3 
						  WHEN tiposConceptos.Descripcion = 'INFORMATIVO' THEN 4
						  WHEN tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO' THEN 5
						  ELSE 0
						  END
		
		into #tempData
	FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo 
				on detallePeriodo.IDPeriodo = periodo.IDPeriodo -- PERIODO
			INNER JOIN @empleados Empleados 
				on Empleados.IdEmpleado = detallePeriodo.IdEmpleado	--EMPLEADOS
			INNER JOIN rh.tblCatCentroCosto CentroCostos					
				on CentroCostos.IDCentroCosto = Empleados.IDCentroCosto   --CENTROS DE COSTO
			INNER JOIN Nomina.tblCatConceptos Conceptos 
				on Conceptos.IDConcepto = detallePeriodo.IdConcepto --CONCEPTOS
			INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos		
				on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto --TIPOS DE CONCEPTOS
			INNER JOIN RH.tblCatSucursales Sucursales
				on Sucursales.IDSucursal = Empleados.IDSucursal --SUCURSALES
		WHERE 
			( tiposConceptos.Descripcion IN ('PERCEPCION','OTROS TIPOS DE PAGOS','DEDUCCION')
					OR Conceptos.Codigo IN ('507','508','509','510','530','540','601','602','604','605') )
				AND detallePeriodo.ImporteTotal1 <> 0
		GROUP BY
			CentroCostos.Codigo,
			Conceptos.Codigo,
			CentroCostos.CuentaContable,
			Sucursales.CuentaContable,
			Sucursales.IDSucursal,
			Sucursales.Codigo,
			Periodo.General,
			Periodo.Finiquito,
			Periodo.Especial,
			Conceptos.Descripcion,
			Conceptos.CuentaCargo,
			Conceptos.CuentaAbono,
			tiposConceptos.Descripcion
	

		insert into #tempData
		select 
			 CuentaAbono = ''
			,CuentaCargo 
			,CodigoConcepto
			,ConceptoDescripcion
			,tiposConceptosDescripcion
			,IDSucursal
			,CodigoSucursal
			,CuentaContableSucursal
			,CodigoCentroCosto
			,CuentaContableCentroCosto
			,Total
			,General
			,Finiquito
			,Especial
			,ORDEN = 4
		from #tempData
		where CodigoConcepto in  ('507','508','509','510','530','540')
		ORDER BY CodigoCentroCosto,CodigoConcepto
		--select * from #tempData
		--SELECT * FROM #tempData

		SELECT 
			[App].[fnAddString]( 2 , ISNULL    ( '29',''),' ',2 ) +
			CASE WHEN LEN ( CuentaAbono ) = 13 THEN
				CASE WHEN CodigoConcepto IN ('308','309','318','313','316','317','328','604','605') THEN --ES PARA DEJARLO IGUALITO A LA CUENTA ABONO
																				   --VALIDAR QUE 313, 317 Y 316 SOLO SEAN DE VALLARTA
					[App].[fnAddString]( 13 , ISNULL    ( CuentaAbono ,''),' ',2 ) 
				ELSE
					CASE WHEN CodigoConcepto IN ('320','321') THEN
						--ENTRA EN CASO DE PRESTAMO DE CAJA DE AHORRO    Y   CAJA DE AHORRO
						[App].[fnAddString]( 7 , ISNULL    (  SUBSTRING (CuentaAbono, 1,7 ) ,''),' ',2 ) +
						--[App].[fnAddString]( 3 , ISNULL    (  SUBSTRING (Conceptos.CuentaAbono, 5,7 ) ,''),'', 2 ) +
						CASE WHEN IDSucursal IN (1,2)  THEN --GUADALAJARA
							[App].[fnAddString]( 3 , ISNULL    (  '509' ,''),'',2 ) 
						ELSE
							[App].[fnAddString]( 3 , ISNULL    (  '511' ,''),'',2 ) 
						END +
						[App].[fnAddString]( 3 , ISNULL    (  SUBSTRING (CuentaAbono, 11,13 ) ,''),'',2 ) 
					ELSE
						CASE WHEN CodigoConcepto IN ('314') THEN
							--ENTRA EN CASO DE PRESTAMO DE CAJA DE AHORRO    Y   CAJA DE AHORRO
							[App].[fnAddString]( 7 , ISNULL    (  SUBSTRING (CuentaAbono, 1,7 ) ,''),' ',2 ) +
							--[App].[fnAddString]( 3 , ISNULL    (  SUBSTRING (Conceptos.CuentaAbono, 5,7 ) ,''),'', 2 ) +
							CASE WHEN IDSucursal IN (1,2)  THEN --GUADALAJARA
								[App].[fnAddString]( 3 , ISNULL    (  '507' ,''),'',2 )
							ELSE
								[App].[fnAddString]( 3 , ISNULL    (  '512' ,''),'',2 ) 
							END +
							[App].[fnAddString]( 3 , ISNULL    (  SUBSTRING (CuentaAbono, 11,13 ) ,''),'',2 ) 
						ELSE
							[App].[fnAddString]( 4 , ISNULL    (  SUBSTRING (CuentaAbono, 1,4 ) ,''),' ',2 ) +
							[App].[fnAddString]( 3 , ISNULL    (  CuentaContableSucursal ,''),'',2 ) +
							[App].[fnAddString]( 6 , ISNULL    (  SUBSTRING (CuentaAbono, 8,13 ) ,''),'',2 ) 
						END
					END
				END
			ELSE
			
				CASE WHEN LEN ( CuentaCargo ) = 13 THEN 
						--ENTRA EN EL SUBISIDIO Y POSIBLE PTU
						[App].[fnAddString]( 4 , ISNULL    (  SUBSTRING (CuentaCargo, 1,4 ) ,''),' ',2 ) +
						[App].[fnAddString]( 3 , ISNULL    (  CuentaContableSucursal ,''),'',2 ) +
						[App].[fnAddString]( 6 , ISNULL    (  SUBSTRING (CuentaCargo, 8,13 ) ,''),'',2 ) 
				ELSE
					--INICIA CENTRO COSTO CTA CONTABLE
					[App].[fnAddString]( 4 , ISNULL    ( CuentaContableCentroCosto ,''),' ',2 ) +
					--TERMINA CENTRO COSTO CTA CONTABLE

					--INICIA SUC CTA CONTABLE
					[App].[fnAddString]( 3 , ISNULL    ( CuentaContableSucursal ,''),' ',2 ) +
					--INICIA SUC CTA CONTABLE

					--INICIA EL HARDCORE 1 ( INICIA EN LA COLUMNA 10 )
					
                    ----------CELINA REPORTO QUE ESTO NO DEBERIA SER ASI REVISAR ATT JAVIER PEÑA RESPALDO
                    -- CASE WHEN CodigoConcepto = '130' THEN 
					-- 	[App].[fnAddString]( 3 , ISNULL    ( '001' ,''),' ',2 ) 
					-- ELSE
					-- 	[App].[fnAddString]( 3 , ISNULL    ( CuentaCargo ,''),' ',2 ) 
					-- END +
					--TERMINA EL HARDCORE 1 ( TERMINA EN LA COLUMNA 12 )
                    ----------CELINA REPORTO QUE ESTO NO DEBERIA SER ASI REVISAR ATT JAVIER PEÑA RESPALDO

                        --INICIA EL HARDCORE 1 ( INICIA EN LA COLUMNA 10 )
					
                    --------CELINA REPORTO QUE ESTO NO DEBERIA SER ASI REVISAR ATT JAVIER PEÑA
                    ----SE ELIMINA VALIDACION DE AGUINALDO 
						[App].[fnAddString]( 3 , ISNULL    ( CuentaCargo ,''),' ',2 ) 
					+
					----TERMINA EL HARDCORE 1 ( TERMINA EN LA COLUMNA 12 )
                    --------CELINA REPORTO QUE ESTO NO DEBERIA SER ASI REVISAR ATT JAVIER PEÑA



					--INICIA EL HARDCORE 2 ( INICIA EN LA COLUMNA 13 )
					[App].[fnAddString]( 3 , ISNULL    ( '000' ,''),' ',2 ) 
					--TERMINA EL HARDCORE 2 ( TERMINA EN LA COLUMNA 15 )4
				END

			END +

			[App].[fnAddString]( 6 , convert(varchar, @FechaIni,12),'',2) +
			CASE WHEN General = 1 THEN [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'NOMIN',''),1,5) ,' ',2) 
				 WHEN Finiquito = 1 then [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'FINIQ',''),1,5) ,' ',2) 
				 WHEN Especial = 1 then [App].[fnAddString]( 5 , SUBSTRING (ISNULL ( 'ESPEC',''),1,5) ,' ',2) 
			END +
			[App].[fnAddString](35 , ISNULL(ConceptoDescripcion,' '),' ',  2 ) +
			
			--INICIA EL MONTO FINAL
			CASE WHEN  tiposConceptosDescripcion = 'PERCEPCION' THEN
				[App].[fnAddString](1 , ISNULL    ( '0' ,''),'',1 ) +
				[App].[fnAddString](15 , REPLACE (ISNULL (  Total ,0 ),'.','' ),'0',  1 ) 
			ELSE
				CASE WHEN tiposConceptosDescripcion = 'DEDUCCION' THEN
					[App].[fnAddString](1 , ISNULL    ( '1' ,''),'',1 ) +
					[App].[fnAddString](15 , REPLACE (ISNULL ( Total  ,0 ),'.','' ),'0',  1 ) 
				ELSE
					--DEFAULT PARA QUE NO NULLE
					CASE WHEN ( CodigoConcepto IN ('507','508','509','510','530','540') AND ( CuentaAbono = '' )) OR CodigoConcepto = '180' THEN
						[App].[fnAddString](1 , ISNULL    ( '0' ,''),'',1 )
					ELSE
						[App].[fnAddString](1 , ISNULL    ( '1' ,''),'',1 )
					END +
						[App].[fnAddString](15 , REPLACE (ISNULL (  Total  ,0 ),'.','' ),'0',  1 ) 
				END
			END
			--TERMINA EL MONTO FINAL
		FROM #tempData
		ORDER BY CodigoCentroCosto,ORDEN



GO
