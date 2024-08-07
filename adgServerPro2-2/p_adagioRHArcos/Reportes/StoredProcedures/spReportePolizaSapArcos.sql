USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SP IMPORTANTE
	NO MOVER
	SP IMPORTANTE
	ARTURO
*/

	CREATE PROC [Reportes].[spReportePolizaSapArcos](    
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
		,@RazonSocial int  = 0 
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

	

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		if object_id('tempdb..#Abono') is not null drop table #Abono;   

		create table #Abono(Respuesta nvarchar(max)); 

		insert into #Abono(Respuesta)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaAbono ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaAbono , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaAbono ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaAbono , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '1' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'DEDUCCION' 
				AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  
				AND ( ISNULL (Empleados.IDRegPatronal , 0 ) = @RazonSocial ) 
				)
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaAbono
	
 ---------------------------------------------------------------------------------------------------------
-- DEDUCCION - CARGO
-- Para que tome los conceptos DEDUCCION y que tengan una cuenta Cargo
-- los conceptos 313 y 314  deben de ir como cargo pero en negativo
----------------------------------------------------------------------------------------------------------
		if object_id('tempdb..#CargoDeduccion') is not null drop table #CargoDeduccion;   

		create table #CargoDeduccion(Respuesta nvarchar(max)); 

		insert into #CargoDeduccion(Respuesta)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaCargo ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaCargo , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaCargo ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaCargo , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '0' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 * -1), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'DEDUCCION' AND ( ISNULL (Conceptos.CuentaCargo , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( ISNULL (Empleados.IDRegPatronal , 0 ) = @RazonSocial ) 
				AND (Conceptos.Codigo in ('313','314')) -- no estoy seguro si deben de ir solo estos conceptos
				)
				
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaCargo
-----------------------------------------------------------------------------------------------------

		if object_id('tempdb..#Cargo') is not null drop table #Cargo;   

		create table #Cargo(Respuesta1 nvarchar(max)); 

		insert into #Cargo(Respuesta1)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaCargo ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaCargo , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaCargo ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaCargo , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '0' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'PERCEPCION' AND ( ISNULL (Conceptos.CuentaCargo , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( ISNULL ( Empleados.IDRegPatronal , 0 ) = @RazonSocial )  )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaCargo


		if object_id('tempdb..#CargoSubs') is not null drop table #CargoSubs;   

		create table #CargoSubs(Respuesta1 nvarchar(max)); 

		insert into #CargoSubs(Respuesta1)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaCargo ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaCargo , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaCargo ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaCargo , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '0' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' AND ( ISNULL (Conceptos.CuentaCargo , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( ISNULL ( Empleados.IDRegPatronal , 0 ) = @RazonSocial )  )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaCargo

----------------------------------------------
-- OTROS TIPOS DE PAGO  - ABONO
-- Para que tomen los conceptos tipo OTROS TIPOS DE PAGO que tengan CuentaAbono
-- por ejemplo el concepto 185
----------------------------------------------
		if object_id('tempdb..#AbonoOtrosTipodePago') is not null drop table #AbonoOtrosTipodePago;   

		create table #AbonoOtrosTipodePago(Respuesta1 nvarchar(max)); 

		insert into #AbonoOtrosTipodePago(Respuesta1)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaAbono ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaAbono , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaAbono ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaAbono , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '1' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( ISNULL ( Empleados.IDRegPatronal , 0 ) = @RazonSocial )  )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaAbono

----------------------------------------------

		if object_id('tempdb..#pago') is not null drop table #pago;   

		create table #pago(Respuesta nvarchar(max)); 

		insert into #pago(Respuesta)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaAbono ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaAbono , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaAbono ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaAbono , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '1' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO' AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( Empleados.IDRegPatronal = @RazonSocial ) )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaAbono

	if object_id('tempdb..#info1') is not null drop table #info1;   

		create table #info1(Respuesta nvarchar(max)); 

		insert into #info1(Respuesta)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaAbono ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaAbono , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaAbono ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaAbono , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '1' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'INFORMATIVO' AND ( ISNULL (Conceptos.CuentaAbono , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( Empleados.IDRegPatronal = @RazonSocial ) )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaAbono


if object_id('tempdb..#info2') is not null drop table #info2;   

		create table #info2(Respuesta nvarchar(max)); 

		insert into #info2(Respuesta)
		SELECT [App].[fnAddString] (2 , 29 , '0' , 1 )
			+[App].[fnAddString] (13 , 
				CASE WHEN ( LEN ( Conceptos.CuentaCargo ) < 13 ) THEN  
					ISNULL ( Departamentos.CuentaContable,'') + ISNULL ( Conceptos.CuentaCargo , '' ) -- OBLIGATORIO
				ELSE
					CASE WHEN ( LEN ( Conceptos.CuentaCargo ) = 13 ) THEN
						ISNULL ( Conceptos.CuentaCargo , '' ) 
					END
				END , '0' , 0 )
			+[App].[fnAddString] (6 , @diaPoliza , '0' , 0 )
			+[App].[fnAddString] (5 , '' , '' , 0 )
			+[App].[fnAddString] (35 , ISNULL (Conceptos.Descripcion,'') , '' , 0 ) -- OBLIGATORIO
			+[App].[fnAddString] (1 , '0' , '0', 0 )
			+[App].[fnAddString] (15,
				RIGHT('000000000000000' +  Ltrim( Rtrim(  REPLACE ( ( CONVERT ( varchar(15), ISNULL ( SUM ( detallePeriodo.ImporteTotal1 ), 0 ) ) ), '.','' ) ) ) , 15  )
				,'0'
				, 0 )
			+[App].[fnAddString] (1 , '' , '', 0 )
			--+[App].[fnAddString] (100,'   ' + Departamentos.Descripcion ,'',1 )  -- NO REQUERIDO
		FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
			INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
				INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatDepartamentos Departamentos on Departamentos.IDDepartamento = Empleados.IDDepartamento -- JOIN PARA DEPARTAMENTOS
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
		WHERE ( tiposConceptos.Descripcion = 'INFORMATIVO' AND ( ISNULL (Conceptos.CuentaCargo , '' ) <> '' )
			    AND ( isnull ( detallePeriodo.ImporteTotal1 , 0 ) <> 0 )  AND ( Empleados.IDRegPatronal = @RazonSocial ) )
		GROUP BY Departamentos.Descripcion,
				 Departamentos.CuentaContable,
				 Conceptos.Descripcion,
				 Conceptos.CuentaCargo


		SELECT Respuesta FROM #Abono
			union all      
		SELECT Respuesta1 FROM #Cargo
			union all
         SELECT Respuesta FROM #CargoDeduccion
			union all
		SELECT Respuesta FROM #pago
			union all
		SELECT Respuesta FROM #info1
			union all
		SELECT Respuesta FROM #info2
			union all
		SELECT Respuesta1 FROM #CargoSubs
		union all
		SELECT Respuesta1 FROM #AbonoOtrosTipodePago

		
GO
