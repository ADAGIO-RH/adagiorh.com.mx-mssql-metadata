USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [RH].[spBuscarRequisitosPuestos]@IDUsuario=1
CREATE proc [RH].[spBuscarRequisitosPuestos](
	@IDRequisitoPuesto int = 0,
	@IDPuesto int = 0,
	@IDTipoCaracteristica int = 0, 
	@IDUsuario int
) AS
    DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select
		rp.IDRequisitoPuesto
		,rp.IDPuesto
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto
		,rp.IDTipoCaracteristica
		,JSON_VALUE(TC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS TipoCaracteristica
		,rp.Requisito
		,t.Tipo as TipoValor
		,t.Texto as TipoValorTexto
		,rp.Activo
		,rp.ValorEsperado
		,rp.[Data]
	from RH.tblRequisitosPuestos rp with (nolock)
		join RH.tblCatPuestos p with (nolock) on p.IDPuesto = rp.IDPuesto
		join RH.tblCatTiposCaracteristicas tc with (nolock) on tc.IDTipoCaracteristica = rp.IDTipoCaracteristica
		join Reclutamiento.tblCatTiposCapturaRequisitos t with(nolock) on rp.TipoValor = t.Tipo
			
	where (rp.IDRequisitoPuesto = @IDRequisitoPuesto or ISNULL(@IDRequisitoPuesto, 0) = 0)
		and (rp.IDPuesto = @IDPuesto or ISNULL(@IDPuesto, 0) = 0)		
		and (rp.IDTipoCaracteristica = @IDTipoCaracteristica or ISNULL(@IDTipoCaracteristica, 0) = 0)
GO
