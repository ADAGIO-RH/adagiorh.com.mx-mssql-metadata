USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarArticulosDevueltos](
	@IDusuario int,
	@IDEmpleado int,
	@PageNumber INT = 1,
	@PageSize INT = 2147483647,
	@orderByColumn VARCHAR(50) = 'FechaHoraRecibido',
	@orderDirection VARCHAR(4) = 'desc'
)
as
begin
	SET FMTONLY OFF;
	declare @IDIdioma varchar(20), @Empleado VARCHAR(40), @TotalPaginas int = 0, @TotalRegistros int;
	DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	if object_id('tempdb..#ArticulosDevueltos') is not null drop table #ArticulosDevueltos;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'FechaHoraRecibido' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	select 
		hea.IDEstatusArticulo as IDHistorialEstatusArticulo,
		hea.IDCatEstatusArticulo,
		cea.Nombre as NombreEstatusArticulo,
		--hea.IDArticulo,
		--a.Nombre as Articulo,
		hea.FechaHora as FechaHoraRecibido,
		hea.IDUsuario,
		U.Nombre
	into #ArticulosDevueltos
	from ControlEquipos.tblEstatusArticulos hea
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = hea.IDCatEstatusArticulo
	left join Seguridad.tblUsuarios U on U.IDUsuario = hea.IDUsuario
--	left join ControlEquipos.tblArticulos a on a.IDArticulo = hea.IDArticulo
	where hea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_ASIGNADO
	and @IDEmpleado in (
	select *
	from OPENJSON(Empleados, '$')
	with (
		IDEmpleado int
		)
	)
	order by hea.FechaHora desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #ArticulosDevueltos
	select @TotalRegistros = count(IDArticulo) from #ArticulosDevueltos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #ArticulosDevueltos
	order by
		case when @orderByColumn = 'FechaHoraRecibido'	and @orderDirection = 'asc'	then FechaHoraRecibido end,			
		case when @orderByColumn = 'FechaHoraRecibido'	and @orderDirection = 'desc'then FechaHoraRecibido end desc,
		FechaHoraRecibido asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end


/*
exec [ControlEquipos].[spBuscarArticulosDevueltos]
	@IDusuario = 1
	,@IDEmpleado = 1279
	,@PageNumber = 1
	,@PageSize = 10
	,@orderByColumn = 'FechaHoraRecibido'
	,@orderDirection = 'desc'



*/
GO
