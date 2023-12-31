USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spCrearChecadasHorariosyDescansos] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')    
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	declare
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@Orden Varchar(max)
			,@contador INT
			,@fecha_ini date
	;
	


	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
	from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaIni'
	
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaFin'

	select @Orden = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'Orden'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	SET @contador = 1
	SET @fecha_ini = @FechaIni

	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados

	select distinct 
		c.IDDatoExtra,
		C.Nombre,
		C.Descripcion
	into #tempDatosExtra
	from (
		select *
		from RH.tblCatDatosExtra
	) c 

	Select
		M.IDEmpleado
		,CDE.IDDatoExtra
		,CDE.Nombre
		,CDE.Descripcion
		,DE.Valor
	into #tempData
	from RH.tblEmpleadosMaster M
		left join RH.tblDatosExtraEmpleados DE on M.IDEmpleado = DE.IDEmpleado
		left join RH.tblCatDatosExtra CDE on DE.IDDatoExtra = CDE.IDDatoExtra

	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT IDEmpleado as [No. Sys] ' + coalesce(','+@cols, '') + ' 
					into ##tempDatosExtraEmpleados
					from 
				(
					select IDEmpleado
						,Nombre
						,Valor
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 MAX(Valor)
					for Nombre in (' + coalesce(@colsAlone, 'NO_INFO')  + ')
				) p 
				order by IDEmpleado
				'

	exec( @query1 + @query2) 

	if object_id('tempdb..#dias_entre_fechas') is not null
		drop table #dias_entre_fechas

	if object_id('tempdb..#checadasIngreso') is not null
		drop table #checadasIngreso

	if object_id('tempdb..#checadasET') is not null
		drop table #checadasET

	CREATE TABLE #dias_entre_fechas (
		diaDeSemana int,
		fecha DATE
	);

	begin
		WHILE @fecha_ini <= @FechaFin
			BEGIN
			INSERT INTO #dias_entre_fechas (diaDeSemana,fecha)
			VALUES ( datepart (dw,@fecha_ini), @fecha_ini )
    
			SET @contador = @contador + 1
			SET @fecha_ini = DATEADD(day, 1, @fecha_ini)
		END
	end

	select 
		distinct CONVERT(VARCHAR(5), fecha, 108) as hora 
		into #checadasET
	from Asistencia.tblChecadas where IDTipoChecada = 'ET'

	IF ( @ClaveEmpleadoInicial <> 0 )
	BEGIN
			insert into @dtEmpleados
			Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@IDUsuario=@IDUsuario
			select 
				*
			from @dtEmpleados m
		END

		ELSE IF ( @ClaveEmpleadoInicial = 0 )
		BEGIN
			if(@IDTipoVigente = 1)
			BEGIN
				insert into @dtEmpleados
				Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

				--Horas de entrada
				select m.ClaveEmpleado, diasfechas.diaDeSemana, convert ( datetime, CONVERT(varchar(10), diasfechas.fecha, 120) + ' '+ CONVERT(varchar(8),hora, 108) ) AS fecha_hora
					--into #checadasIngreso
					from @dtEmpleados m
						cross join #dias_entre_fechas diasfechas
						inner join #checadasET on hora is not null
				where diasfechas.diaDeSemana not in (6,7) 

					
			END
			ELSE IF(@IDTipoVigente = 2)
			BEGIN
				insert into @dtEmpleados
				exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
				select *
				from RH.tblEmpleadosMaster M with (nolock)
				
			END ELSE IF(@IDTipoVigente = 3)
			BEGIN
				select *
				
				from RH.tblEmpleadosMaster M with (nolock) 
				
			END
		END
	END
GO
