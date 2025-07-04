USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[Facturacion].[spCoreBuscarDetalleFolio] 75253
*/

CREATE PROCEDURE [Facturacion].[spCoreBuscarDetalleFolio] --70131
(      
	@IDHistorialEmpleadoPeriodo int      
)      
AS      
BEGIN      
      
	DECLARE       
		@Folio int,      
		@Fecha Datetime,      
		@ImporteGravado Decimal(21,2),      
		@SubTotal Decimal(21,2),      
		@Total Decimal(21,2),      
		@TotalDeducciones Decimal(21,2),      
		@ImporteExcento Decimal(21,2),      
		@TotalImpuestos Decimal(21,2),      
		@OtrasDeducciones Decimal(21,2),      
		@TotalOtrosPagos Decimal(21,2),      
		@dtFiltros [Nomina].[dtFiltrosRH] ,      
		@empleados [RH].[dtEmpleados],      
		@TotalSueldo Decimal(21,2),  
		@Indemnizacion bit = 0,
      
		@IDPeriodo int       
		,@IDTipoNomina int       
		,@Ejercicio int       
		,@ClavePeriodo varchar(20)       
		,@DescripcionPeriodo varchar(250)       
		,@FechaInicioPago date       
		,@FechaFinPago date       
		,@FechaInicioIncidencia date       
		,@FechaFinIncidencia date       
		,@Dias int       
		,@AnioInicio bit       
		,@AnioFin bit       
		,@MesInicio bit       
		,@MesFin bit       
		,@IDMes int       
		,@BimestreInicio bit       
		,@BimestreFin bit       
		,@General bit       
		,@Finiquito bit       
		,@Especial bit       
		,@Cerrado bit    
	;
      
	--PERIODO      
	select top 1       
		@IDPeriodo = p.IDPeriodo ,@IDTipoNomina= p.IDTipoNomina,@Ejercicio = p.Ejercicio,@ClavePeriodo = p.ClavePeriodo,@DescripcionPeriodo =  p.Descripcion       
		,@FechaInicioPago = p.FechaInicioPago,@FechaFinPago = p.FechaFinPago,@FechaInicioIncidencia = p.FechaInicioIncidencia,@FechaFinIncidencia=  p.FechaFinIncidencia       
		,@Dias = p.Dias,@AnioInicio = p.AnioInicio,@AnioFin = p.AnioFin,@MesInicio = p.MesInicio,@MesFin = p.MesFin       
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin       
		,@General = p.General,@Finiquito = p.Finiquito,@Especial = p.Especial,@Cerrado = p.Cerrado       
	from Nomina.tblCatPeriodos p with (nolock)     
		Inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with (nolock)      
			on P.IDPeriodo = HEP.IDPeriodo      
	Where HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
         
   --PERIODO      
      
   --FILTRO EMPLEADO      
      
	insert into @dtFiltros       
	select 'Empleados',Cast( IDEmpleado as Varchar(50))      
	from Nomina.tblHistorialesEmpleadosPeriodos with (nolock)      
	Where IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster] @FechaIni = @FechaInicioPago,@Fechafin = @FechaFinPago ,@dtFiltros = @dtFiltros ,@IDUsuario = 1     
    --FILTRO EMPLEADO      
        
	--CONFIGURACION TIMBRADO      
	SELECT HEP.IDHistorialEmpleadoPeriodo,      
		CE.Usuario,      
		CE.Password,      
		CE.PasswordKey,      
		--Pack.NombrePack,      
		E.RFC as RFCEmisor,    
		ISNULL(t.UUID,'') as UUID       
	FROM  Nomina.tblHistorialesEmpleadosPeriodos HEP with (nolock)      
		Left Join Facturacion.tblCatConfigEmpresa CE with (nolock)      
			on HEP.IDEmpresa = CE.IDEmpresa      
		--Left Join Facturacion.tblCatPacks Pack      
			-- on CE.IDPack = Pack.IDPack      
		LEFT Join RH.tblEmpresa E with (nolock)      
			on HEP.IDEmpresa = E.IDEmpresa    
		left join Facturacion.TblTimbrado t with (nolock)    
			on t.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo and t.Actual = 1      
	Where HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      

	--CONFIGURACION TIMBRADO      
	--FOLIOS Y TOTALES DE GRAVADO Y EXCENTO      

	select @Folio = @IDHistorialEmpleadoPeriodo     
		  ,@Fecha = getdate()  


	select 
		    
		@SubTotal = ROUND(SUM(DP.ImporteTotal1),2)      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		left join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		inner join Sat.tblCatTiposPercepciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion  in ('PERCEPCION')      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		--AND percepciones.Codigo not in ('022','023','025')      
		and DP.ImporteAcumuladoTotales <> 0      
	GROUP BY EP.IDHistorialEmpleadoPeriodo      
      
	select       
      @ImporteGravado =  SUM(DP.ImporteGravado)     
      ,@ImporteExcento = SUM(DP.ImporteExcento)     
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock) 
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposPercepciones percepciones with (nolock) 
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion in ('PERCEPCION')      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		--AND percepciones.Codigo not in ('022','023','025')      
		and DP.ImporteAcumuladoTotales <> 0      
	GROUP BY EP.IDHistorialEmpleadoPeriodo      
      
    select       
      @TotalSueldo = ROUND(SUM(DP.ImporteTotal1),2)      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposPercepciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion  in ('PERCEPCION')      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		   AND percepciones.Codigo not in ('022','023','025')      
		   and DP.ImporteAcumuladoTotales <> 0      
	GROUP BY EP.IDHistorialEmpleadoPeriodo      
      
	select       
		@TotalOtrosPagos = SUM(round(DP.ImporteTotal1,2))      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposDeducciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoDeduccion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'OTROS TIPOS DE PAGOS'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		--AND percepciones.Codigo not in ('022','023','025')      
        
      
	select       
		@TotalDeducciones = SUM(round(DP.ImporteTotal1,2))      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposDeducciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoDeduccion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'DEDUCCION'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo and DP.ImporteAcumuladoTotales <> 0      
      
	select       
		@OtrasDeducciones = SUM(ROUND(DP.ImporteTotal1,2))      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)     
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposDeducciones Deducciones with (nolock)      
			on c.IDCodigoSAT = Deducciones.IDTipoDeduccion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'DEDUCCION'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		and Deducciones.Codigo <> '002' -- ISR      
		and DP.ImporteAcumuladoTotales <> 0      
      
	select       
		@TotalImpuestos = SUM(ROUND(DP.ImporteTotal1,2))      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposDeducciones deducciones with (nolock)      
			on c.IDCodigoSAT = deducciones.IDTipoDeduccion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto      
				and TipoConcepto.Descripcion = 'DEDUCCION'      
				and deducciones.Codigo = '002' -- ISR      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo and DP.ImporteAcumuladoTotales <> 0      
      
	set @Total = (isnull(@TotalOtrosPagos,0.00)+isnull(@SubTotal,0.00)) - isnull(@TotalDeducciones,0.00)      
   --set @Total = isnull(@SubTotal,0.00) - isnull(@TotalDeducciones,0.00)     
   
    select       
      @Indemnizacion = CASE WHEN (ROUND(SUM(DP.ImporteTotal1),2) > 0) THEN 1 ELSE 0 END     
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposPercepciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion  in ('PERCEPCION')      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		   AND percepciones.Codigo in ('022','023','025')      
		   and DP.ImporteAcumuladoTotales <> 0      
	GROUP BY EP.IDHistorialEmpleadoPeriodo   

         
	select 
		@Folio Folio      
		 ,@Fecha Fecha      
		 ,cast(isnull(@ImporteGravado,0.00)							 as decimal(21,2))	as TotalGravado      
		 ,cast(isnull(@SubTotal,0.00)								 as decimal(21,2))	as TotalPercepciones      
		 ,cast(isnull(@TotalDeducciones,0.00)						 as decimal(21,2))	as TotalDeducciones      
		 ,cast(isnull(@Total,0.00)									 as decimal(21,2))	as Total      
		 ,cast(isnull(@SubTotal,0.00)+ ISNULL(@TotalOtrosPagos,0.00) as decimal(21,2))	as SubTotal      
		 ,cast(isnull(@ImporteExcento,0.00)							 as decimal(21,2))	as TotalExcento      
		 ,cast(isnull(@TotalImpuestos,0.00)							 as decimal(21,2))	as TotalImpuestos      
		 ,cast(isnull(@OtrasDeducciones,0.00)						 as decimal(21,2))	as OtrasDeducciones      
		 ,cast(ISNULL(@TotalOtrosPagos,0.00)						 as decimal(21,2))	as OtrosTiposPagos      
		 ,cast(ISNULL(@TotalSueldo,0.00)							 as decimal(21,2))	as TotalSueldo  
		 , CAST(@Indemnizacion										 as bit) as Indemnizacion
	-- FOLIO TOTALES       
	
	--PERCEPCIONES      
	select 
		c.Codigo as CodigoConcepto,      
		c.Descripcion as Concepto,      
		percepciones.Codigo as CodigoSatPercepcion,      
		CAST(DP.ImporteGravado as DECIMAL(21,2)) as ImporteGravado,       
		CAST(DP.ImporteExcento as DECIMAL(21,2)) as  ImporteExcento,
		CEILING(CAST(CASE WHEN c.Codigo = '110' THEN (CAST(DP.ImporteTotal1 as DECIMAL(21,2))/2)/(isnull(E.SalarioDiario,0)/8) 
						  WHEN c.Codigo = '111' THEN (CAST(DP.ImporteTotal1 as DECIMAL(21,2))/3)/(isnull(E.SalarioDiario,0)/8) 
							ELSE 0 END as DECIMAL(21,2))) as CantidadesHorasExtra,
		CAST(DP.ImporteTotal1 as DECIMAL(21,2))  as ImporteTotal1,
		CASE WHEN c.Codigo in ('110','111') THEN		
				CASE WHEN pp.Codigo = '02' THEN CASE WHEN ((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) > 3 THEN 3 ELSE CEILING((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) END
					WHEN pp.Codigo = '03' THEN CASE WHEN   ((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) > 6 THEN 6 ELSE CEILING((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) END
					WHEN pp.Codigo = '04' THEN CASE WHEN   ((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) > 7 THEN 7 ELSE CEILING((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) END
					WHEN pp.Codigo = '05' THEN CASE WHEN   ((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) > 14 THEN 14 ELSE CEILING((CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))/2)/(isnull(e.SalarioDiario,0)/8)/3) END
					ELSE 0
				END
		ELSE 0
		END as CantidadDiasExtra
		from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
			Inner join Nomina.tblDetallePeriodo DP with (nolock)      
				on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo  
			inner join Nomina.tblCatPeriodos p with (nolock)
				on ep.IDPeriodo = p.IDPeriodo
			inner join Nomina.tblCatTipoNomina tn with (nolock)
				on p.IDTipoNomina = tn.IDTipoNomina
			inner join Sat.tblCatPeriodicidadesPago pp with (nolock)
				on pp.IDPeriodicidadPago = tn.IDPeriodicidadPago   
			inner join Nomina.tblCatConceptos c with (nolock)      
				on DP.IDConcepto = C.IDConcepto      
			Inner join Sat.tblCatTiposPercepciones percepciones with (nolock)      
				on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
			Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
				on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto      
					and TipoConcepto.Descripcion = 'PERCEPCION' 
			inner join @empleados e
				on e.IDEmpleado = ep.IDEmpleado
			Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
				--AND percepciones.Codigo not in ('022','023','025')      
				and DP.ImporteAcumuladoTotales <> 0      
				--and C.Descripcion not like( '%Aguinaldo%')      
	--PERCEPCIONES      
	--OTROS TIPOS DE PAGO      
	select 
		c.Codigo as CodigoConcepto,      
		c.Descripcion as Concepto,      
		percepciones.Codigo as CodigoSatPercepcion,          
		CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2)) as  ImporteTotal1      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock) 
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposOtrosPagos percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoOtroPago      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)       
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto      
				and TipoConcepto.Descripcion = 'OTROS TIPOS DE PAGOS'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo     
	--and percepciones.Codigo = '002'     
         
	--OTROS TIPOS DE PAGO      
    
	--OTROS TIPOS DE PAGO  -- SUBISDIO CAUSADO    
	select 
		c.Codigo as CodigoConcepto,      
		c.Descripcion as Concepto,      
		percepciones.Codigo as CodigoSatPercepcion,      
		CAST(ROUND(DP.ImporteGravado,2) as DECIMAL(21,2)) as ImporteGravado,       
		CAST(ROUND(DP.ImporteExcento,2) as DECIMAL(21,2)) as  ImporteExcento,      
		CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2)) as  ImporteTotal1   
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		left join Sat.tblCatTiposPercepciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)          
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto      
		--and TipoConcepto.Descripcion = 'OTROS TIPOS DE PAGOS'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo  and c.Codigo in ('078')     
	--OTROS TIPOS DE PAGO -- SUBISDIO CAUSADO    
    
	--DEDUCCIONES      
	select 
		c.Codigo as CodigoConcepto,      
		c.Descripcion as Concepto,      
		Deducciones.Codigo as CodigoSatDeduccion,      
		CAST(SUM(ROUND(DP.ImporteTotal1,2)) as DECIMAL(21,2)) as TotalDeduccion      
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposDeducciones Deducciones with (nolock)      
			on c.IDCodigoSAT = Deducciones.IDTipoDeduccion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'DEDUCCION'      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo and DP.ImporteAcumuladoTotales <> 0      
	--and C.Codigo = '200' -- ISR      
	GROUP By c.Codigo,c.Descripcion,Deducciones.Codigo ;     
	--DEDUCCIONES      
	--INCAPACIDADES  

    
	DECLARE @MontoIncapacidad Decimal(18,2)

	select @MontoIncapacidad = SUM(ISNULL(dp.ImporteTotal1,0.00))
	FROM @empleados Empleados
	inner join Nomina.tblDetallePeriodo dp with(nolock)
            on Empleados.IDEmpleado = dp.IDEmpleado
            and dp.IDPeriodo = @IDPeriodo
            and dp.IDConcepto in (
                select IDConcepto 
                from Nomina.tblCatConceptos c with(nolock) 
                inner join Sat.tblCatTiposPercepciones p 
                    on p.IDTipoPercepcion = c.IDCodigoSAT 
                where p.Codigo = '014' and c.IDTipoConcepto = 1
            );

	--select @MontoIncapacidad;

    WITH IncapacidadesBase AS (
        select
            fn.Numero,  
            fn.Duracion as Duracion,
            fn.TipoIncapacidad,
            fn.PagoSubsidioEmpresa as PagoSubsidioEmpresa,
            CASE WHEN isnull(@MontoIncapacidad,0) > 0 THEN @MontoIncapacidad
                else CAST(CASE  
                    WHEN fn.PagoSubsidioEmpresa = 1 and fn.TipoIncapacidad = '02' 
                        THEN (((Empleados.SalarioDiario / 100) * 40) * fn.Duracion)      
                    else 0      
                    END as Decimal(18,2)) 
                end as ImporteBase
        From @empleados Empleados      
        Cross APPLY  Asistencia.fnGetIncapacidades(Empleados.IDEmpleado,@FechaInicioIncidencia,@FechaFinIncidencia) as fn
		
    )
    SELECT 
        inca.Numero,
        inca.Duracion,
        inca.PagoSubsidioEmpresa,
        inca.TipoIncapacidad,
        CAST(
            (inca.ImporteBase * (CAST(inca.Duracion AS DECIMAL(18,2)) / NULLIF(SUM(i2.Duracion), 0))) 
            as DECIMAL(18,2)
        ) as Importe
    FROM IncapacidadesBase inca
    CROSS JOIN IncapacidadesBase i2
    GROUP BY 
        inca.Numero,
        inca.Duracion,
        inca.PagoSubsidioEmpresa,
        inca.TipoIncapacidad,
        inca.ImporteBase


    --Select * from IncapacidadesBase

	--INCAPACIDADES      
      
	--INDEMNIZACION FINIQUITO  
    /* El () / COUNT() se hace para cuando hay INDEMNIZACION y PRIMA DE ANTIGUEDAD Se repite el SALARIO dos veces y le duplica el salario mensual */   
	select 
		SUM(dp.ImporteTotal1) as TotalPagado,      
		DATEDIFF(YEAR,CF.FechaAntiguedad,isnull(CF.FechaBaja,@FechaFinPago)) as NumAniosServicio, 
		CAST(SUM(ROUND((e.SalarioDiario * 30.4),2)) as DECIMAL(21,2)) as UltimoSueldoMensOrd,

		CASE WHEN SUM(dp.ImporteGravado) >=  CAST(SUM(ROUND((e.SalarioDiario * 30.4),2)) as DECIMAL(21,2))       
			THEN CAST(SUM(ROUND((e.SalarioDiario * 30.4),2)) as DECIMAL(21,2))      
			ELSE SUM(dp.ImporteGravado)      
		END IngresoAcumulable, 

		CASE WHEN (SUM(dp.ImporteGravado) - CAST(SUM(ROUND((e.SalarioDiario * 30.4),2))as DECIMAL(21,2))) < 0 THEN 0      
		ELSE (SUM(dp.ImporteGravado) - CAST(SUM(ROUND((e.SalarioDiario * 30.4),2))as DECIMAL(21,2)))      
		END as IngresoNoAcumulable   

	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)      
		Inner join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		inner join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		Inner join Sat.tblCatTiposPercepciones percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoPercepcion      
		Inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)      
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'PERCEPCION'      
		left JOIN Nomina.tblControlFiniquitos CF with (nolock)      
			on EP.IDEmpleado = CF.IDEmpleado      
				and EP.IDPeriodo = CF.IDPeriodo      
				AND CF.IDEStatusFiniquito = 2      
		INNER JOIN @empleados e      
			on EP.IDEmpleado = E.IDEmpleado      
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo      
		AND percepciones.Codigo in ('022','023','025') AND DP.ImporteAcumuladoTotales <> 0      
	Group by cf.FechaAntiguedad,CF.FechaBaja, e.SalarioDiario      
       
	-- REINTREGRO DE ISR AJUSTE ANUAL     
	select      
		ISNULL(SUM(CAST(ROUND(DP.ImporteTotal1,2) as DECIMAL(21,2))),0) as REINTEGRO    
		,p.Ejercicio - 1 as Ejercicio -- Año anterior 
	from Nomina.tblHistorialesEmpleadosPeriodos EP with (nolock)    
		Inner join Nomina.tblCatPeriodos p with (nolock) 
			on p.IDPeriodo = ep.IDPeriodo      
		left join Nomina.tblDetallePeriodo DP with (nolock)      
			on EP.IDEmpleado = dp.IDEmpleado and EP.IDPeriodo = DP.IDPeriodo      
		left join Nomina.tblCatConceptos c with (nolock)      
			on DP.IDConcepto = C.IDConcepto      
		inner join Sat.tblCatTiposOtrosPagos percepciones with (nolock)      
			on c.IDCodigoSAT = percepciones.IDTipoOtroPago      
		inner join Nomina.tblCatTipoConcepto TipoConcepto with (nolock)       
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto and TipoConcepto.Descripcion = 'OTROS TIPOS DE PAGOS'  
	Where EP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo and percepciones.Codigo in( '004')       
	GROUP BY p.Ejercicio 
	-- REINTREGRO DE ISR AJUSTE ANUAL    
	
	--CFDI's RELACIONADOS
		SELECT DISTINCT UPPER(UUID) as UUID
		FROM FACTURACION.TblTimbrado 
		WHERE IDHistorialEmpleadoPeriodo = @Folio
		AND UUID IS NOT NULL
	--CFDI's RELACIONADOS

	--SUBCONTRATACION BENEFICIARIO DE CONTRATACIÓN
	SELECT BC.RFC, BCED.Porcentaje
	FROM RH.tblBeneficiarioContratacionEmpleado BCE with(nolock)    
		INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP with(nolock)
			on BCE.IDEmpleado = HEP.IDEmpleado
		INNER JOIN RH.tblBeneficiarioContratacionEmpleadoDetalle BCED with(nolock)
			on BCED.IDBeneficiarioContratacionEmpleado = BCE.IDBeneficiarioContratacionEmpleado
		Inner join RH.tblcatBeneficiariosContratacion BC with(nolock)
			on BC.IDCatBeneficiarioContratacion = BCED.IDCatBeneficiarioContratacion
	WHERE HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo
	and @FechaFinPago Between BCE.FechaIni and BCE.FechaFin
	--SUBCONTRATACION BENEFICIARIO DE CONTRATACIÓN

END
GO
