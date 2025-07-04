USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spStaffing](
		@FechaIni date
	   ,@FechaFin date
)as
--declare @FechaIni date = '2019-01-01'
--	   ,@FechaFin date = '2019-02-28'
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	SET DATEFIRST 7;

	--set @Duracion = (@Duracion - 1);
    
    declare 
		@Fechas [App].[dtFechas]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null

	   ,@dtFiltros [Nomina].[dtFiltrosRH] 
		,@dtEmpleados RH.dtEmpleados
		,@IDUsuario int = 1
		,@TotalDias decimal(18,2) = datediff(DAY,@FechaIni,@FechaFin)


	--insert into @dtFiltros(Catalogo,Value)  
	--values('Empleados','18246,20087')  

	set @IdiomaSQL = 'Spanish' ;
  
	SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;    
	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);

	insert @dtEmpleados
	exec [RH].[spBuscarEmpleados] 
		@FechaIni = @FechaIni         
		,@Fechafin = @FechaFin           
		,@IDUsuario = 1       
		,@dtFiltros=@dtFiltros

	insert into @Fechas(Fecha)
	exec [App].[spListaFechas]
		@FechaIni = @FechaIni
		,@FechaFin = @FechaFin


	--select * from @Fechas
	insert #tempDiasVigencias
	exec RH.spBuscarListaFechasVigenciaEmpleado  
		@dtEmpleados = @dtEmpleados 
		,@Fechas = @Fechas
		,@IDUsuario = @IDUsuario 

	delete from #tempDiasVigencias where Vigente = 0

	if object_id('tempdb..#tempDiv') is not null drop table #tempDiv;
	if object_id('tempdb..#tempDepto') is not null drop table #tempDepto;
	if object_id('tempdb..#tempPuesto') is not null drop table #tempPuesto;
	if object_id('tempdb..#tempFinal') is not null drop table #tempFinal;

	-- 2019	1	Enero	ADAGIO	ADMINISTRACION	ADMINISTRADOR GENERAL	62	2.00
	select f.Fecha,de.IDDivision,de.IDEmpleado,1 TOTAL
	INTO #tempDiv
	from #tempDiasVigencias f 
		JOIN [RH].tblDivisionEmpleado DE WITH(NOLOCK)              
			on DE.FechaIni<= f.Fecha and dE.FechaFin >=  f.Fecha and de.IDEmpleado = f.IDEmpleado
		 
		--join @Fechas ff on f.Fecha = ff.Fecha
	    
		--select * 
		--from #tempDiv 
		--where IDEmpleado = 1 order by Fecha, IDEmpleado

		--return
	select f.Fecha,de.IDDepartamento,de.IDEmpleado,1 as TOTAL
	INTO #tempDepto
	from #tempDiasVigencias f 
		JOIN [RH].tblDepartamentoEmpleado DE WITH(NOLOCK)              
			on DE.FechaIni<= f.Fecha and dE.FechaFin >=  f.Fecha and de.IDEmpleado = f.IDEmpleado
	    
	select f.Fecha,de.IDPuesto,de.IDEmpleado,1 as  TOTAL
	INTO #tempPuesto
	from #tempDiasVigencias f  
	   JOIN [RH].tblPuestoEmpleado DE WITH(NOLOCK)              
		on DE.FechaIni<= f.Fecha and dE.FechaFin >=  f.Fecha  
			and de.IDEmpleado = f.IDEmpleado

	    -- 14468
--select * from RH.tblEmpleadosMaster	where IDEmpleado in (20087,18246) --18246

	--select *
	--from #tempDiv d
	--	left join #tempDepto depto on d.IDEmpleado = depto.IDEmpleado and d.Fecha = depto.Fecha
	--	left join #tempPuesto p on d.IDEmpleado = p.IDEmpleado and d.Fecha = p.Fecha

	select datepart(YEAR,d.Fecha)as ANIO,datepart(MONTH,d.Fecha)as MES,DATENAME(MONTH,d.Fecha) as NombreMes,datepart(day,d.Fecha) DIA,IDDivision,IDDepartamento,IDPuesto,SUM(d.TOTAL)  as Total
	INTO #tempFinal
	from #tempDiv d
		left join #tempDepto depto on d.IDEmpleado = depto.IDEmpleado and d.Fecha = depto.Fecha
		left join #tempPuesto p on d.IDEmpleado = p.IDEmpleado and d.Fecha = p.Fecha		
	group by  datepart(YEAR,d.Fecha),datepart(MONTH,d.Fecha),DATENAME(MONTH,d.Fecha),datepart(day,d.Fecha),IDDivision,IDDepartamento,IDPuesto
	order by datepart(MONTH,d.Fecha),datepart(day,d.Fecha),IDDivision,IDDepartamento,IDPuesto

	--select * from #tempFinal order by MES, DIA

	select ANIO,
    MES,NombreMes,
    JSON_VALUE(divi.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Division,
    JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as Departamento, 
    JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto,
    sum(Total) TOTAL,cast(sum(Total)/@TotalDias as decimal(18,2)) as [AVG]--,CAST(AVG(Total) AS DECIMAL(10,2)) [AVG]
	from #tempFinal f
		left join RH.tblCatDepartamentos d on f.IDDepartamento =d.IDDepartamento
		left join RH.tblCatDivisiones divi on f.IDDivision=  divi.IDDivision
		left join RH.tblCatPuestos p on f.IDPuesto =  p.IDPuesto
	group by ANIO,MES,NombreMes,divi.Descripcion ,d.Descripcion, p.Descripcion 
	--order by ANIO,MES,divi.Descripcion,avg(Total) desc
	--OFFSET 0 ROWS  
	--select datepart(MONTH,Fecha)as MES,datepart(day,Fecha) DIA,IDDivision,SUM(TOTAL) 
	--from #temp
	--group by datepart(MONTH,Fecha),datepart(day,Fecha),IDDivision
	--order by datepart(MONTH,Fecha),datepart(day,Fecha),IDDivision

	
	--select * from [RH].[tblDepartamentoEmpleado] where IDEmpleado in (20087,7334) order by fechaIni
	-- select * from [RH].[tblDivisionEmpleado] where IDEmpleado in (20087) order by fechaIni


		--select IDEmpleado,IDDepartamento,Count(*)
		--from [RH].[tblDepartamentoEmpleado]
		--group by IDEmpleado,IDDepartamento
		--order by Count(*) desc

		--select IDEmpleado,IDDivision,Count(*)
		--from [RH].tblDivisionEmpleado
		--group by IDEmpleado,IDDivision
		--order by Count(*) desc
GO
