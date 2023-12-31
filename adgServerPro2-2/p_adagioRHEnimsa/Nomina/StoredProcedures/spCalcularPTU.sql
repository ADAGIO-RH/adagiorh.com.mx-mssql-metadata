USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Calcular PTU del colaborador    
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-29    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/   
CREATE PROCEDURE [Nomina].[spCalcularPTU] --1,1,1
(
	 @IDPTU int
	,@Aplicar bit 
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;

	DECLARE 
		@IDEmpresa int,
		@Ejercicio int,
		@DescontarEnfermedadGeneral bit = 0,
		@ConceptosDiasDescontar varchar(MAX),
		@CantidadGanancia Decimal(18,4),
		@CantidadRepartir Decimal(18,4),
		@CantidadPendiente Decimal(18,4),
		@DiasMinimosTrabajados int,
		@EjercicioPago int,
		@TotalRepartir Decimal(18,4),
		@CantidadMonto Decimal(18,4),
		@CantidadDias Decimal(18,4),
		@FechaInicial Date,
		@FechaFinal Date,
		@dtEmpleados RH.dtEmpleados,
		@dtFiltros Nomina.dtFiltrosRH,
		@FactorDias decimal(18,4),
		@FactorMonto decimal(18,4),
		@TopeSindical decimal(18,4),

		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCalcularPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTUEmpleados]',
		@Accion		varchar(20)	= 'EJECUCIÓN CÁLCULO PTU'
	;	

	select @NewJSON = a.JSON
	from (
	Select  IDEmpresa					= IDEmpresa,
			Ejercicio					= Ejercicio,
			EjercicioPago				= EjercicioPago,
			DescontarEnfermedadGeneral	= DescontarEnfermedadGeneral, 
			ConceptosDiasDescontar		= DiasDescontar,
			DiasMinimosTrabajados		= DiasMinimosTrabajados,
			CantidadGanancia			= ISNULL(CantidadGanancia,0.00) ,
			CantidadRepartir			= ISNULL(CantidadRepartir,0.00), 
			CantidadPendiente			= ISNULL(CantidadPendiente,0.00), 
			TotalRepartir				= ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00), 
			CantidadMonto				= (ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00))/2, 
			CantidadDias				= (ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00))/2, 
			FechaInicial				= Cast(Cast(Ejercicio as Varchar(4)) +'-01-01' as date),
			FechaFinal					= Cast(Cast(Ejercicio as Varchar(4)) +'-12-31' as date)
		from Nomina.tblPTU
		where IDPTU = @IDPTU
	) b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	Select @IDEmpresa				= IDEmpresa,
		@Ejercicio					= Ejercicio,
		@EjercicioPago				= EjercicioPago,
		@DescontarEnfermedadGeneral = DescontarEnfermedadGeneral, 
		@ConceptosDiasDescontar		= DiasDescontar,
		@DiasMinimosTrabajados      = DiasMinimosTrabajados,
		@CantidadGanancia			= ISNULL(CantidadGanancia,0.00) ,
		@CantidadRepartir			= ISNULL(CantidadRepartir,0.00), 
		@CantidadPendiente			= ISNULL(CantidadPendiente,0.00), 
		@TotalRepartir				= ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00), 
		@CantidadMonto				= (ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00))/2, 
		@CantidadDias				= (ISNULL(CantidadPendiente,0.00)+ISNULL(CantidadRepartir,0.00))/2, 
		@FechaInicial				= Cast(Cast(Ejercicio as Varchar(4)) +'-01-01' as date),
		@FechaFinal					= Cast(Cast(Ejercicio as Varchar(4)) +'-12-31' as date)
	from Nomina.tblPTU
	where IDPTU = @IDPTU

	insert into @dtFiltros(Catalogo,Value)
	select 'RazonesSociales',@IDEmpresa

	insert into @dtEmpleados
	Exec RH.spBuscarEmpleados
		 @FechaIni  = @FechaInicial,                
		 @Fechafin  = @FechaFinal,                
		 @dtFiltros = @dtFiltros

	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil      
      
	select 
		IDEmpleado
		, FechaAlta
		, FechaBaja             
		, case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso              
		, IDMovAfiliatorio      
   into #tempMovAfil              
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
	where IDEmpleado in (Select e.IDEmpleado from @dtEmpleados e inner join RH.tblEmpleadoPTU eu on eu.IDEmpleado = e.IDEmpleado where ISNULL(eu.PTU,0) = 1)  
	
	if object_id('tempdb..#tempDataEmpleados') is not null drop table #tempDataEmpleados 
	
	select e.IDEmpleado
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
		   ,ee.FechaIni
		   ,ee.FechaFin 
		   ,   CASE
					WHEN @FechaInicial >= (case when ma.FechaReingreso is not null then ma.FechaReingreso else ma.FechaAlta end) AND @FechaInicial >= EE.FechaIni THEN @FechaInicial
					WHEN (case when ma.FechaReingreso is not null then ma.FechaReingreso else ma.FechaAlta end) >= @FechaInicial AND (case when ma.FechaReingreso is not null then ma.FechaReingreso else ma.FechaAlta end) >=  EE.FechaIni THEN (case when ma.FechaReingreso is not null then ma.FechaReingreso else ma.FechaAlta end)
					WHEN EE.FechaIni >= @FechaInicial AND EE.FechaIni >= (case when ma.FechaReingreso is not null then ma.FechaReingreso else ma.FechaAlta end) THEN EE.FechaIni
					ELSE  @FechaInicial
				END FechaInicioHistoria


			,CASE WHEN  (CASE 
					WHEN @FechaFinal > (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) and @FechaFinal > EE.FechaFin THEN @FechaFinal 
				   WHEN (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) > EE.FechaFin and (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) > @FechaFinal THEN (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end)
				   ELSE EE.FechaFin
			  END ) > @FechaFinal THEN @FechaFinal 
			  ELSE (CASE 
					WHEN @FechaFinal > (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) and @FechaFinal > EE.FechaFin THEN @FechaFinal 
				   WHEN (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) > EE.FechaFin and (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end) > @FechaFinal THEN (case when ma.FechaBaja is not null then ma.FechaBaja else '9999-12-31' end)
				   ELSE EE.FechaFin
			  END ) END  As FechaFinHistoria
			,e.IDTipoPrestacion
			,TP.Descripcion as TipoPrestacion
			,tp.Sindical
	into #tempDataEmpleados
	from @dtEmpleados e
		inner join #tempMovAfil MA
			on MA.IDEmpleado = e.IDEmpleado
		inner join rh.tblEmpresaEmpleado EE
			on e.IDEmpleado = ee.IDEmpleado
		and EE.FechaIni<= @FechaFinal and EE.FechaFin >= @FechaFinal   
		and EE.IDEmpresa = @IDEmpresa
		inner join RH.tblCatTiposPrestaciones TP
			on TP.IDTipoPrestacion = e.IDTipoPrestacion
	ORDER BY E.ClaveEmpleado

	if object_id('tempdb..#tempDataEmpleadosGeneral') is not null drop table #tempDataEmpleadosGeneral

	select * 
	, (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) DiasTrabajados
	, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,@ConceptosDiasDescontar,FechaInicioHistoria,FechaFinHistoria) as DescontarDias
	, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'I',FechaInicioHistoria,FechaFinHistoria) as Incapacidades
	, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'F',FechaInicioHistoria,FechaFinHistoria) as Faltas
	into #tempDataEmpleadosGeneral
	from #tempDataEmpleados
	WHERE (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) >= @DiasMinimosTrabajados 
  
	select 
		@FactorDias = @CantidadDias / CAST(SUM(DiasTrabajados) - SUM(DescontarDias) as decimal(18,4))
	from #tempDataEmpleadosGeneral

	select 
		@FactorMonto = @CantidadMonto / cast((SUM(SalarioDiario ) ) as decimal(18,4)) 
	from #tempDataEmpleadosGeneral

	if exists( select Top 1 1 from #tempDataEmpleadosGeneral where Sindical = 1)
	BEGIN
		Select @TopeSindical = MAX(SalarioDiario * 365) + (MAX(SalarioDiario * 365.0000) * 0.2000)
		from #tempDataEmpleadosGeneral
		where Sindical = 1
	END
	ELSE
	BEGIN
		Select @TopeSindical = 0
	END
  
  --select 
		-- @IDEmpresa	as IDEmpresa			
		--,@Ejercicio		as Ejercicio				
  --  	,@EjercicioPago	as EjercicioPago			
		--,@DescontarEnfermedadGeneral  as DescontarEnfermedadGeneral
		--,@ConceptosDiasDescontar as ConceptosDiasDescontar		
		--,@CantidadGanancia	 as CantidadGanancia		 
		--,@CantidadRepartir as CantidadRepartir			
		--,@CantidadPendiente	 as CantidadPendiente		
		--,@TotalRepartir	as TotalRepartir				
		--,@CantidadMonto	 as CantidadMonto				
		--,@CantidadDias	as CantidadDias
		--,@FechaInicial as FechaInicial
		--,@FechaFinal as FechaFinal
		--,@FactorDias as factorDias
		--,@FactorMonto as FactorMonto
		--,@TopeSindical as TopeSindical

		
	if object_id('tempdb..#tempData') is not null drop table #tempData

	select G.* ,
		CantidadMonto	= case when (ISNULL(G.Sindical,0) = 0) and (((G.SalarioDiario) * @FactorMonto) > @TopeSindical) and @TopeSindical >0.00 then @TopeSindical else ((G.SalarioDiario * @FactorMonto))END,
		CantidadDias	= (G.DiasTrabajados - G.DescontarDias) * @FactorDias,
		TotalPTU		= (case when (ISNULL(G.Sindical,0) = 0) and (((G.SalarioDiario) * @FactorMonto) > @TopeSindical) and @TopeSindical >0.00 then @TopeSindical else ((G.SalarioDiario * @FactorMonto))END)+((G.DiasTrabajados - G.DescontarDias) * @FactorDias),
		VigenteHoy		= M.Vigente
	into #tempData
	from #tempDataEmpleadosGeneral G
		inner join RH.tblEmpleadosMaster m
			on G.IDEmpleado = M.IDEmpleado

	if(@Aplicar = 1)
	BEGIN
		--Synchronize the target table with refreshed data from source table
		MERGE Nomina.tblPTUEmpleados AS TARGET
			USING #tempData AS SOURCE 
				ON (TARGET.IDPTU = @IDPTU) and (TARGET.IDEmpleado = SOURCE.IDEmpleado) 
			--When records are matched, update the records if there is any change
			WHEN MATCHED THEN UPDATE 
				SET 
					TARGET.CantidadMonto = SOURCE.CantidadMonto
					,TARGET.CantidadDias = SOURCE.CantidadDias 
			--When no records are matched, insert the incoming records from source table to target table
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT (IDPTU, IDEmpleado, CantidadMonto, CantidadDias) 
				VALUES (@IDPTU, SOURCE.IDEmpleado, SOURCE.CantidadMonto,SOURCE.CantidadDias)
			--When there is a row that exists in target and same record does not exist in source then delete this record target
			WHEN NOT MATCHED BY SOURCE 
		THEN DELETE;
	END

	Select * from #tempData
END
GO
