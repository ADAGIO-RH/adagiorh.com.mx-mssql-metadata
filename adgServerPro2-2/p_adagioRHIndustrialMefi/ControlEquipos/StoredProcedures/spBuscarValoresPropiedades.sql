USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarValoresPropiedades](
	@IDDetalleArticulo int,
	@IDUsuario int
)
as

	DECLARE 
		@IDIdioma varchar(20),
        @IDTipoArticulo int 
	;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	
	IF OBJECT_ID('tempdb..#TempPropiedades') IS NOT NULL DROP TABLE #TempPropiedades;

    select @IDTipoArticulo=IDTipoArticulo from   ControlEquipos.tblDetalleArticulos  d
    inner join ControlEquipos.tblArticulos a on a.IDArticulo=d.IDArticulo
    where IDDetalleArticulo = @IDDetalleArticulo

	select *
	into #TempPropiedades
	from ControlEquipos.tblCatPropiedades
	where IDTipoArticulo =@IDTipoArticulo

	SELECT 
		isnull(vp.IDValorPropiedad, 0) as IDValorPropiedad,
		p.IDPropiedad,
		p.IDTipoArticulo,
		isnull(vp.IDDetalleArticulo, @IDDetalleArticulo) as IDDetalleArticulo,
		p.IDInputType,
		JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS Nombre,
		p.Traduccion,
		p.[Data],
		vp.Valor,
		cit.ConfiguracionSizeInput
	FROM #TempPropiedades p
		left join [ControlEquipos].[tblValoresPropiedades] vp on vp.IDPropiedad = p.IDPropiedad and vp.IDDetalleArticulo = @IDDetalleArticulo
		LEFT JOIN App.tblCatInputsTypes cit ON cit.IDInputType = p.IDInputType
GO
