USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Reportes].[spReporteBasicoCatalogoMunicipios](
    @dtFiltros [Nomina].[dtFiltrosRH] readonly,
    @IDUsuario INT
)
as
begin
	declare @IDEstado int;
	select @IDEstado = (SELECT TOP 1 TRY_CAST([Value] as int) FROM @dtFiltros WHERE Catalogo = 'IDEstado')

	declare @tempMunicipios as table (
		IDMunicipio int,
		Codigo varchar(5),
		Descripcion varchar(100),
		IDEstado int,
		TotalPaginas int,
		TotalRegistros int
	)

	insert into @tempMunicipios(IDMunicipio, Codigo, Descripcion, IDEstado, TotalPaginas, TotalRegistros)
	exec [STPS].[spBuscarMunicipios_Vue] @IDEstado = @IDEstado


	select 
		Codigo,
		Descripcion
	from @tempMunicipios
end
GO
