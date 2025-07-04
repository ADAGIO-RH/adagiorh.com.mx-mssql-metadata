USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Salud].[spBuscarTemperaturaEmpleado](
	@IDEmpleado int,
	@IDUsuario int,
	@PageNumber int = 1,
	@PageSize int = 2147483647
) as
	declare @TotalPaginas int = 0;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if OBJECT_ID('tempdb..#tempTemperaturas') is not null drop table #tempTemperaturas;

	select 
		IDTemperaturaEmpleado
		,IDEmpleado
		,FechaHora
		,format(FechaHora,'dd/MM/yyyy') as FechaStr
		,format(FechaHora,'HH:mm:ss') as HoraStr
		,Temperatura
	INTO #tempTemperaturas
	from Salud.tblTemperaturaEmpleado with (nolock)
	where IDEmpleado = @IDEmpleado
	--order by FechaHora desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempTemperaturas

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempTemperaturas
		order by FechaHora desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
