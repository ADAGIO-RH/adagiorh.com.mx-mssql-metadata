USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare 
--	@dtFiltros [Nomina].[dtFiltrosRH]  
--	;
--	insert @dtFiltros
--	values('TipoVigente','1')
--exec [Reportes].[spBuscarEmpleadosInfonavitTabla] @IDUsuario = 1,@dtFiltros=@dtFiltros
--GO

CREATE procedure [Reportes].[spReporteDiasTrabajados] (
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int  
)
AS
BEGIN

	DECLARE  
		@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null
		,@Ejercicio int 
		,@IDCliente int
		,@IDRazonSocial int 
		,@DiasDescontar varchar(MAX)
		,@FechaIni date
		,@FechaFin date
		,@IDTipoNomina int

   ;   
   

	set @IDCliente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Cliente'),'0'),','))
	set @IDRazonSocial = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'RazonesSociales'),'0'),','))
	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'	
	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	--select @DiasDescontar = CAST(CASE WHEN ISNULL(Value,'') = '' THEN NULL ELSE  Value END as varchar(MAX))
	--	from @dtFiltros where Catalogo = 'Ausentismos'	
 


	select top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)        
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = 1 and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	DECLARE 
		@IDEmpresa int,
		@ConceptosIntegranSueldo varchar(max),
		@DescontarIncapacidades bit = 0,
		@TiposIncapacidadesADescontar varchar(max),
		@CantidadGanancia Decimal(18,4),
		@CantidadRepartir Decimal(18,4),
		@CantidadPendiente Decimal(18,4),
		@DiasMinimosTrabajados int,
		@EjercicioPago int,
		@IDPeriodo	int,
		@TotalRepartir Decimal(18,4),
		@MontoSueldo Decimal(18,2),
		@MontoDias Decimal(18,2),
		@FactorSueldo decimal(18,9),
		@FactorDias decimal(18,9),
		@IDEmpleadoTipoSalarioMensualConfianza int,
		@dtEmpleados RH.dtEmpleados,
		@TopeSindical decimal(18,2),
		@TopeSalarioAnual decimal(18,2),
		@TopeConfianza decimal(18,2),
		@dtFechas app.dtFechas, 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCalcularPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTUEmpleados]',
		@Accion		varchar(20)	= 'EJECUCIÓN CÁLCULO PTU'
	;	


	insert into @dtFechas  
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin 

	insert into @dtEmpleados
	Exec RH.spBuscarEmpleados
		 @FechaIni  = @FechaIni,                
		 @Fechafin  = @FechaFin,                
		 @dtFiltros = @dtFiltros,
		 @IDUsuario = @IDUsuario





	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
  
	create Table #tempVigenciaEmpleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  
	     
	insert into #tempVigenciaEmpleados  
	Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1  

	delete  #tempVigenciaEmpleados where Vigente = 0


	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil      
      
	select 
		IDEmpleado
		,FechaAlta
		,FechaBaja             
		,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso              
		,IDMovAfiliatorio      
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
                and mBaja.Fecha <= @FechaFin               
      order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,              
        case when (IDEmpleado is not null) then (select top 1 Fecha               
                 from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)              
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento              
                 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'                
                and mReingreso.Fecha <= @FechaFin               
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
		,ee.FechaIni
		,ee.FechaFin 
		,FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as FechaAntiguedad
		,FechaInicioHistoria = 
			case when MA.FechaReingreso is not null and MA.FechaReingreso > MA.FechaAlta and MA.FechaReingreso between @fechaini and @FechaFin then MA.FechaReingreso 
				when MA.FechaAlta > @FechaIni then MA.FechaAlta
			else @FechaIni end
		,FechaFinHistoria = 
			case when ISNULL(em.Vigente, 0) = 0 and MA.FechaBaja between @FechaIni and @FechaFin then MA.FechaBaja
			else @FechaFin end
		,e.IDTipoPrestacion
		,TP.Descripcion as TipoPrestacion
		,tp.Sindical
		,CASE WHEN em.Vigente = 1 THEN 'SI' ELSE 'NO' END as VIGENTE
	into #tempDataEmpleados
	from @dtEmpleados e
		join RH.tblEmpleadosMaster em with (nolock) on em.IDEmpleado = e.IDEmpleado
		inner join #tempMovAfil MA on MA.IDEmpleado = e.IDEmpleado
		left join rh.tblEmpresaEmpleado EE with (nolock) on e.IDEmpleado = ee.IDEmpleado
			and EE.FechaIni<= @FechaFin and EE.FechaFin >= @FechaFin   
			and EE.IDEmpresa = @IDEmpresa
		inner join RH.tblCatTiposPrestaciones TP with (nolock) on TP.IDTipoPrestacion = e.IDTipoPrestacion
	ORDER BY E.ClaveEmpleado



	if object_id('tempdb..#tempAusentismos')	is not null drop table #tempAusentismos 
	if object_id('tempdb..#tempData')		is not null drop table #tempData

	select distinct 
		INC.IDIncidencia,
		replace(replace(replace(replace(replace(Substring(INC.IDIncidencia,0,21)+'_'+INC.Descripcion,' ','_'),'-',''),'.',''),'(',''),')','') as INCIDENCIA,
		INC.Orden as Orden
	into #tempAusentismos
	from (select 
			 I.IDIncidencia
			,I.Descripcion
			,1 as Orden
		from Asistencia.tblCatIncidencias I with (nolock) 
			where IDIncidencia in ('FF', 'F','S','P', 'I')
			-- I.IDIncidencia in (select item from App.split(@DiasDescontar, ','))
		--UNION
		--select 
		--	 I.IDIncidencia +'_'+ CI.Codigo
		--	,I.Descripcion +'_'+ CI.Nombre
		--	,0 as Orden
		--from Asistencia.tblCatIncidencias I with (nolock) 
		--	cross apply IMSS.tblCatClasificacionesIncapacidad CI
		--	where ISNULL(I.EsAusentismo,0) = 1
		--	and I.IDIncidencia = 'I'
		)INC 


		Select
		e.IDEmpleado		as IDEmpleado,
		e.ClaveEmpleado		as CLAVE,
		e.NOMBRECOMPLETO	as NOMBRE,
		e.Empresa			as [RAZON SOCIAL],
		e.Sucursal			as SUCURSAL,
		e.Departamento		as DEPARTAMENTO,
		e.Puesto			as PUESTO,
		e.Division			as DIVISION,
		e.CentroCosto		as CENTRO_COSTO,
		FORMAT(e.FechaAntiguedad,'dd/MMM/yyyy') as ANTIGUEDAD,
		A.IDIncidencia		,
		A.INCIDENCIA,
		A.ORDEN,
		COUNT(*) as TOTALAUSENTISMOS
	into #tempData
	from @dtEmpleados E
		inner join Asistencia.tblIncidenciaEmpleado IE with(nolock)
			on E.IDEmpleado = IE.IDEmpleado
		left join Asistencia.tblIncapacidadEmpleado INCEmpleado with(nolock)
			on IE.IDIncapacidadEmpleado = INCEmpleado.IDIncapacidadEmpleado
		left join IMSS.tblCatClasificacionesIncapacidad CINC with(nolock)
			on CINC.IDClasificacionIncapacidad = INCEmpleado.IDTipoIncapacidad
		inner join #tempAusentismos A with(nolock)
			on A.IDIncidencia = IE.IDIncidencia /*+ CASE WHEN CINC.Codigo IS NOT NULL THEN +'_'+ CINC.Codigo ELSE '' END*/
	WHERE IE.Fecha BETWEEN @FechaIni and @FechaFin
	and ISNULL(IE.Autorizado,0) = 1
	Group by e.ClaveEmpleado
		,e.NOMBRECOMPLETO,
		e.Empresa,
		e.Sucursal ,
		e.Departamento,
		e.Puesto,
		e.Division,
		e.CentroCosto,
		e.CentroCosto,
		A.IDIncidencia,
		A.INCIDENCIA,
		A.ORDEN,
		e.FechaAntiguedad,
		e.IDEmpleado
	ORDER BY e.ClaveEmpleado ASC

	if object_id('tempdb..#tempDataEmpleadosGeneral') is not null drop table #tempDataEmpleadosGeneral

	select d.* 
		--, (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) DiasVigencia
		, (select count(*) from #tempVigenciaEmpleados where IDEmpleado = d.IDEmpleado ) DiasVigencia
		, 0 as DiasADescontar
		, 0 as Incapacidades
		, 0 as DiasTrabajados
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,@ConceptosDiasDescontar,FechaInicioHistoria,FechaFinHistoria) as DescontarDias
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'I',FechaInicioHistoria,FechaFinHistoria) as Incapacidades
		--, Asistencia.fnBuscarIncidenciasEmpleado(IDEmpleado,'F',FechaInicioHistoria,FechaFinHistoria) as Faltas
	into #tempDataEmpleadosGeneral
	from #tempDataEmpleados d with (nolock)
	--WHERE (DATEDIFF(day, FechaInicioHistoria, FechaFinHistoria)+1) >= @DiasMinimosTrabajados 
  


	update temp_data
		set temp_data.DiasADescontar = (select COUNT(IDIncidencia) 
										from Asistencia.tblIncidenciaEmpleado ie 
										where ie.IDIncidencia in ('FF', 'F','S','P', 'I')
											and ie.Fecha between @FechaIni and @FechaFin
											and ie.IDEmpleado = temp_data.IDEmpleado
											and isnull(ie.Autorizado,0) = 1
										)
										
			
	from #tempDataEmpleadosGeneral temp_data



	update #tempDataEmpleadosGeneral
		set DiasTrabajados = isnull(DiasVigencia,0) - (isnull(Incapacidades,0) + isnull(DiasADescontar,0))


	--select 
	--e.claveempleado as [CLAVE EMPLEADO],
	--e.nombreCompleto as NOMBRE,
	--incidencias.DiasADescontar as AUSENTISMOS,
	--incidencias.DiasTrabajados as [DIAS TRABAJADOS]
	--from
	--	@dtEmpleados e
	--	inner join #tempDataEmpleadosGeneral incidencias on incidencias.IDEmpleado = e.IDEmpleado
	
	--select COUNT(ie.IDEmpleado) Total,ci.Descripcion, empl.ClaveEmpleado 
	--	from Asistencia.tblIncidenciaEmpleado ie
	--		inner join Asistencia.tblCatIncidencias ci with(nolock) 
	--			on ie.IDIncidencia = ci.IDIncidencia 
	--		inner join rh.tblEmpleados empl with(nolock) 
	--			on ie.IDEmpleado = empl.IDEmpleado
	--	where ie.Fecha between @FechaIni and @FechaFin
	--	group by ie.IDEmpleado,ci.IDIncidencia, ci.Descripcion, ie.IDIncidencia, empl.ClaveEmpleado


	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(A.Incidencia)+',0) AS '+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT ClaveEmpleado as [CLAVE], NOMBRECOMPLETO as NOMBRE, FechaAntiguedad [FECHA ANTIGUEDAD], SUCURSAL, DEPARTAMENTO, PUESTO, SalarioDiario as [SALARIO DIARIO], VIGENTE, 
		DiasVigencia as [DIAS VIGENCIA], ' + @cols + ', DiasTrabajados as [DIAS TRABAJADOS] from 
				(
					select general.*, isnull(data.TOTALAUSENTISMOS,0) as TOTALAUSENTISMOS,  data.incidencia
					from #tempDataEmpleadosGeneral general
						left join #tempData data
							on general.idempleado = data.idempleado
			   ) x'


	set @query2 = '
				pivot 
				(
					 SUM(TOTALAUSENTISMOS)
					for INCIDENCIA in (' + @colsAlone + ')
				) p 
				order by CLAVE
				'

	--select len(@query1) +len( @query2) 
	--print( @query1 + @query2) 	
	exec( @query1 + @query2)


END
GO
