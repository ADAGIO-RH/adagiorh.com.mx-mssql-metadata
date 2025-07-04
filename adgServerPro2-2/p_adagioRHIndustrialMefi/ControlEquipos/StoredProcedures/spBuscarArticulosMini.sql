USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc ControlEquipos.spBuscarArticulosMini(
	@IDArticulo int,
	@IDUsuario int,
	@query VARCHAR(4000) = '""'
)
as
begin
	SET FMTONLY OFF;
	declare  @IDIdioma varchar(20);

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	select 
		a.IDArticulo,
		a.IDTipoArticulo,
		a.Nombre,
		cta.IDCatEstatusTipoArticulo
	from ControlEquipos.tblArticulos a
	inner join ControlEquipos.tblCatTiposArticulos cta on cta.IDTipoArticulo = a.IDTipoArticulo
	where (a.IDArticulo = @IDArticulo or isnull(@IDArticulo, 0) = 0)
			and (@query = '""' or contains(a.*, @query))
end
GO
