USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Config].[spGenerarConceptos]
as
--delete  Nomina.tblCatConceptos
--exec App.spBorrarProceduresDeConceptos
--select isnull(Max(OrdenCalculo)+1,1) from Nomina.tblCatConceptos
BEGIN /* Inserts Nomina.tblCatConceptos */
	BEGIN TRY
		BEGIN TRAN TransaccionCatConceptos
			if object_id('tempdb..#TempCatConceptos') is not null
				drop table #TempCatConceptos

			declare @i int = 0		
			,@Codigo				varchar(20)
			,@Descripcion			varchar(100)
			,@IDTipoConcepto		int
			,@Estatus				bit	
			,@IDFrecuenciaConcepto	int
			,@Impresion			bit	
			,@IDCalculo			int
			,@CuentaAbono			varchar(50)
			,@CuentaCargo			varchar(50)
			,@bCantidadMonto		bit
			,@bCantidadDias		bit
			,@bCantidadVeces		bit
			,@bCantidadOtro1		bit
			,@bCantidadOtro2		bit
			,@IDCodigoSAT			int 
			,@NombreProcedure		varchar(200)
 			,@OrdenCalculo			int

			create table #TempCatConceptos(
				[Codigo] [varchar](20) NOT NULL,
				[Descripcion] [varchar](100) NOT NULL,
				[IDTipoConcepto] [int] NOT NULL,
				[Estatus] [bit] NOT NULL DEFAULT ((1)),
				[IDFrecuenciaConcepto] [int] NOT NULL,
				[Impresion] [bit] NOT NULL DEFAULT ((0)),
				[IDCalculo] [int] NOT NULL,
				[CuentaAbono] [varchar](50) NULL,
				[CuentaCargo] [varchar](50) NULL,
				[bCantidadMonto] [bit] NOT NULL DEFAULT ((0)),
				[bCantidadDias] [bit] NOT NULL DEFAULT ((0)),
				[bCantidadVeces] [bit] NOT NULL DEFAULT ((0)),
				[bCantidadOtro1] [bit] NOT NULL DEFAULT ((0)),
				[bCantidadOtro2] [bit] NOT NULL DEFAULT ((0)),
				[IDCodigoSAT] [int] NULL,
				[NombreProcedure] [varchar](200) NULL,
				[OrdenCalculo] [int] NULL,
				[Row] int identity(1,1)
			)
			/*Agregar conceptos en este segmento*/
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'DVAC'
			--Descripcion
			,'DIAS DE VACACIONES'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,null
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'DVIG'
			--Descripcion
			,'DIAS DE VIGENCIA'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,null
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'01'
			--Descripcion
			,'SUELDO'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,'0875-0631-0001-0000'
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'02'
			--Descripcion
			,'DEV.FONDO AHORRO EMPRESA'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,'0875-0631-0001-0000'
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'03'
			--Descripcion
			,'COMISIONES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'05'
			--Descripcion
			,'DIAS PENDIENTES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'10'
			--Descripcion
			,'TIEMPO EXTRA DOBLE'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'11'
			--Descripcion
			,'TIEMPO EXTRA TRIPLE'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'12'
			--Descripcion
			,'DEV.FONDO AHORRO TRABAJADOR'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'13'
			--Descripcion
			,'GRATIFICACIONES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'16'
			--Descripcion
			,'COMPENSACIONES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'17'
			--Descripcion
			,'DÍAS FESTIVOS TRABAJADOS'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'18'
			--Descripcion
			,'DESCANSO TRABAJADO'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'19'
			--Descripcion
			,'PRIMA DOMINICAL'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'20'
			--Descripcion
			,'VACACIONES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,1
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'21'
			--Descripcion
			,'PRIMA VACACIONAL'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,0
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,1
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'29'
			--Descripcion
			,'OTRAS PERCEPCIONES'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'30'
			--Descripcion
			,'AGUINALDO'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'31'
			--Descripcion
			,'PTU'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'45'
			--Descripcion
			,'VALES DE DESPENSA'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null				
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'46'
			--Descripcion
			,'SUBSIDIO POR INCAPACIDAD'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,2
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'49'
			--Descripcion
			,'PREVISION SOCIAL'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'50'
			--Descripcion
			,'DEV FONDO DE AHORRO'
			--IDTipoConcepto
			,1
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'51'
			--Descripcion
			,'ISR'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'51A'
			--Descripcion
			,'SUBSIDIO AL EMPLEO PAGADO'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'51B'
			--Descripcion
			,'AJUSTE ISPT'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'52'
			--Descripcion
			,'IMSS'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'52A'
			--Descripcion
			,'IMSS CESANTIA Y VEJEZ'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'54'
			--Descripcion
			,'FONDO AHORRO EMPRESA'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'54A'
			--Descripcion
			,'FONDO AHORRO COLABORADOR'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'54B'
			--Descripcion
			,'FONDO AHORRO EMP/TRAB'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'56'
			--Descripcion
			,'CREDITO INFONAVIT'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'56A'
			--Descripcion
			,'AJUSTE INFONAVIT'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'57'
			--Descripcion
			,'FONACOT'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null	
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'5%IN'
			--Descripcion
			,'5% INFONAVIT PATRONAL'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'IMSSP'
			--Descripcion
			,'IMSS PATRONAL'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'CESA'
			--Descripcion
			,'CESANTIA Y VEJEZ'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'RETI'
			--Descripcion
			,'RETIRO'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'AGUI'
			--Descripcion
			,'PROVISION AGUINALDO'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'PANT'
			--Descripcion
			,'PRIMA DE ANTIGUEDAD'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'PVAC'
			--Descripcion
			,'PROVISION PRIMA VAC'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null		
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'THEX'
			--Descripcion
			,'ACUM H. EXTRAS DOB'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'IMP1'
			--Descripcion
			,'ISPT ART. 113 LISR'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'IMP2'
			--Descripcion
			,'ISPT ART. 86'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'IMP3'
			--Descripcion
			,'ISPT ART. 79'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'CRED'
			--Descripcion
			,'SUBSIDIO AL EMPLEO CALCULADO'
			--IDTipoConcepto
			,2
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'ISCA'
			--Descripcion
			,'FINIQUITOS EN EFECTIVO'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'PERC'
			--Descripcion
			,'TOTAL PERCEPCIONES'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'DEDU'
			--Descripcion
			,'TOTAL DEDUCCIONES'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'ISN'
			--Descripcion
			,'IMPUESTO SOBRE NÓMINA'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'CHEQ'
			--Descripcion
			,'NOMINA EN CHEQUE'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'FINI'
			--Descripcion
			,'FINIQUITOS EN CHEQUE'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			insert into #TempCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus,IDFrecuenciaConcepto,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo) 
			select 
			--Codigo
			'TOTA'
			--Descripcion
			,'NOMINA ELECTRONICA'
			--IDTipoConcepto
			,3
			--Estatus
			,1
			--IDFrecuenciaConcepto
			,1
			--Impresion
			,1
			--IDCalculo
			,1
			--CuentaAbono
			,null
			--CuentaCargo
			,NULL
			--bCantidadMonto
			,1
			--bCantidadDias
			,0
			--bCantidadVeces
			,0
			--bCantidadOtro1
			,0
			--bCantidadOtro2
			,0
			--IDCodigoSAT
			,null
			--NombreProcedure
			,null
			--OrdenCalculo			 
			,null
			/*Agregar conceptos en este segmento*/

			--select * from #TempCatConceptos
			select @i=min([Row]) from #TempCatConceptos
			while exists(select 1 from #TempCatConceptos where [Row]>=@i)
			begin
			 select 
			  @Codigo				= Codigo				
			 ,@Descripcion			= Descripcion			
			 ,@IDTipoConcepto		= IDTipoConcepto		
			 ,@Estatus			= Estatus				
			 ,@IDFrecuenciaConcepto	= IDFrecuenciaConcepto	
			 ,@Impresion			= Impresion			
			 ,@IDCalculo			= IDCalculo			
			 ,@CuentaAbono			= CuentaAbono			
			 ,@CuentaCargo			= CuentaCargo			
			 ,@bCantidadMonto		= bCantidadMonto		
			 ,@bCantidadDias		= bCantidadDias		
			 ,@bCantidadVeces		= bCantidadVeces		
			 ,@bCantidadOtro1		= bCantidadOtro1		
			 ,@bCantidadOtro2		= bCantidadOtro2		
			 ,@IDCodigoSAT			= IDCodigoSAT			
			 from #TempCatConceptos
			 where [Row] = @i

			 exec [Nomina].[spIUCatConceptos]
			   @IDConcepto =0 
			  ,@Codigo			 =@Codigo			
			  ,@Descripcion		 =@Descripcion		
			  ,@IDTipoConcepto		 =@IDTipoConcepto		
			  ,@Estatus			 =@Estatus			
			 -- ,@IDFrecuenciaConcepto	 =@IDFrecuenciaConcepto	
			  ,@Impresion			 =@Impresion			
			  ,@IDCalculo			 =@IDCalculo			
			  ,@CuentaAbono		 =@CuentaAbono		
			  ,@CuentaCargo		 =@CuentaCargo		
			  ,@bCantidadMonto		 =@bCantidadMonto		
			  ,@bCantidadDias		 =@bCantidadDias		
			  ,@bCantidadVeces		 =@bCantidadVeces		
			  ,@bCantidadOtro1		 =@bCantidadOtro1		
			  ,@bCantidadOtro2		 =@bCantidadOtro2		
			  ,@IDCodigoSAT		 =@IDCodigoSAT		
			  ,@NombreProcedure		 =null		
			  ,@OrdenCalculo		 =null		

    			 select @i=min([Row]) from #TempCatConceptos where [Row]>@i			 
			end;

		COMMIT TRAN TransaccionCatConceptos
	END TRY
	BEGIN CATCH
		  SELECT  
		  ERROR_NUMBER() AS ErrorNumber  
		  ,ERROR_SEVERITY() AS ErrorSeverity  
		  ,ERROR_STATE() AS ErrorState  
		  ,ERROR_PROCEDURE() AS ErrorProcedure  
		  ,ERROR_LINE() AS ErrorLine  
		  ,ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN TransaccionCatConceptos
	END CATCH
END;
GO
