USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Intranet].[spDetalleDashboardNomina]
(
	@IDEmpleado int,
	@Ejercicio int,
	@Filtro Varchar(max)
)
AS
BEGIN

	DECLARE 
		@QueryTotal varchar(max),
		@QueryGeneral varchar(max),
		@IDFondoAhorro int,
		@IDTipoNomina int,
		@FechaIni date,
		@FechaFin date,
		@IDUsuario int,
		@IDIdioma varchar(20)
	;

	select @IDUsuario = IDUsuario
	from Seguridad.tblUsuarios
	where IDEmpleado = @IDEmpleado

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	if object_id('tempdb..##tempMesesDashboardNomina') is not null drop table ##tempMesesDashboardNomina;

	select IDMes, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	INTO ##tempMesesDashboardNomina
	from Nomina.tblCatMeses


	if (charindex('309', @Filtro) <> 0 or charindex('308', @Filtro) <> 0)
	begin
		select 
			@IDTipoNomina = IDTipoNomina
		from RH.tblEmpleadosMaster
		where IDEmpleado = @IDEmpleado

		select 
			@FechaIni		= cpInicial.FechaInicioPago
			,@FechaFin		= ISNULL(cpFinal.FechaFinPago,'9999-12-31')
		from Nomina.tblCatFondosAhorro cfa with (nolock)
			left join Nomina.tblCatPeriodos cpInicial with (nolock) on cfa.IDPeriodoInicial = cpInicial.IDPeriodo 
			left join Nomina.tblCatPeriodos cpFinal with (nolock) on cfa.IDPeriodoFinal = cpFinal.IDPeriodo 
		where cfa.IDTipoNomina = @IDTipoNomina and cfa.Ejercicio = @Ejercicio

		set @QueryTotal = '
			Select 
				ISNULL(SUM(DP.ImporteTotal1),0) as  Total
			from ##tempMesesDashboardNomina m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes
				left join Nomina.tblDetallePeriodo DP with (nolock)	
					on DP.IDPeriodo = P.IDPeriodo
				and DP.IDEmpleado ='+ CAST(@IDEmpleado as varchar(100)) + '
						AND P.Cerrado = 1 
			WHERE DP.IDConcepto in ('+@Filtro+') and p.FechaFinPago between '''+format(@FechaIni, 'yyyy-MM-dd')+''' and '''+format(@FechaFin, 'yyyy-MM-dd')+  ''''

		set @QueryGeneral = '
			Select 
				p.Ejercicio
				,M.IDMes as [Order]
				,cast(p.Ejercicio as varchar)+ '' - '' +M.Descripcion as Mes
				,ISNULL(SUM(DP.ImporteTotal1),0) as  Total
			from ##tempMesesDashboardNomina m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes
						and P.Cerrado = 1  
				left join Nomina.tblDetallePeriodo DP with (nolock)	
					on DP.IDPeriodo = P.IDPeriodo
				and DP.IDEmpleado = '+ CAST(@IDEmpleado as varchar(100)) + '
					and DP.IDConcepto in ('+@Filtro+')
			where p.FechaFinPago between '''+format(@FechaIni, 'yyyy-MM-dd')+''' and '''+format(@FechaFin, 'yyyy-MM-dd')+ '''			 	 
			GROUP BY  p.Ejercicio, m.IDMes, m.Descripcion
			order by p.Ejercicio, m.IDMes'
	end else
	begin
		set @QueryTotal = '
			Select 
				ISNULL(SUM(DP.ImporteTotal1),0) as  Total
			from ##tempMesesDashboardNomina m
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes
				left join Nomina.tblDetallePeriodo DP with (nolock)	
					on DP.IDPeriodo = P.IDPeriodo
				and DP.IDEmpleado ='+ CAST(@IDEmpleado as varchar(100)) + '
						AND P.Ejercicio = '+ CAST(@Ejercicio as varchar(100)) + '
						AND P.Cerrado = 1 
			WHERE DP.IDConcepto in ('+@Filtro+')'

		set @QueryGeneral = '
			Select 
				M.IDMes as [Order]
				,M.Descripcion as Mes
				,ISNULL(SUM(DP.ImporteTotal1),0) as  Total
			from ##tempMesesDashboardNomina  m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes
						AND P.Ejercicio = '+ CAST(@Ejercicio as varchar(100)) + '
						and P.Cerrado = 1  
				left join Nomina.tblDetallePeriodo DP with (nolock)	
					on DP.IDPeriodo = P.IDPeriodo
				and DP.IDEmpleado = '+ CAST(@IDEmpleado as varchar(100)) + '
					and DP.IDConcepto in ('+@Filtro+')
						 	 
			GROUP BY m.IDMes, m.Descripcion
			order by m.IDMes'
	end
	
	exec (@QueryTotal)
	exec (@QueryGeneral)
END
GO
