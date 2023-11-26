USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Reportes.spConstanciaSueldoYSalarios(
	@FechaIni datetime
	,@FechaFin datetime
	,@Ejercicio int
	,@IDEmpleado int
)
as
	SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
  
	SET LANGUAGE 'Spanish';

	if object_id('tempdb..#tempInfoRepSueldoSalarios') is not null drop table #tempInfoRepSueldoSalarios;

	create table #tempInfoRepSueldoSalarios(
		ClaveEmpleado	varchar(20)
		,RFC				varchar(20)
		,CURP			varchar(20)
		,IMSS			varchar(20)
		,Nombre			varchar(50)
		,SegundoNombre	varchar(50)
		,Paterno			varchar(50)
		,Materno			varchar(50)

		,MesInicial varchar(10)
		,MesFinal varchar(10)
		,Ejercicio int

		--DATOS DEL TRABAJADOR O ASIMILADO A SALARIOS
		,AREA_GEOGRAFICA_DEL_SM CHAR(1) DEFAULT 'X'
		,SI_EL_PATRON_REALIZO_EL_CALCULO CHAR(1) DEFAULT 'X'
		,DEL_EJERCICIO_QUE_DECLARA CHAR(1) DEFAULT 'X'
		,CLAVE_ENTIDAD_FEDERATIVA_PRESTO_SERVICIOS VARCHAR(10) DEFAULT '23'
		,RFC_DEL_OTRO_PATRONE1 VARCHAR(20)
		,RFC_DEL_OTRO_PATRONE2 VARCHAR(20)
		,RFC_DEL_OTRO_PATRONE3 VARCHAR(20)

		-- OTROS DATOS INFORMATIVOS
		,MONTO_APORTACIONES_VOLUNTARIAS_EFECTUADAS DECIMAL(18,2) DEFAULT 0
		,MONTO_APORTACIONES_VOLUNTARIAS_DEDUCIBLES_A_TRABAJADORES_REALIZARAN_DECLARACION DECIMAL(18,2)  DEFAULT 0
		,INDIQUE_PATRON_APLICO_MONTO_APORTACIONES_VOLUNTARIAS_AL_CALCULO_IMPUESTO  CHAR(1) DEFAULT 'N'
	
		-- IMPUESTO SOBRE LA RENTA
		,ISR_A DECIMAL(18,2) DEFAULT 0
		,ISR_B DECIMAL(18,2) DEFAULT 0
		,ISR_C DECIMAL(18,2) DEFAULT 0
		,ISR_D DECIMAL(18,2) DEFAULT 0
		,ISR_E DECIMAL(18,2) DEFAULT 0
		,ISR_F DECIMAL(18,2) DEFAULT 0
		,ISR_G DECIMAL(18,2) DEFAULT 0
		,ISR_H DECIMAL(18,2) DEFAULT 0
		,ISR_I DECIMAL(18,2) DEFAULT 0
		,ISR_J DECIMAL(18,2) DEFAULT 0
		,ISR_K DECIMAL(18,2) DEFAULT 0
		,ISR_L DECIMAL(18,2) DEFAULT 0
		,ISR_M DECIMAL(18,2) DEFAULT 0
		,ISR_N DECIMAL(18,2) DEFAULT 0
		,ISR_O DECIMAL(18,2) DEFAULT 0
		,ISR_P DECIMAL(18,2) DEFAULT 0

		--PAGOS POR SEPARACIÓN
		,PXR_Q DECIMAL(18,2) DEFAULT 0
		,PXR_R DECIMAL(18,2) DEFAULT 0
		,PXR_S DECIMAL(18,2) DEFAULT 0
		,PXR_T DECIMAL(18,2) DEFAULT 0
		,PXR_U DECIMAL(18,2) DEFAULT 0
		,PXR_V DECIMAL(18,2) DEFAULT 0
		,PXR_W DECIMAL(18,2) DEFAULT 0
		,PXR_X DECIMAL(18,2) DEFAULT 0
		,PXR_Y DECIMAL(18,2) DEFAULT 0
		,PXR_Z DECIMAL(18,2) DEFAULT 0
		-- CONTINUACIÓN
		,PXR_a DECIMAL(18,2) DEFAULT 0
		,PXR_b DECIMAL(18,2) DEFAULT 0
		,PXR_c DECIMAL(18,2) DEFAULT 0
		,PXR_d DECIMAL(18,2) DEFAULT 0
		,PXR_e DECIMAL(18,2) DEFAULT 0
		,PXR_f DECIMAL(18,2) DEFAULT 0
		,PXR_g DECIMAL(18,2) DEFAULT 0
		,PXR_h DECIMAL(18,2) DEFAULT 0

		-- INGRESOS ASIMILADOS A SALARIOS (Sin incluir ( 3 ))
		,I_ASIMILADOS_i DECIMAL(18,2) DEFAULT 0
		,I_ASIMILADOS_j DECIMAL(18,2) DEFAULT 0

		-- INGRESOS EN ACCIONES O TÍTULOS VALOR QUE REPRESENTAN BIENES (Por ejercer la opción otorgada por el empleador)
		,I_ACCIONES_BIENES_k  DECIMAL(18,2) DEFAULT 0
		,I_ACCIONES_BIENES_i  DECIMAL(18,2) DEFAULT 0
		,I_ACCIONES_BIENES_m  DECIMAL(18,2) DEFAULT 0
		,I_ACCIONES_BIENES_n  DECIMAL(18,2) DEFAULT 0

		-- PAGOS DEL PATRÓN EFECTUADOS A SUS TRABAJADORES (Incluyendo ( 3 ))
		,SUELDOS_Y_SALARIOS_G							   DECIMAL(18,2) DEFAULT 0
		,SUELDOS_Y_SALARIOS_E							   DECIMAL(18,2) DEFAULT 0
		,GRATIFICACION_ANUAL_G							   DECIMAL(18,2) DEFAULT 0
		,GRATIFICACION_ANUAL_E							   DECIMAL(18,2) DEFAULT 0
		,VIATICOS_GASTOS_VIAJE_G						   DECIMAL(18,2) DEFAULT 0
		,VIATICOS_GASTOS_VIAJE_E						   DECIMAL(18,2) DEFAULT 0
		,TIEMPO_EXTRA_G									   DECIMAL(18,2) DEFAULT 0
		,TIEMPO_EXTRA_E									   DECIMAL(18,2) DEFAULT 0
		,PRIMA_VACACIONAL_G								   DECIMAL(18,2) DEFAULT 0
		,PRIMA_VACACIONAL_E								   DECIMAL(18,2) DEFAULT 0
		,PRIMA_DOMINICAL_G								   DECIMAL(18,2) DEFAULT 0
		,PRIMA_DOMINICAL_E								   DECIMAL(18,2) DEFAULT 0
		,PTU_G											   DECIMAL(18,2) DEFAULT 0
		,PTU_E											   DECIMAL(18,2) DEFAULT 0
		,REEMBOLSO_GASTOS_MÉDICOS_G						   DECIMAL(18,2) DEFAULT 0
		,REEMBOLSO_GASTOS_MÉDICOS_E						   DECIMAL(18,2) DEFAULT 0
		,FONDO_AHORRO_G									   DECIMAL(18,2) DEFAULT 0
		,FONDO_AHORRO_E									   DECIMAL(18,2) DEFAULT 0
		,CAJA_AHORRO_G									   DECIMAL(18,2) DEFAULT 0
		,CAJA_AHORRO_E									   DECIMAL(18,2) DEFAULT 0
		,VALES_DESPENSA_G								   DECIMAL(18,2) DEFAULT 0
		,VALES_DESPENSA_E								   DECIMAL(18,2) DEFAULT 0
		,AYUDA_GASTOS_FUNERAL_G							   DECIMAL(18,2) DEFAULT 0
		,AYUDA_GASTOS_FUNERAL_E							   DECIMAL(18,2) DEFAULT 0
		,CONTRIBUCIONES_CARGO_TRABAJADOR_PAGADAS_PATRON_G  DECIMAL(18,2) DEFAULT 0
		,CONTRIBUCIONES_CARGO_TRABAJADOR_PAGADAS_PATRON_E  DECIMAL(18,2) DEFAULT 0
		,PREMIOS_PUNTUALIDAD_G							   DECIMAL(18,2) DEFAULT 0
		,PREMIOS_PUNTUALIDAD_E							   DECIMAL(18,2) DEFAULT 0
		,PRIMA_SEGURO_VIDA_G							   DECIMAL(18,2) DEFAULT 0
		,PRIMA_SEGURO_VIDA_E							   DECIMAL(18,2) DEFAULT 0
		,SEGURO_GASTOS_MEDICOS_MAYORES_G				   DECIMAL(18,2) DEFAULT 0
		,SEGURO_GASTOS_MEDICOS_MAYORES_E				   DECIMAL(18,2) DEFAULT 0
		,VALES_RESTAURANTE_G							   DECIMAL(18,2) DEFAULT 0
		,VALES_RESTAURANTE_E							   DECIMAL(18,2) DEFAULT 0
		,VALES_GASOLINA_G								   DECIMAL(18,2) DEFAULT 0
		,VALES_GASOLINA_E								   DECIMAL(18,2) DEFAULT 0
		,VALES_ROPA_G									   DECIMAL(18,2) DEFAULT 0
		,VALES_ROPA_E									   DECIMAL(18,2) DEFAULT 0
		,AYUDA_RENTA_G									   DECIMAL(18,2) DEFAULT 0
		,AYUDA_RENTA_E									   DECIMAL(18,2) DEFAULT 0
		,AYUDA_ARTICULOS_ESCOLARES_G					   DECIMAL(18,2) DEFAULT 0
		,AYUDA_ARTICULOS_ESCOLARES_E					   DECIMAL(18,2) DEFAULT 0
		,AYUDA_ANTEOJOS_G								   DECIMAL(18,2) DEFAULT 0
		,AYUDA_ANTEOJOS_E								   DECIMAL(18,2) DEFAULT 0
		,AYUDA_TRANSPORTE_G								   DECIMAL(18,2) DEFAULT 0
		,AYUDA_TRANSPORTE_E								   DECIMAL(18,2) DEFAULT 0
		,CUOTAS_SINDICALES_PAGADAS_POR_PATRON_G			   DECIMAL(18,2) DEFAULT 0
		,CUOTAS_SINDICALES_PAGADAS_POR_PATRON_E			   DECIMAL(18,2) DEFAULT 0
		,SUBSIDIOS_POR_INCAPACIDAD_G					   DECIMAL(18,2) DEFAULT 0
		,SUBSIDIOS_POR_INCAPACIDAD_E					   DECIMAL(18,2) DEFAULT 0
		,BECAS_TRABAJADORES_Y_O_HIJOS_G					   DECIMAL(18,2) DEFAULT 0
		,BECAS_TRABAJADORES_Y_O_HIJOS_E					   DECIMAL(18,2) DEFAULT 0
		,PAGOS_EFECTUADOS_POR_OTROS_EMPLEADORES_23_G	   DECIMAL(18,2) DEFAULT 0
		,PAGOS_EFECTUADOS_POR_OTROS_EMPLEADORES_23_E	   DECIMAL(18,2) DEFAULT 0
		,OTROS_INGRESOS_POR_SALARIOS_G					   DECIMAL(18,2) DEFAULT 0
		,OTROS_INGRESOS_POR_SALARIOS_E					   DECIMAL(18,2) DEFAULT 0

		-- IMPUESTO SOBRE LA RENTA POR SUELDOS Y SALARIOS (SS = SUELDOS Y SALARIOS)
		,ISR_SS_Q1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_R1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_S1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_T1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_U1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_V1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_W1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_X1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_Y1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_Z1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_a1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_b1 DECIMAL(18,2) DEFAULT 0
		,ISR_SS_c1 DECIMAL(18,2) DEFAULT 0

		-- DATOS DEL RETENEDOR
		,RETENEDOR_RFC VARCHAR(20)
		,RETENEDOR_CURP VARCHAR(20)
		,RETENEDOR_NOMBRECOMPLETO_O_RZ VARCHAR(MAX) /* APELLIDO PATERNO, MATERNO Y NOMBRE(S) O DENOMINACIÓN O RAZÓN SOCIAL*/

		-- DATOS DEL REPRESENTANTE LEGAL
		,REPRESENTANTE_LEGAL_CURP VARCHAR(20)
		,REPRESENTANTE_LEGAL_NOMBRE VARCHAR(MAX) /*APELLIDO PATERNO,MATERNO Y NOMBRE(S)*/
	 )

	insert into #tempInfoRepSueldoSalarios(ClaveEmpleado 
		,RFC			 
		,CURP			 
		,IMSS			 
		,Nombre			 
		,SegundoNombre	 
		,Paterno		 
		,Materno
		,MesInicial
		,MesFinal
		,Ejercicio
		)
	select 
		 e.ClaveEmpleado	 
		,e.RFC			 
		,e.CURP			 
		,e.IMSS			 
		,e.Nombre			 
		,e.SegundoNombre	 
		,e.Paterno		 
		,e.Materno		 
		,case when datepart(MONTH,@FechaIni) >= 10 then  cast(datepart(MONTH,@FechaIni) as varchar(10)) else '0'+cast( datepart(MONTH,@FechaIni) as varchar(10)) end
		,case when datepart(MONTH,@FechaFin) >= 10 then  cast(datepart(MONTH,@FechaFin) as varchar(10)) else '0'+cast( datepart(MONTH,@FechaFin) as varchar(10)) end
		,@Ejercicio
	from rh.tblEmpleadosMaster e
	where IDEmpleado = @IDEmpleado

	select * from #tempInfoRepSueldoSalarios
GO
