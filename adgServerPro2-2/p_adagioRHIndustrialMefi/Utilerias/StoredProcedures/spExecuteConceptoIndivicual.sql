USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec Nomina.spBuscarCatTipoNomina
--select * from Nomina.tblCatTipoNomina

--select * from Nomina.tblCatPeriodos
--where IDTipoNomina = 4


CREATE proc [Utilerias].[spExecuteConceptoIndivicual] as
--exec [Nomina].[spCalculoNomina]  1,19,2

--ALTER PROC [Nomina].[spCalculoNomina] (
--    @IDUsuario int 
--   ,@IDTipoNomina int 
--   ,@IDPeriodo int = 0,
--	@dtFiltros [Nomina].[dtFiltrosRH] READONLY
--)
--as

--select * from Nomina.tblCatPeriodos where ClavePeriodo = '001_04_1952'
--where IDTipoNomina = 4

--select * from Nomina.tblCatTipoNomina

--select * from rh.tblEmpleadosMaster where claveEmpleado = 'ADG0037'

declare 
	@IDUsuario int = 1
   ,@IDTipoNomina int = 4
   ,@IDPeriodo int = 83
   ,@dtFiltros [Nomina].[dtFiltrosRH] 
   , @i int = 0 
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
   ,@isPreviewFiniquito bit=0 

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

   insert into @dtFiltros(Catalogo,Value)
   Select 'Empleados','390'

   /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */
 	if(isnull(@isPreviewFiniquito,0) = 0 )
	BEGIN             
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros  , @IDUsuario = @IDUsuario                
	END
	ELSE
	BEGIN
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario
	END 

  -- select * from @empleados

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

	--select * from @Conceptos order by OrdenCalculo

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


   --select * from @DetallePeriodo
   --where IDConcepto = 370

-- TODO: Set parameter values here.

EXECUTE[Nomina].[spConcepto_304A] 
   @dtconfigs = @configs
  ,@dtempleados = @Empleados
  ,@dtConceptos = @Conceptos
  ,@dtPeriodo = @Periodo
  ,@dtDetallePeriodo = @DetallePeriodo
GO
