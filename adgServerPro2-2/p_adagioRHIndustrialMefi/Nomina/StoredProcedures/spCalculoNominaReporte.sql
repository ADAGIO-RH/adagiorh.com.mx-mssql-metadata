USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Nomina].[spCalculoNominaReporte]  1,37

CREATE PROC [Nomina].[spCalculoNominaReporte] (
    @IDUsuario int 
   ,@IDTipoNomina int 
   ,@IDPeriodo int = 0,
	@dtEmpleados Varchar(MAX) = null
)
as

	raiserror('Este SP está deprecated',16,1)
declare 
    @i int = 0 
   ,@IDPeriodoSeleccionado int=0
   ,@periodo [Nomina].[dtPeriodos]
   ,@configs [Nomina].[dtConfiguracionNomina]
   ,@empleados [RH].[dtEmpleados]
   ,@Conceptos [Nomina].[dtConceptos]
   ,@DetallePeriodo [Nomina].[dtDetallePeriodo]
   ,@spConcepto nvarchar(255)
   ,@IDConcepto int = 0
   ,@CodigoConcepto varchar(20)
   ,@fechaIniPeriodo  date
   ,@fechaFinPeriodo  date
   ,@dtFiltros [Nomina].[dtFiltrosRH]

   /* Estos conceptos no serán considerados por el proceso que ejecuta los stored procedured de la 
      formula de cada concepto */
   ,@ConceptosExcluidos varchar(1000) = '500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,303,519';

   if object_id('tempdb..#tempDetallePeriodo') is not null
	   drop table #tempDetallePeriodo;

    CREATE table #tempDetallePeriodo (
	   [IDDetallePeriodo] [int] NULL,
	   [IDEmpleado] [int] NOT NULL,
	   [IDPeriodo] [int] NOT NULL,
	   [IDConcepto] [int] NOT NULL,
	   [CantidadMonto] [decimal](18, 4)  NULL default 0,
	   [CantidadDias] [decimal](18, 4)	  NULL default 0,
	   [CantidadVeces] [decimal](18, 4)  NULL default 0,
	   [CantidadOtro1] [decimal](18, 4)  NULL default 0,
	   [CantidadOtro2] [decimal](18, 4)  NULL default 0,
	   [ImporteGravado] [decimal](18, 4) NULL default 0,
	   [ImporteExcento] [decimal](18, 4) NULL default 0,
	   [ImporteOtro] [decimal](18, 4)	  NULL default 0,
	   [ImporteTotal1] [decimal](18, 4)  NULL default 0,
	   [ImporteTotal2] [decimal](18, 4)  NULL default 0,
	   [Descripcion] [Varchar](255) COLLATE DATABASE_DEFAULT NULL,
	   [IDReferencia] int null
	   );

   /* Se busca el ID de periodo seleccionado del tipo de nómina */
  
  /*@dtFiltros*/

  if(isnull(@dtEmpleados,'')<>'')
  BEGIN
    insert into @dtFiltros(Catalogo,Value)
	values('Empleados',case when @dtEmpleados is null then '' else @dtEmpleados end)
  END




   IF(isnull(@IDPeriodo,0)=0)
   BEGIN	
	   select @IDPeriodoSeleccionado = IDPeriodo
	   from Nomina.tblCatTipoNomina
	   where IDTipoNomina=@IDTipoNomina
   END
   ELSE
   BEGIN
		set @IDPeriodoSeleccionado = @IDPeriodo
   END

   /* Se buscar toda la información del periodo seleccionado y se guarda en @periodo*/
   Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)
   select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado
   from Nomina.TblCatPeriodos
   where IDPeriodo = @IDPeriodoSeleccionado

   select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago
   from Nomina.TblCatPeriodos
   where IDPeriodo = @IDPeriodoSeleccionado

   /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */
   insert into @empleados
   exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin=	@fechaFinPeriodo, @dtFiltros = @dtFiltros

   /* Se carga la configuración de la nómina */
   insert into @configs
   select 
    Configuracion
	,Valor
	,TipoDato
	,Descripcion 
   from Nomina.tblConfiguracionNomina

   /* Se buscan todos los conceptos activos para el cálculo excluyendo los código que está en la lista @ConceptosExcluidos*/
   insert into @Conceptos
   select * 
   from Nomina.tblCatConceptos 
   where Estatus = 1 
    and codigo not in (select Item from App.split(@ConceptosExcluidos,','))


   /* Se carga el detalle del periodo al momento del cálculos (Capturas de nóminia y/o montos previamente calculados) */
   insert into @DetallePeriodo(IDDetallePeriodo,IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1
				    ,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,[IDReferencia])
   select detallePeriodo.IDDetallePeriodo,detallePeriodo.IDEmpleado,detallePeriodo.IDPeriodo,detallePeriodo.IDConcepto,detallePeriodo.CantidadMonto
		  ,detallePeriodo.CantidadDias,detallePeriodo.CantidadVeces,detallePeriodo.CantidadOtro1,detallePeriodo.CantidadOtro2,detallePeriodo.ImporteGravado
		  ,detallePeriodo.ImporteExcento,detallePeriodo.ImporteOtro,detallePeriodo.ImporteTotal1,detallePeriodo.ImporteTotal2,detallePeriodo.Descripcion,[IDReferencia]
   from Nomina.tblDetallePeriodo detallePeriodo with (nolock)
	   JOIN @empleados e 
		  on detallePeriodo.IDEmpleado = e.IDEmpleado
   where detallePeriodo.IDPeriodo=@IDPeriodoSeleccionado

   select @i=min(OrdenCalculo) from @Conceptos; 
  
   /* Se recorren todos los conceptos y se ejecuta su respectivo Stored procedure
      pasandole los debidos parámetros */   
   while exists(select 1 from @Conceptos where OrdenCalculo >= @i) 
    begin 
	   select @spConcepto=NombreProcedure
		  ,@IDConcepto=IDConcepto
		  ,@CodigoConcepto=Codigo
	   from @Conceptos where OrdenCalculo=@i; 
		
	   --select @spConcepto

	  INSERT INTO #tempDetallePeriodo(IDDetallePeriodo,IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1
				    ,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,[IDReferencia])	  
	  exec sp_executesql N'exec @miSP @dtconfigs,@dtempleados,@dtConceptos,@dtPeriodo,@dtDetallePeriodo' 
						  ,N' @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
							    ,@dtempleados [RH].[dtEmpleados] READONLY 
							    ,@dtConceptos [Nomina].[dtConceptos] READONLY 
							    ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
							    ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY
							    ,@miSP varchar(255)',								
							     @dtconfigs =@configs
							    ,@dtempleados =@empleados
							    ,@dtConceptos = @Conceptos
							    ,@dtPeriodo = @periodo
							    ,@dtDetallePeriodo =@DetallePeriodo
							    ,@miSP = @spConcepto	;						    				    



	if (@CodigoConcepto = '302')    
	begin
	   MERGE @DetallePeriodo AS TARGET
		  USING #tempDetallePeriodo AS SOURCE
			 ON TARGET.IDConcepto = SOURCE.IDConcepto 
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDPeriodo = SOURCE.IDPeriodo
				and ISNULL(TARGET.Descripcion,'') = ISNULL(SOURCE.Descripcion,'')
	   WHEN MATCHED Then
		  update
			 Set 				
				 TARGET.CantidadMonto  = SOURCE.CantidadMonto
				,TARGET.CantidadDias   = SOURCE.CantidadDias
				,TARGET.CantidadVeces  = SOURCE.CantidadVeces
				,TARGET.CantidadOtro1  = SOURCE.CantidadOtro1
				,TARGET.CantidadOtro2  = SOURCE.CantidadOtro2
				,TARGET.ImporteGravado = SOURCE.ImporteGravado
				,TARGET.ImporteExcento = SOURCE.ImporteExcento
				,TARGET.ImporteOtro	   = SOURCE.ImporteOtro
				,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1
				,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2
				,TARGET.Descripcion  = SOURCE.Descripcion
				,TARGET.IDReferencia    = SOURCE.IDReferencia
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto
				      ,SOURCE.CantidadMonto,SOURCE.CantidadDias,SOURCE.CantidadVeces,SOURCE.CantidadOtro1,SOURCE.CantidadOtro2
					 ,SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteOtro,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2,SOURCE.Descripcion,SOURCE.IDReferencia)
			WHEN NOT MATCHED BY SOURCE and TARGET.IDConcepto in (select c.IDConcepto from Nomina.tblCatConceptos c where c.Codigo in (select item from App.split(@ConceptosExcluidos,',')) or TARGET.IDConcepto = @IDConcepto) THEN 
			DELETE;
	end else
	begin  
	   MERGE @DetallePeriodo AS TARGET
		  USING #tempDetallePeriodo AS SOURCE
			 ON (TARGET.IDConcepto = SOURCE.IDConcepto 
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDPeriodo = SOURCE.IDPeriodo
				and ISNULL(TARGET.Descripcion,'') = ISNULL(SOURCE.Descripcion,'')
				and ISNULL(TARGET.IDReferencia, 0) = ISNULL(SOURCE.IDReferencia,0))
	   WHEN MATCHED  Then
		  update
			 Set 				
				 TARGET.CantidadMonto  = SOURCE.CantidadMonto
				,TARGET.CantidadDias   = SOURCE.CantidadDias
				,TARGET.CantidadVeces  = SOURCE.CantidadVeces
				,TARGET.CantidadOtro1  = SOURCE.CantidadOtro1
				,TARGET.CantidadOtro2  = SOURCE.CantidadOtro2
				,TARGET.ImporteGravado = SOURCE.ImporteGravado
				,TARGET.ImporteExcento = SOURCE.ImporteExcento
				,TARGET.ImporteOtro	   = SOURCE.ImporteOtro
				,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1
				,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2
				,TARGET.Descripcion  = SOURCE.Descripcion
				,TARGET.IDReferencia    = SOURCE.IDReferencia
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto
				      ,SOURCE.CantidadMonto,SOURCE.CantidadDias,SOURCE.CantidadVeces,SOURCE.CantidadOtro1,SOURCE.CantidadOtro2
					 ,SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteOtro,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2,SOURCE.Descripcion, SOURCE.IDReferencia)
			WHEN NOT MATCHED BY SOURCE and TARGET.IDConcepto = @IDConcepto THEN 
			DELETE;
	   end;
	   
	   delete from #tempDetallePeriodo;

	   select @i=min(OrdenCalculo) from @Conceptos where OrdenCalculo > @i; 
    end;   
	   MERGE Nomina.tblDetallePeriodo AS TARGET
		  USING @DetallePeriodo AS SOURCE
			 ON (TARGET.IDConcepto = SOURCE.IDConcepto 
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDPeriodo = SOURCE.IDPeriodo
				and ISNULL(TARGET.Descripcion,'') = ISNULL(SOURCE.Descripcion,'')
				and ISNULL(TARGET.IDReferencia, 0) = ISNULL(SOURCE.IDReferencia,0) )
	   WHEN MATCHED Then
		  update
			 Set 				
				 TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)
				,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)
				,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)
				,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)
				,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)
				,TARGET.ImporteGravado = isnull(SOURCE.ImporteGravado,0)
				,TARGET.ImporteExcento = isnull(SOURCE.ImporteExcento,0)
				,TARGET.ImporteOtro	   = isnull(SOURCE.ImporteOtro   ,0)
				,TARGET.ImporteTotal1  = isnull(SOURCE.ImporteTotal1 ,0)
				,TARGET.ImporteTotal2  = isnull(SOURCE.ImporteTotal2 ,0)
				,TARGET.Descripcion  = SOURCE.Descripcion
				,TARGET.IDReferencia  = SOURCE.IDReferencia
			 
	   WHEN NOT MATCHED BY TARGET THEN 
		  INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
		  VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto
				,isnull(SOURCE.CantidadMonto	,0)
				,isnull(SOURCE.CantidadDias	,0)
				,isnull(SOURCE.CantidadVeces	,0)
				,isnull(SOURCE.CantidadOtro1	,0)
				,isnull(SOURCE.CantidadOtro2	,0)
				,isnull(SOURCE.ImporteGravado,0)
				,isnull(SOURCE.ImporteExcento,0)
				,isnull(SOURCE.ImporteOtro	,0)
				,isnull(SOURCE.ImporteTotal1	,0)
				,isnull(SOURCE.ImporteTotal2	,0)
				,SOURCE.Descripcion
				,SOURCE.IDReferencia)
	   WHEN NOT MATCHED BY SOURCE and TARGET.IDPeriodo = @IDPeriodoSeleccionado and TARGET.IDEmpleado in (Select IDEmpleado from @Empleados) THEN 
	   DELETE;

   if object_id('tempdb..#tempSumatoriaPeriodo') is not null
    drop table #tempSumatoriaPeriodo;

	   CREATE table #tempSumatoriaPeriodo (
	
	   [IDPeriodo] [int] NOT NULL,
	   [Periodo] [Varchar](MAX) NOT NULL,
	   [IDConcepto] [int] NOT NULL,
	   [Codigo] [Varchar](MAX) NOT NULL,
	   [Concepto] [Varchar](MAX) NOT NULL,
	   [IDTipoConcepto] [int] NOT NULL,
	   [OrdenCalculo] [int] NOT NULL,
	   [Descripcion] [Varchar](MAX) NULL,
	   [CantidadMonto] [decimal](18, 4)  NULL default 0,
	   [CantidadDias] [decimal](18, 4)	  NULL default 0,
	   [CantidadVeces] [decimal](18, 4)  NULL default 0,
	   [CantidadOtro1] [decimal](18, 4)  NULL default 0,
	   [CantidadOtro2] [decimal](18, 4)  NULL default 0,
	   [ImporteGravado] [decimal](18, 4) NULL default 0,
	   [ImporteExcento] [decimal](18, 4) NULL default 0,
	   [ImporteOtro] [decimal](18, 4)	  NULL default 0,
	   [ImporteTotal1] [decimal](18, 4)  NULL default 0,
	   [ImporteTotal2] [decimal](18, 4)  NULL default 0,
	   [ImporteAcumuladoTotales] [decimal](18, 4)  NULL default 0,
	   );


   INSERT INTO #tempSumatoriaPeriodo
   select dp.IDPeriodo
	   ,cp.Descripcion as Periodo
	   ,dp.IDConcepto
	   ,ccp.Codigo
	   ,ccp.Descripcion as Concepto
	   ,ccp.IDTipoConcepto
	   ,ccp.OrdenCalculo
	   ,dp.Descripcion
	   ,SUM(dp.CantidadMonto) as CantidadMonto
	   ,SUM(dp.CantidadDias) as CantidadDias
	   ,SUM(dp.CantidadVeces) as CantidadVeces
	   ,SUM(dp.CantidadOtro1) as CantidadOtro1
	   ,SUM(dp.CantidadOtro2) as CantidadOtro2
	   ,SUM(dp.ImporteGravado) as ImporteGravado
	   ,SUM(dp.ImporteExcento) as ImporteExcento
	   ,SUM(dp.ImporteOtro) as ImporteOtro
	   ,SUM(dp.ImporteTotal1) as ImporteTotal1
	   ,SUM(dp.ImporteTotal2) ImporteTotal2	   
	   ,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales
   from [Nomina].[tblDetallePeriodo] dp with (nolock)
    join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo
    join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto   
	join @empleados e on dp.IDEmpleado = e.IDEmpleado
   where cp.IDPeriodo = @IDPeriodoSeleccionado
   group by  dp.IDPeriodo
		  ,cp.Descripcion 
		  ,dp.IDConcepto
		  ,ccp.Codigo
		  ,ccp.Descripcion
		  ,ccp.IDTipoConcepto
		  ,ccp.OrdenCalculo
		  ,dp.Descripcion

   select 
	    dp.IDDetallePeriodo
	   ,dp.IDEmpleado
	   ,dp.IDPeriodo
	   ,cp.Descripcion as Periodo
	   ,dp.IDConcepto
	   ,ccp.Codigo
	   ,Concepto = case when dp.Descripcion is not null then ccp.Descripcion+'('+dp.Descripcion+')' else ccp.Descripcion end
	   ,ccp.IDTipoConcepto
	   ,dp.CantidadMonto
	   ,dp.CantidadDias
	   ,dp.CantidadVeces
	   ,dp.CantidadOtro1
	   ,dp.CantidadOtro2
	   ,dp.ImporteGravado
	   ,dp.ImporteExcento
	   ,dp.ImporteOtro
	   ,dp.ImporteTotal1
	   ,dp.ImporteTotal2	   
	   ,dp.ImporteAcumuladoTotales
	   ,dp.IDReferencia
   from [Nomina].[tblDetallePeriodo] dp with (nolock)
    join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo
    join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto
	join @empleados e on dp.IDEmpleado = e.IDEmpleado
   where cp.IDPeriodo = @IDPeriodoSeleccionado

   select 
   	    IDPeriodo
	   ,Periodo
	   ,IDConcepto
	   ,Codigo
	   ,Concepto = case when Descripcion is not null then Concepto+'('+Descripcion+')' else Concepto end
	   ,OrdenCalculo
	   ,IDTipoConcepto
	   ,CantidadMonto
	   ,CantidadDias
	   ,CantidadVeces
	   ,CantidadOtro1
	   ,CantidadOtro2
	   ,ImporteGravado
	   ,ImporteExcento
	   ,ImporteOtro
	   ,ImporteTotal1
	   ,ImporteTotal2	   
	   ,ImporteAcumuladoTotales
   from #tempSumatoriaPeriodo
   order by OrdenCalculo


   select COUNT(*)NoEmpleados from @empleados
GO
