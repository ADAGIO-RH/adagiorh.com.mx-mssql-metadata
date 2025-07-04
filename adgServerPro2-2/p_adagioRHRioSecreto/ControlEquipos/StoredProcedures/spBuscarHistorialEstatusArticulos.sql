USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarHistorialEstatusArticulos] (
	@IDArticulo int=0,
	@IDusuario int,
	@PageNumber INT = 1,
	@PageSize INT = 2147483647,
    @query VARCHAR(4000) = '""',
	@orderByColumn VARCHAR(50) = 'FechaHoraActualizacion',
	@orderDirection VARCHAR(4) = 'desc'
)
as
begin
	SET FMTONLY OFF;
	declare @IDIdioma varchar(20), @TotalPaginas int = 0, @TotalRegistros int
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	if object_id('tempdb..#HistorialEstatusArticulos') is not null drop table #HistorialEstatusArticulos;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

    set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end


	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'FechaHoraActualizacion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 


		
	select 
		a.Nombre as Articulo,
        DA.Etiqueta as Etiqueta,
		hea.IDEstatusArticulo as IDHistorialEstatusArticulo,
		hea.IDCatEstatusArticulo,
		cea.Nombre as NombreEstatusArticulo,
		--hea.IDArticulo,
		hea.FechaHora as FechaHoraActualizacion,
		hea.IDUsuario,
		U.Nombre,	
		ISNULL((
        SELECT 
			em.IDEmpleado,
            em.ClaveEmpleado,
            em.NombreCompleto,
			em.ClaveNombreCompleto,
            SUBSTRING(em.Nombre, 1, 1) + SUBSTRING(em.Paterno, 1, 1) AS Iniciales,
			em.Puesto
        FROM OPENJSON(hea.Empleados) WITH (
            IDEmpleado INT '$.IDEmpleado'
        ) AS ej
        JOIN RH.tblEmpleadosMaster em ON em.IDEmpleado = ej.IDEmpleado
        FOR JSON PATH
    ), '[{"Estatus":"Sin asignar","ClaveEmpleado":"No Aplica","NombreCompleto":"No Aplica","IDEmpleado":"No Aplica"}]') AS Empleados
	into #HistorialEstatusArticulos
	from ControlEquipos.tblArticulos A
	left join ControlEquipos.tblDetalleArticulos DA on A.IDArticulo = DA.IDArticulo
	left JOIN ControlEquipos.tblEstatusArticulos hea on  DA.IDDetalleArticulo = hea.IDDetalleArticulo
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = hea.IDCatEstatusArticulo
	left join Seguridad.tblUsuarios U on U.IDUsuario = hea.IDUsuario
    WHERE (@query = '""' or contains (A.*, @query))
	order by hea.FechaHora desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #HistorialEstatusArticulos
	select @TotalRegistros = count(IDHistorialEstatusArticulo) from #HistorialEstatusArticulos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #HistorialEstatusArticulos
	order by
		case when @orderByColumn = 'FechaHoraActualizacion'	and @orderDirection = 'asc'	then FechaHoraActualizacion end,			
		case when @orderByColumn = 'FechaHoraActualizacion'	and @orderDirection = 'desc'then FechaHoraActualizacion end desc,
		FechaHoraActualizacion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end


/*

exec [ControlEquipos].[spBuscarHistorialEstatusArticulos]
	@IDArticulo = 4
	,@IDusuario = 1
	,@PageNumber = 1
	,@PageSize = 10
	,@orderByColumn = 'FechaHoraActualizacion'
	,@orderDirection = 'desc'


*/
GO
