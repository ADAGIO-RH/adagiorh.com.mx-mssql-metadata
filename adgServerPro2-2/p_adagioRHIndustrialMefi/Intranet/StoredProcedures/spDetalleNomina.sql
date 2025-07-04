USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare @dtFiltros Nomina.dtFiltrosRH
--insert into @dtFiltros values(N'IDEmpleado',N'1279')
--insert into @dtFiltros values(N'Ejercicio',N'2022')

--declare @dtPagination Nomina.dtFiltrosRH
--insert into @dtPagination values(N'PageNumber',N'1')
--insert into @dtPagination values(N'PageSize',N'100')
--insert into @dtPagination values(N'TotalPages',N'1')
--insert into @dtPagination values(N'query',NULL)
--insert into @dtPagination values(N'orderByColumn',NULL)
--insert into @dtPagination values(N'orderDirection',N'asc')

CREATE PROCEDURE [Intranet].[spDetalleNomina](
	@IDUsuario int 
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
	,@dtFiltros [Nomina].[dtFiltrosRH] READONLY    
) AS
BEGIN
	declare 	
		@IDEmpleado int
		,@Ejercicio int	
		,@orderByColumn	varchar(50) = 'FechaFinPago'
		,@orderDirection varchar(4) = 'asc'
	;

	if object_id('tempdb..#tempSetPagination') is not null drop table #tempSetPagination;
	
	SET @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)    	
	SET @Ejercicio = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),0)    	

	Select  @orderByColumn=isnull(Value,'FechaFinPago') from @dtPagination where Catalogo = 'orderByColumn'
	Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection';


	select 
		HEP.IDHistorialEmpleadoPeriodo as Folio,
		HEP.IDEmpleado,
		p.IDPeriodo,
		P.FechaFinPago,
		P.ClavePeriodo as Periodo,
		P.Descripcion as PeriodoNomina,
		p.Cerrado,
		isnull(T.IDEstatusTimbrado, 0) as IDEstatusTimbrado,
		cet.Descripcion as EstatusTimbrado,
		 
		(select isnull(SUM(DP.ImporteTotal1),0) 
			from Nomina.tblDetallePeriodo DP with (nolock)
				join Nomina.tblCatConceptos c with (nolock) on c.IDConcepto = DP.IDConcepto and c.Codigo like '%550'
			where DP.IDPeriodo = p.IDPeriodo and DP.IDEmpleado = @IDEmpleado) as TotalPercepciones, 
		(select isnull(SUM(DP.ImporteTotal1),0) 
			from Nomina.tblDetallePeriodo DP with (nolock) 
				join Nomina.tblCatConceptos c with (nolock) on c.IDConcepto = DP.IDConcepto and  c.IDTipoConcepto = 5	
			where DP.IDPeriodo = p.IDPeriodo and DP.IDEmpleado = @IDEmpleado) as TotalPagado,
		(select isnull(SUM(DP.ImporteTotal1),0) 
			from Nomina.tblDetallePeriodo DP with (nolock) 
				join Nomina.tblCatConceptos c with (nolock) on c.IDConcepto = DP.IDConcepto and c.Codigo like '%560'
			where DP.IDPeriodo = p.IDPeriodo and DP.IDEmpleado = @IDEmpleado) as TotalDeducciones,
		ROW_NUMBER()Over(Order by  
			case when @orderByColumn = 'Periodo'			and @orderDirection = 'asc'		then p.ClavePeriodo end ,
			case when @orderByColumn = 'Periodo'			and @orderDirection = 'desc'		then p.ClavePeriodo end desc
		)  as [row]
	INTO #tempSetPagination 
	from Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) 
		inner join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = HEP.IDPeriodo
		left join Facturacion.TblTimbrado T with (nolock) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo 
			 and isnull(T.Actual, 0) = 1
		left join Facturacion.tblCatEstatusTimbrado cet with (nolock) on cet.IDEstatusTimbrado = T.IDEstatusTimbrado
	where HEP.IDEmpleado = @IDEmpleado and isnull(p.Cerrado, 0) = 1 and p.Ejercicio = @Ejercicio and isnull(p.Finiquito,0)=0


	--with TOTALPERCEPCIONES as (
	--	Select 
	--		T.IDHistorialEmpleadoPeriodo
	--		,HEP.IDPeriodo
	--		,M.IDMes as [Order]
	--		,P.Descripcion as PeriodoNomina
	--		,DP.ImporteTotal1 as  TotalPercepciones
	--		,P.ClavePeriodo
	--		,DP.IDEmpleado	
	--	from  Facturacion.TblTimbrado T WITH(NOLOCK)
	--		inner join Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
	--		left join Nomina.tblCatPeriodos P with (nolock)	 on P.IDPeriodo = HEP.IDPeriodo
	--		inner join Nomina.tblCatMeses m with (nolock) on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1
	--		left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	--		and DP.IDEmpleado = @IDEmpleado 
	--		join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo = '550' 	
	--	WHERE -- T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO') and
	--		HEP.IDEmpleado= @IDEmpleado 	 
	--	), TOTALPAGADO as
	--	(
	--		Select 
	--			T.IDHistorialEmpleadoPeriodo
	--			,HEP.IDPeriodo
	--			,M.IDMes as [Order]
	--			,P.Descripcion as PeriodoNomina
	--			, DP.ImporteTotal1 as  TotalPagado
	--			,P.ClavePeriodo
	--			,DP.IDEmpleado
	--		from  Facturacion.TblTimbrado T WITH(NOLOCK)
	--			INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
	--			left join Nomina.tblCatPeriodos P with (nolock)	 on P.IDPeriodo = HEP.IDPeriodo
	--			inner join Nomina.tblCatMeses m with (nolock) on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1
	--			left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	--			and DP.IDEmpleado = @IDEmpleado 
	--			join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.IDTipoConcepto = 5	
	--		WHERE --T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO') and 
	--			HEP.IDEmpleado= @IDEmpleado 
	--	), TOTALDEDUCCIONES as
	--	(
	--		Select
	--			T.IDHistorialEmpleadoPeriodo
	--			,HEP.IDPeriodo
	--			,M.IDMes as [Order]
	--			,P.Descripcion as PeriodoNomina
	--			,DP.ImporteTotal1 as  TotalDeducciones
	--			,P.ClavePeriodo
	--			,DP.IDEmpleado
	--		from  Facturacion.TblTimbrado T WITH(NOLOCK)
	--			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
	--			left join Nomina.tblCatPeriodos P with (nolock)	 on P.IDPeriodo = HEP.IDPeriodo
	--			inner join Nomina.tblCatMeses m with (nolock) on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1
	--			left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	--				and DP.IDEmpleado = @IDEmpleado 
	--			join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo = '560' 	
	--		WHERE --  T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO') and 
	--			HEP.IDEmpleado= @IDEmpleado 
	--	)
	
	--select 
	--	ROW_NUMBER()Over(Order by  
	--		case when @orderByColumn = 'Periodo'			and @orderDirection = 'asc'		then TP.ClavePeriodo end ,
	--		case when @orderByColumn = 'Periodo'			and @orderDirection = 'desc'		then TP.ClavePeriodo end desc
	--	)  as [row],
	--	TP.IDHistorialEmpleadoPeriodo as Folio,
	--	TP.IDPeriodo as IDPeriodo,
	--	TP.ClavePeriodo as Periodo,
	--	TP.IDEmpleado as IDEmpleado,
	--	Tp.PeriodoNomina as PeriodoNomina,				
	--	SUM(isnull(TP.TotalPercepciones	, 0)) as TotalPercepciones, 
	--	SUM(isnull(TPA.TotalPagado		, 0)) as TotalPagado,
	--	SUM(isnull(TD.TotalDeducciones	, 0)) as TotalDeducciones
	--into #tempSetPagination
	--from TOTALPERCEPCIONES TP
	--	left join TOTALPAGADO TPA on TPA.ClavePeriodo = TP.ClavePeriodo
	--	left join TOTALDEDUCCIONES TD on TD.ClavePeriodo = TP.ClavePeriodo
	--group by Tp.PeriodoNomina, 
	--	TP.ClavePeriodo,
	--	TP.IDHistorialEmpleadoPeriodo,
	--	TP.IDPeriodo,
	--	TP.IDEmpleado 


	if exists(select top 1 * from @dtPagination)
	BEGIN
		exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
	end
	else 
	begin 
		select  * From #tempSetPagination order by row desc
	end
	
END
GO
