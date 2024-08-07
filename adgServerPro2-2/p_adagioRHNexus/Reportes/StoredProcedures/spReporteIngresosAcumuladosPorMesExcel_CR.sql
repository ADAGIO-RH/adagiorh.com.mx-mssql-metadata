USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: REPORTE DE INGRESOS ACUMULADOS POR MES EXCEL 
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2022-08-08


HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Reportes].[spReporteIngresosAcumuladosPorMesExcel_CR](
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
        ,@IDCliente int
		,@fechaIniPeriodo  date
		,@fechaFinPeriodo  date
        ,@IDConceptoRD122 INT --Reembolso
        ,@IDConceptoRD120 INT --Vacaciones
		,@Afectar Varchar(10) = 'FALSE'
		 ,@IDPeriodoInicial int
		  ,@IDConceptoAguinaldo int



	;

    SELECT @IDConceptoRD122=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD122'
    SELECT @IDConceptoRD120=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD120'
	select top 1 @IDConceptoAguinaldo = IDConcepto from Nomina.tblCatConceptos where Codigo = 'CR103' -- AGUINALDO

    

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int)
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
							 then (Select top 1 cast(item as int)
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0
	END
    SET @IDCliente = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
						else 0 
    END                    
	
	SET @IDPeriodoInicial = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
					  else 0  
					END  
	/* Se buscan el periodo seleccionado */
	insert into @periodo
	select *
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
		and (IDMes between (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			and (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
		)
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))
		))
    	and isnull(Cerrado,0) = 1

	select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */
    insert into @empleados                  
	exec [RH].[spBuscarEmpleados]  @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	DECLARE
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

		  
	
			if object_id('tempdb..#TempDatosAfectar') is not null
				drop table #TempDatosAfectar

	SELECT
			IDEmpleado AS [IDEmpleado]
			,ClaveEmpleado AS [CLAVE]
	        ,NOMBRECOMPLETO AS [NOMBRE COMPLETO]
            ,TipoNomina as [TIPO DE NOMINA]
			,CentroCosto AS [CENTRO DE COSTO]
			,FORMAT(FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,isnull([ENERO],0) as ENERO
			,isnull([FEBRERO],0) as FEBRERO
			,isnull([MARZO],0) as MARZO
			,isnull([ABRIL],0) as ABRIL
			,isnull([MAYO],0) as MAYO
			,isnull([JUNIO],0) as JUNIO
			,isnull([JULIO],0) as JULIO
			,isnull([AGOSTO],0) as AGOSTO
			,isnull([SEPTIEMBRE],0) as SEPTIEMBRE
			,isnull([OCTUBRE],0) as OCTUBRE
			,isnull([NOVIEMBRE],0) as NOVIEMBRE
			,isnull([DICIEMBRE],0) as DICIEMBRE
			,isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0)  + isnull([ABRIL],0)		+ isnull([MAYO],0)    +
			 isnull([JUNIO],0) + isnull([JULIO],0)	 + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0)  + isnull([OCTUBRE],0) +
			 isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL
		into #TempDatosAfectar
		from (
	    			select
					 e.IDEmpleado
					,e.ClaveEmpleado
					,e.NOMBRECOMPLETO
                    ,e.CentroCosto
                    ,e.TipoNomina
                    ,e.FechaAntiguedad
					,m.Nombre as Mes
					,SUM(isnull(dp.ImporteTotal1,0)) as Total
			
				from Nomina.tblDetallePeriodo dp with (nolock)
					inner join @periodo P on dp.IDPeriodo = P.IDPeriodo
					inner join (select
									ccc.*
									,tc.Descripcion as TipoConcepto
									,crr.Orden
								from Nomina.tblCatConceptos ccc with (nolock)
									inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto and tc.IDTipoConcepto=1
									inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
                                    Where CCC.IDConcepto NOT IN(
                                        @IDConceptoRD122--Reembolso
                                        ,@IDConceptoRD120--Vacaciones
                                    )---Conceptos que no son ingresos para dominicana
								) c on c.IDConcepto = dp.IDConcepto
					inner join Utilerias.tblMeses m with (nolock) on P.IDMes = m.IDMes
					inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
				
                Group by e.ClaveEmpleado,e.IDEmpleado,e.NOMBRECOMPLETO,e.TipoNomina,e.CentroCosto,e.FechaAntiguedad,m.Nombre
            ) x
            pivot
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p 

		SELECT 
		*
			FROM #TempDatosAfectar d ORDER BY d.CLAVE ASC
			

			IF(@Afectar = 'TRUE')
	BEGIN
		MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempDatosAfectar AS SOURCE
			ON TARGET.IDPeriodo = @IDPeriodoInicial
				and TARGET.IDConcepto = @IDConceptoAguinaldo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.[TOTAL] ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
			isnull(SOURCE.[TOTAL] ,0)
			)
		;
	END


                
GO
