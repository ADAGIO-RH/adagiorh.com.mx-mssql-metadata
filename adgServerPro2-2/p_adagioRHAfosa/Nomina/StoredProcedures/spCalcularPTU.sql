USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [p_adagioRHAfosa]
--GO
--/****** Object:  StoredProcedure [Nomina].[spCalcularPTU]    Script Date: 4/16/2021 10:57:40 AM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--/****************************************************************************************************     
--** Descripción  : Calcular PTU del colaborador    
--** Autor   : Jose Roman   
--** Email   : jose.roman@adagio.com.mx    
--** FechaCreacion : 2019-04-29    
--** Paremetros  :                  
--****************************************************************************************************    
--HISTORIAL DE CAMBIOS    
--Fecha(yyyy-mm-dd) Autor   Comentario    
--------------------- ------------------- ------------------------------------------------------------    
  
--[Nomina].[spCalcularPTU] 2,1
--GO
--***************************************************************************************************/  
CREATE PROCEDURE [Nomina].[spCalcularPTU]
(
	 @IDPTU int
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;
	--declare 
	--	@IDPTU int = 2
	--	,@IDUsuario int = 1
	--;

	DECLARE 
		@IDEmpresa int,
		@Ejercicio int,
		@ConceptosIntegranSueldo varchar(max),
		@DiasDescontar varchar(MAX),
		@DescontarIncapacidades bit = 0,
		@TiposIncapacidadesADescontar varchar(max),
		@CantidadGanancia Decimal(18,4),
		@CantidadRepartir Decimal(18,4),
		@CantidadPendiente Decimal(18,4),
		@DiasMinimosTrabajados int,
		@DiasMaximosTrabajados int,
		@EjercicioPago int,
		@IDPeriodo	int,
		@TotalRepartir Decimal(18,4),
		@MontoSueldo Decimal(18,2),
		@MontoDias Decimal(18,2),
		@FactorSueldo decimal(18,9),
		@FactorDias decimal(18,9),
		@IDEmpleadoTipoSalarioMensualConfianza int,
		@FechaInicial Date,
		@FechaFinal Date,
		@dtEmpleados RH.dtEmpleados,
		@dtFiltros Nomina.dtFiltrosRH,
		@TopeSindical decimal(18,2),
		@TopeSalarioAnual decimal(18,2),
		@TopeConfianza decimal(18,2),
		@AplicarReforma bit,
		@dtFechas app.dtFechas, 
		@dtFechasPromSalario3Meses app.dtFechas, 
		@FechaHoy Date,
		@Fecha3Meses Date,
		@dtEmpleadosMovimientoSalario RH.dtEmpleados ,
		@ConceptoPTU Varchar(10) = '131',
		@IDConceptoPTU int ,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCalcularPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTUEmpleados]',
		@Accion		varchar(20)	= 'EJECUCIÓN CÁLCULO PTU'
	;	


	SET @FechaHoy = CAST(GETDATE() as DATE)
	SET @Fecha3Meses = DATEADD(MONTH,-3,CAST(GETDATE() as DATE))

	select top 1 @IDConceptoPTU = IDConcepto from Nomina.tblCatConceptos with(nolock) where Codigo = @ConceptoPTU


	Select
		@IDEmpresa					= IDEmpresa,
		@Ejercicio					= Ejercicio,
		@ConceptosIntegranSueldo	= ConceptosIntegranSueldo,
		@DiasDescontar				= DiasDescontar,
		@DescontarIncapacidades		= DescontarIncapacidades, 
		@TiposIncapacidadesADescontar = TiposIncapacidadesADescontar,
		@CantidadGanancia			= ISNULL(CantidadGanancia,0.00) ,
		@CantidadRepartir			= ISNULL(CantidadRepartir,0.00), 
		@CantidadPendiente			= ISNULL(CantidadPendiente,0.00), 
		@DiasMinimosTrabajados      = DiasMinimosTrabajados,
		@EjercicioPago				= EjercicioPago,
		@IDPeriodo					= IDPeriodo,
		@MontoSueldo				= cast((ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))))/2.00 as decimal(18 ,2)),
		@MontoDias					= cast((ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))))/2.00 as decimal(18 ,2)), 
		@TotalRepartir				= ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))), 
		@FechaInicial				= Cast(Cast(Ejercicio as Varchar(4)) +'-01-01' as date),
		@FechaFinal					= Cast(Cast(Ejercicio as Varchar(4)) +'-12-31' as date),
		@TopeConfianza				= ISNULL(TopeConfianza,0.00),
		@AplicarReforma				= isnull(AplicarReforma,0)
	from Nomina.tblPTU
	where IDPTU = @IDPTU

	insert into @dtFechas  
	exec [App].[spListaFechas] @FechaIni = @FechaInicial, @FechaFin = @FechaFinal  


	select @NewJSON = a.JSON
	from (
		Select 
			@IDEmpresa					 as IDEmpresa					
			,@Ejercicio					 as Ejercicio					
			,@ConceptosIntegranSueldo	 as ConceptosIntegranSueldo	
			,@DiasDescontar				 as DiasDescontar				
			,@DescontarIncapacidades		 as DescontarIncapacidades		
			,@TiposIncapacidadesADescontar as TiposIncapacidadesADesconta
			,@CantidadGanancia			 as CantidadGanancia			
			,@CantidadRepartir			 as CantidadRepartir			
			,@CantidadPendiente			 as CantidadPendiente			
			,@DiasMinimosTrabajados       as DiasMinimosTrabajados      
			,@EjercicioPago				 as EjercicioPago				
			,@IDPeriodo					 as IDPeriodo					
			,@MontoSueldo				 as MontoSueldo				
			,@MontoDias					 as MontoDias					
			,@TotalRepartir				 as TotalRepartir				
			,@FechaInicial				 as FechaInicial				
			,@FechaFinal				 as FechaFinal	
			,@AplicarReforma			 as AplicarReforma
	) b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
	
	--select @CantidadDias as CantidadDias, @CantidadMonto as CantidadMonto

	insert into @dtFiltros(Catalogo,Value)
	select 'RazonesSociales',@IDEmpresa

	--SELECT @FechaInicial, @FechaFinal
	insert into @dtEmpleados
	Exec RH.spBuscarEmpleados
		 @FechaIni  = @FechaInicial,                
		 @Fechafin  = @FechaFinal,                
		 @dtFiltros = @dtFiltros,
		 @IDUsuario = @IDUsuario


	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
  
	create Table #tempVigenciaEmpleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  


  
	insert into #tempVigenciaEmpleados  
	Exec [RH].[spBuscarListaFechasVigenciaEmpresaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1
		,@IDEmpresa =  @IDEmpresa


	delete  #tempVigenciaEmpleados where Vigente = 0

	-- Eliminar de @dtEmpleados los trabajadores que no se les paga PTU
	delete e
	from @dtEmpleados e
		left join RH.tblEmpleadoPTU ptu on ptu.IDEmpleado = e.IDEmpleado
	where isnull(ptu.PTU,0) = 0


	declare @tempAcumulado as TABLE (
		IDEmpleado int,
		ClaveEmpleado varchar(20),
		Colaborador varchar(500),
		CodigoConcepto varchar(20),
		Concepto varchar(255),
		Total decimal(18,2)
	)

	insert @tempAcumulado
	exec [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
		@Ejercicio = @Ejercicio,
		@CodigosConceptos = @ConceptosIntegranSueldo,
		@dtEmpleados = @dtEmpleados,
		@IDUsuario = @IDUsuario,
		@IDEmpresa = @IDEmpresa


	declare @acum as TABLE (
		IDEmpleado int,
		Total decimal(18,2)
	)

	insert @acum(IDEmpleado, Total)
	select IDEmpleado, SUM(total)
	from @tempAcumulado
	group by IDEmpleado

	
	if object_id('tempdb..#tempMovAfilPTU') is not null drop table #tempMovAfilPTU    
      
	select 
		IDEmpleado
		,FechaAlta
		,FechaBaja             
		,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso              
		,IDMovAfiliatorio      
	into #tempMovAfilPTU              
    from (select distinct tm.IDEmpleado,              
        case when(IDEmpleado is not null) then (select top 1 Fecha               
                 from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)              
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento              
                 where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'                
                 Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,              
        case when (IDEmpleado is not null) then (select top 1 Fecha               
                 from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)              
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento              
                 where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'                
                and mBaja.Fecha <= @FechaFinal               
      order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,              
        case when (IDEmpleado is not null) then (select top 1 Fecha               
                 from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)              
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento              
                 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'                
                and mReingreso.Fecha <= @FechaFinal               
                order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso                
        ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)              
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento              
                 where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')               
                 order by mSalario.Fecha desc ) as IDMovAfiliatorio                                               
        from [IMSS].[tblMovAfiliatorios]  tm ) mm       
	where IDEmpleado in (Select e.IDEmpleado from @dtEmpleados e)  

	


	
	if object_id('tempdb..#tempDataEmpleados') is not null drop table #tempDataEmpleados 
	
	select 
		e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.SalarioDiario
		,e.Empresa
		,ma.FechaAlta 
		,ma.FechaBaja 
		,ma.FechaReingreso
		,ee.EmpresaInicio
		,ee.EmpresaFin 
		,FechaInicioHistoria = 
			case when MA.FechaReingreso is not null and MA.FechaReingreso > MA.FechaAlta and MA.FechaReingreso between @FechaInicial and @FechaFinal then MA.FechaReingreso 
				when MA.FechaAlta > @FechaInicial then MA.FechaAlta
			else @FechaInicial end
		,FechaFinHistoria = case when ISNULL(em.Vigente, 0) = 0 and MA.FechaBaja between @FechaInicial and @FechaFinal then MA.FechaBaja
								else @FechaFinal end
		,e.IDTipoPrestacion
		,TP.Descripcion as TipoPrestacion
		,tp.Sindical
		,salarioAnual.Total as SalarioAcumuladoReal
		,salarioAnual.Total as Salario
		--,isnull(((avgSueldo.SalarioDiario)*90.0)/3.0,0) as SueldoPromedio3Meses
		--,isnull(PromPTU3Anios.PromPTU3Anios,0) as PromPTU3Anios
		, 0 as PTURecomendado
	into #tempDataEmpleados
	from @dtEmpleados e
		join RH.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado
		inner join #tempMovAfilPTU MA on MA.IDEmpleado = e.IDEmpleado
		inner join (select empresa.IDEmpresa, empresa.IDEmpleado, min(empresa.FechaIni) EmpresaInicio, max(empresa.FechaFin) EmpresaFin from rh.tblEmpresaEmpleado empresa where empresa.IDEmpresa = @IDEmpresa group by empresa.IDEmpleado, empresa.IDEmpresa ) EE on e.IDEmpleado = ee.IDEmpleado
			and EE.EmpresaInicio<= @FechaFinal and EE.EmpresaFin >= @FechaInicial   
			--and EE.IDEmpresa = @IDEmpresa 
		--inner join rh.tblEmpresaEmpleado EE on e.IDEmpleado = ee.IDEmpleado
		--	and EE.FechaIni<= @FechaFinal and EE.FechaFin >= @FechaFinal   
		--	and EE.IDEmpresa = @IDEmpresa
		inner join RH.tblCatTiposPrestaciones TP on TP.IDTipoPrestacion = e.IDTipoPrestacion
		join @acum salarioAnual on salarioAnual.IDEmpleado = e.IDEmpleado
		--left join #tempEmpleadosSueldosAVG avgSueldo
		--	on e.IDEmpleado = avgSueldo.IDEmpleado
		--left join #tempPromPTU3Anios promPTU3Anios
		--	on promPTU3Anios.IDEmpleado = e.IDEmpleado
	ORDER BY E.ClaveEmpleado




	if object_id('tempdb..#tempDataEmpleadosGeneral') is not null drop table #tempDataEmpleadosGeneral


	select d.* 
		--, (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) DiasVigencia
		,(select count(*) from #tempVigenciaEmpleados where IDEmpleado = d.IDEmpleado ) DiasVigencia
		--,(DATEDIFF(day, EmpresaInicio, EmpresaFin)) DiasVigencia
		, 0 as DiasADescontar
		, 0 as Incapacidades
		, 0 as DiasTrabajados
		
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,@ConceptosDiasDescontar,FechaInicioHistoria,FechaFinHistoria) as DescontarDias
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'I',FechaInicioHistoria,FechaFinHistoria) as Incapacidades
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'F',FechaInicioHistoria,FechaFinHistoria) as Faltas
	into #tempDataEmpleadosGeneral
	from #tempDataEmpleados d
	--WHERE (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) >= @DiasMinimosTrabajados
	
	select * from #tempDataEmpleadosGeneral
	update temp_data
		set temp_data.DiasADescontar = (select COUNT(ie.IDIncidencia) 
										from Asistencia.tblIncidenciaEmpleado ie 
										inner join (select ee.IDEmpleado, ee.FechaIni as EmpresaInicio, ee.FechaFin as EmpresaFin 
											from rh.tblEmpresaEmpleado ee 
											where ee.IDEmpresa = @IDEmpresa
										) Empresa on Empresa.idEmpleado = ie.IdEmpleado
										where ie.IDIncidencia in (select item from App.split(@DiasDescontar, ','))
											and (year(ie.Fecha) = @ejercicio  and ie.Fecha between Empresa.EmpresaInicio and Empresa.EmpresaFin)
											and ie.IDEmpleado = temp_data.IDEmpleado
											and isnull(ie.Autorizado,0) = 1
										)
										
			,temp_data.Incapacidades = case when isnull(@DescontarIncapacidades, 0) = 1 then 
										(select isnull(count(ie.IDIncidencia),0) 
										from Asistencia.tblIncidenciaEmpleado ie 
											join Asistencia.tblIncapacidadEmpleado ii on ii.IDIncapacidadEmpleado = ie.IDIncapacidadEmpleado
											inner join (select ee.IDEmpleado, ee.FechaIni as EmpresaInicio, ee.FechaFin as EmpresaFin 
														from rh.tblEmpresaEmpleado ee 
														where ee.IDEmpresa = @IDEmpresa 
														) Empresa on Empresa.idEmpleado = ie.IdEmpleado
										where ii.IDTipoIncapacidad in (select item from App.split(@TiposIncapacidadesADescontar, ','))
											and (year(ie.Fecha) = @ejercicio  and ie.Fecha between Empresa.EmpresaInicio and Empresa.EmpresaFin)
											and ie.IDEmpleado = temp_data.IDEmpleado
											and isnull(ie.Autorizado,0) = 1
										) else 0 end
	from #tempDataEmpleadosGeneral temp_data



	update #tempDataEmpleadosGeneral
		set DiasTrabajados = isnull(DiasVigencia,0) - (isnull(Incapacidades,0) + isnull(DiasADescontar,0))

	
	
	if (isnull(@DiasMinimosTrabajados,0) > 0)
	begin
		delete #tempDataEmpleadosGeneral
		where DiasTrabajados < @DiasMinimosTrabajados
	end


	--select @TopeSalarioAnual = MAX(SalarioDiario) * 30 * 1.20
	--from #tempDataEmpleadosGeneral

	--select top 1 @IDEmpleadoTipoSalarioMensualConfianza = IDEmpleado, @TopeSalarioAnual = Salario * 1.20
	--from #tempDataEmpleadosGeneral
	--where Sindical = 1
	--order by SalarioDiario desc

	select @DiasMaximosTrabajados =  MAX(DiasVigencia) from #tempDataEmpleadosGeneral

	IF(ISNULL(@TopeConfianza,0) <> 0 )
	BEGIN
		update #tempDataEmpleadosGeneral
			set Salario = (@TopeConfianza * @DiasMaximosTrabajados)
		where Salario > (@TopeConfianza * @DiasMaximosTrabajados)
			and isnull(Sindical,0) = 0
	END

	select 
		@FactorDias = @MontoDias / CAST(SUM(DiasTrabajados) as decimal(18,9))
	from #tempDataEmpleadosGeneral

	select 
		@FactorSueldo = @MontoSueldo / cast((SUM(Salario)) as decimal(18,9)) 
	from #tempDataEmpleadosGeneral

	--select * from #tempDataEmpleadosGeneral where Sindical = 1
	if exists(select Top 1 1 from #tempDataEmpleadosGeneral where Sindical = 1)
	BEGIN
		Select @TopeSindical = MAX(SalarioDiario * 365.0) + (MAX(SalarioDiario * 365.00) * 0.20)
		from #tempDataEmpleadosGeneral
		where Sindical = 1
	END
	ELSE
	BEGIN
		Select @TopeSindical = MAX(SalarioDiario * 365.0) + (MAX(SalarioDiario * 365.00) * 0.20)
		from #tempDataEmpleadosGeneral
	END

	
  
	--if object_id('tempdb..#tempData') is not null drop table #tempData

	--select G.* ,
	--	CantidadMonto	= cast(G.Salario * @FactorSueldo as decimal(18, 4)),	--case when (ISNULL(G.Sindical,0) = 1) and (((G.Salario) * @FactorMonto) > @TopeSindical) and @TopeSindical > 0.00 then @TopeSindical else ((G.Salario * @FactorMonto))END,
	--	CantidadDias	= cast(G.DiasTrabajados * @FactorDias as decimal(18, 4)),
	--	TotalPTU		= cast(0.0000 as decimal(18 ,4)), --(case when (ISNULL(G.Sindical,0) = 1) and (((G.Salario) * @FactorMonto) > @TopeSindical) and @TopeSindical > 0.00 then @TopeSindical else ((G.Salario * @FactorMonto))END)+((G.DiasTrabajados - G.DescontarDias) * @FactorDias),
	--	VigenteHoy		= M.Vigente,
	--	SueldoPromedio3Meses = ((g.SalarioAcumuladoReal/365.0)*90),
	--	PromPTU3Anios = 0.00
	--into #tempData
	--from #tempDataEmpleadosGeneral G
	--	inner join RH.tblEmpleadosMaster m on G.IDEmpleado = M.IDEmpleado


	
	

	BEGIN ----PROMEDIO PTU 3 ANIOS
		if object_id('tempdb..#tempPromPTU3Anios') is not null drop table #tempPromPTU3Anios      
		
	declare @tempAcumuladoPTU3Anios as TABLE (
		IDEmpleado int,
		ClaveEmpleado varchar(20),
		Colaborador varchar(500),
		CodigoConcepto varchar(20),
		Concepto varchar(255),
		Total decimal(18,2)
	)

	insert @tempAcumuladoPTU3Anios
	exec [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
		@Ejercicio = @Ejercicio,
		@CodigosConceptos = @ConceptoPTU,
		@dtEmpleados = @dtEmpleados,
		@IDUsuario = @IDUsuario,
		@IDEmpresa = @IDEmpresa
	
	DECLARE @Ejercicio1 int = @Ejercicio - 1 
	DECLARE @Ejercicio2 int = @Ejercicio - 2 

	insert @tempAcumuladoPTU3Anios
	exec [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
		@Ejercicio = @Ejercicio1,
		@CodigosConceptos = @ConceptoPTU,
		@dtEmpleados = @dtEmpleados,
		@IDUsuario = @IDUsuario,
		@IDEmpresa = @IDEmpresa

	insert @tempAcumuladoPTU3Anios
	exec [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
		@Ejercicio = @Ejercicio2,
		@CodigosConceptos = @ConceptoPTU,
		@dtEmpleados = @dtEmpleados,
		@IDUsuario = @IDUsuario,
		@IDEmpresa = @IDEmpresa

	--select * from @tempAcumuladoPTU3Anios

	select IDEmpleado, avg(Total) PromPTU3Anios
		into #tempPromPTU3Anios
	from @tempAcumuladoPTU3Anios 
	group by IDEmpleado

	END

	select G.* ,
		CantidadMonto	= cast(G.Salario * @FactorSueldo as decimal(18, 4)),	--case when (ISNULL(G.Sindical,0) = 1) and (((G.Salario) * @FactorMonto) > @TopeSindical) and @TopeSindical > 0.00 then @TopeSindical else ((G.Salario * @FactorMonto))END,
		CantidadDias	= cast(G.DiasTrabajados * @FactorDias as decimal(18, 4)),
		TotalPTU		= cast((case when (CantidadMonto + CantidadDias) > @TopeSindical  and @TopeSindical > 0.00 then @TopeSindical else (CantidadMonto + CantidadDias) end )as decimal(18 ,4)), --(case when (ISNULL(G.Sindical,0) = 1) and (((G.Salario) * @FactorMonto) > @TopeSindical) and @TopeSindical > 0.00 then @TopeSindical else ((G.Salario * @FactorMonto))END)+((G.DiasTrabajados - G.DescontarDias) * @FactorDias),
		VigenteHoy		= M.Vigente,
		SueldoPromedio3Meses = ((g.SalarioAcumuladoReal/365.0)*90),
		PromPTU3Anios =ptu3.PromPTU3Anios  --personalizado
	into #tempData
	from #tempDataEmpleadosGeneral G
		inner join RH.tblEmpleadosMaster m on G.IDEmpleado = M.IDEmpleado
		left join #tempPromPTU3Anios ptu3 
			on ptu3.IDEmpleado = m.IDEmpleado      

	update t
		set TotalPTU = case when (CantidadMonto + CantidadDias) > @TopeSindical  and @TopeSindical > 0.00 then @TopeSindical else (CantidadMonto + CantidadDias) end 
		,t.PromPTU3Anios = ptu3.PromPTU3Anios
		--(case when (ISNULL(G.Sindical,0) = 1) and (((G.Salario) * @FactorMonto) > @TopeSindical) and @TopeSindical > 0.00 then @TopeSindical else ((G.Salario * @FactorMonto))END)+((G.DiasTrabajados - G.DescontarDias) * @FactorDias)
	from #tempDataEmpleadosGeneral G
		inner join RH.tblEmpleadosMaster m on G.IDEmpleado = M.IDEmpleado
		inner join #tempData t on t.IDEmpleado = M.IDEmpleado
		left join #tempPromPTU3Anios ptu3 
			on ptu3.IDEmpleado = m.IDEmpleado
	








	update t
		set PTURecomendado =  A.TheMin 
	from #tempData t
	Inner Join (
         Select A.IDEmpleado, Min(A.TotalPTU) As TheMin
         From   (
                Select IDEmpleado, TotalPTU
                From   #tempData

                Union All

                Select IDEmpleado, PromPTU3Anios
                From   #tempData

                Union All

                
                Select IDEmpleado, SueldoPromedio3Meses
                From   #tempData
                ) As A
		 WHERE A.TotalPTU > 0
         Group By A.IDEmpleado
       ) As A
	on A.IDEmpleado = t.IDEmpleado

--select * from #tempData

	MERGE [Nomina].[tblPTUEmpleados] as TARGET
		USING #tempData as SOURCE
	ON TARGET.IDPTU = @IDPTU
		and TARGET.IDEmpleado = SOURCE.IDEmpleado
	WHEN MATCHED THEN
		update set
			TARGET.SalarioDiario			= SOURCE.SalarioDiario			
			,TARGET.FechaInicio				= SOURCE.FechaInicioHistoria				
			,TARGET.FechaFin					= SOURCE.FechaFinHistoria				
			,TARGET.Sindical					= SOURCE.Sindical				
			,TARGET.SalarioAcumuladoReal		= SOURCE.SalarioAcumuladoReal	
			,TARGET.SalarioAcumuladoTopado	= SOURCE.Salario	
			,TARGET.DiasVigencia			= SOURCE.DiasVigencia			
			,TARGET.DiasADescontar			= SOURCE.DiasADescontar			
			,TARGET.Incapacidades			= SOURCE.Incapacidades			
			,TARGET.DiasTrabajados			= SOURCE.DiasTrabajados			
			,TARGET.PTUPorSalario			= SOURCE.CantidadMonto			
			,TARGET.PTUPorDias				= SOURCE.CantidadDias
			,TARGET.PromedioSueldo3Meses	= SOURCE.SueldoPromedio3Meses
			,TARGET.PromedioPTU3Anios		= SOURCE.PromPTU3Anios
			,TARGET.PTURecomendado			= SOURCE.PTURecomendado
	WHEN NOT MATCHED BY TARGET THEN 
		insert(IDPTU,[IDEmpleado],SalarioDiario,FechaInicio,FechaFin,Sindical				
			,SalarioAcumuladoReal,SalarioAcumuladoTopado,DiasVigencia, DiasADescontar
			,Incapacidades, DiasTrabajados,PTUPorSalario,PTUPorDias, PromedioSueldo3Meses, PromedioPTU3Anios, PTURecomendado)
		values(@IDPTU
			,SOURCE.[IDEmpleado]
			,SOURCE.SalarioDiario			
			,SOURCE.FechaInicioHistoria				
			,SOURCE.FechaFinHistoria				
			,SOURCE.Sindical				
			,SOURCE.SalarioAcumuladoReal	
			,SOURCE.Salario	
			,SOURCE.DiasVigencia			
			,SOURCE.DiasADescontar			
			,SOURCE.Incapacidades			
			,SOURCE.DiasTrabajados			
			,SOURCE.CantidadMonto			
			,SOURCE.CantidadDias
			,SOURCE.SueldoPromedio3Meses
			,SOURCE.PromPTU3Anios
			,SOURCE.PTURecomendado


		)
	WHEN NOT MATCHED BY SOURCE and TARGET.IDPTU = @IDPTU
	THEN DELETE;

	update [Nomina].[tblPTU]
		set MontoSueldo = @MontoSueldo
			,MontoDias = @MontoDias
			,FactorSueldo = @FactorSueldo
			,FactorDias = @FactorDias
			,IDEmpleadoTipoSalarioMensualConfianza = @IDEmpleadoTipoSalarioMensualConfianza
			,TopeSalarioMensualConfianza = @TopeSalarioAnual			
	where IDPTU = @IDPTU

--	Select --*
--		ClaveEmpleado, 
--		TotalPTU as Total,
--		--format(TotalPTU, 'c') as Total,
--		CantidadDias, 
--		DiasTrabajados, 
--		--DiasADescontar, 
--		--Incapacidades,
--		--FechaAlta, 
--		--FechaBaja, 
--		--FechaReingreso, 
--		--FechaInicioHistoria, 
--		--FechaFinHistoria, 
--		Salario
--	from #tempData 
----	where ClaveEmpleado = '0294'
--	order by ClaveEmpleado desc
--	--Select sum(Salario) as total from #tempData


	--Select *
	--	--ClaveEmpleado, 
	--	--format(TotalPTU, 'c') as Total,
	--	--CantidadSueldo,
	--	--CantidadDias, 
	--	--DiasTrabajados, 
	--	--DiasADescontar, 
	--	--Incapacidades,
	--	--FechaAlta, 
	--	--FechaBaja, 
	--	--FechaReingreso, 
	--	--FechaInicioHistoria, 
	--	--FechaFinHistoria, 
	--	--Salario
	--from #tempData 
	----where ClaveEmpleado = '0015'
END
GO
