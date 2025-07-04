USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Dashboard].[spBuscarAltasBajasReingresoVue](
		@dtFiltros [Nomina].[dtFiltrosRH] readonly,
		@IDUsuario int  
) as
	--declare 
	--	@dtFiltros [Nomina].[dtFiltrosRH],
	--	@IDUsuario int  = 1

	--insert @dtFiltros
	--values 
	--	('FechaIni','2023-01-01')
	--	,('FechaFin','2023-01-31')

	declare
		@dtEmpleados [RH].[dtEmpleados]
		,@FechaIni date
		,@FechaFin date
		,@dtFechas [App].[dtFechas]
		,@IDIdioma varchar(10)
	   ,@IdiomaSQL varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = i.[SQL]
	from App.tblIdiomas i
	where i.IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;



	set @FechaIni = isnull((SELECT top 1 cast([Value] as date) from @dtFiltros where Catalogo = 'FechaIni'),'1990-01-01')
	set @FechaFin = isnull((SELECT top 1 cast([Value] as date) from @dtFiltros where Catalogo = 'FechaFin'),'9999-12-31')

	insert @dtFechas
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleadosMaster] 
		@FechaIni	= @FechaIni
		,@FechaFin	= @FechaFin
		,@dtFiltros = @dtFiltros
		,@IDUsuario	= @IDUsuario

---- ALTAS

	IF OBJECT_ID('tempdb..#tmpResultAltas') IS NOT NULL
	BEGIN
		DROP TABLE #tmpResultAltas;
	END

	CREATE TABLE #tmpResultAltas (Fecha DATE, data INT);

	INSERT INTO #tmpResultAltas
	SELECT 
		   f.Fecha
		    ,isnull(Total,0)
		from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'A'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov
---- ALTAS
---- BAJAS
	IF OBJECT_ID('tempdb..#tmpResultBajas') IS NOT NULL
	BEGIN
		DROP TABLE #tmpResultBajas;
	END

	CREATE TABLE #tmpResultBajas (Fecha DATE, data INT);

	INSERT INTO #tmpResultBajas
	SELECT 
		   f.Fecha
		   ,isnull(Total,0)
		from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'B'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov
---- BAJAS
---- REINGRESO
	IF OBJECT_ID('tempdb..#tmpResultReingreso') IS NOT NULL
	BEGIN
		DROP TABLE #tmpResultReingreso;
	END

	CREATE TABLE #tmpResultReingreso (Fecha DATE, data INT);

	INSERT INTO #tmpResultReingreso
	SELECT 
		   f.Fecha
		    ,isnull(Total,0)
		from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'R'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov
---- REINGRESO


-- Consulta original (agrupa por Fecha)
SELECT 
    'Altas' as label	
    , '#446db2'  borderColor
    , CONCAT('[', 
      STUFF(
        (
          SELECT ',' + CAST(data AS VARCHAR(50))
          FROM #tmpResultAltas AS tmp
          FOR XML PATH('')
        ),
        1,
        1,
        ''
      ) ,']') AS data
UNION
SELECT 
    'Bajas' as label	
    , '#b24444'  borderColor
    , CONCAT('[', 
      STUFF(
        (
          SELECT ',' + CAST(data AS VARCHAR(50))
          FROM #tmpResultBajas AS tmp
          FOR XML PATH('')
        ),
        1,
        1,
        ''
      ) ,']') AS data
UNION
SELECT 
    'Reingresos' as label	
    , '#b29b44'  borderColor
    , CONCAT('[', 
      STUFF(
        (
          SELECT ',' + CAST(data AS VARCHAR(50))
          FROM #tmpResultReingreso AS tmp
          FOR XML PATH('')
        ),
        1,
        1,
        ''
      ) ,']') AS data

SELECT CASE WHEN @IDIdioma = 'es-MX' THEN FORMAT(Fecha,'dd/MM/yyyy')
			WHEN @IDIdioma = 'en-US' THEN FORMAT(Fecha,'MM/dd/yyyy')
			ELSE FORMAT(Fecha,'yyyy-MM-dd')
			END Fecha
FROM @dtFechas
GO
