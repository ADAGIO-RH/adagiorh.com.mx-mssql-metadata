USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [Asistencia].[spBuscarHorarioVue](
    @IDHorario int = null
    ,@IDUsuario int
	,@PageNumber INT = 1
	,@PageSize INT = 2147483647
    ,@query			VARCHAR(100) = '""'
	,@orderByColumn VARCHAR(50) = 'Turno'
	,@orderDirection VARCHAR(4) = 'asc'
) as
	SET FMTONLY OFF;
	DECLARE  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int,
	   @IDIdioma varchar(20)
	;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Turno' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


    SET @query = CASE 
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				 ELSE '"'+@query + '*"' END

	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;

    select ch.IDHorario
	   ,ch.Codigo
	   , isnull(ch.IDTurno,0) as IDTurno
	   , isnull(ct.Descripcion,'Sin turno') as Turno
	   , ch.Descripcion
	   , CONVERT(VARCHAR(8), CONVERT(VARCHAR(8), HoraEntrada, 108)) AS HoraEntrada
	   , ch.HoraSalida
	   ,ch.TiempoTotal
	   ,ch.TiempoDescanso
	   , ch.JornadaLaboral
	into #tempHorarios
    from [Asistencia].[tblCatHorarios] ch with (nolock)
	   join [Asistencia].[tblCatTurnos] ct with (nolock) on ch.IDTurno = ct.IDTurno
    where (ch.IDHorario = @IDHorario or @IDHorario is null)
    and ( (@query = '""' or contains(ch.*, @query)))

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempHorarios

	select @TotalRegistros = CAST(count(IDHorario) AS DECIMAL(18,2)) from #tempHorarios

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempHorarios
	order by
		case when @orderByColumn = 'Turno'	and @orderDirection = 'asc'	then Turno end,			
		case when @orderByColumn = 'Turno'	and @orderDirection = 'desc'then Turno end desc,
		IDHorario asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
