USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarCatTiposCaracteristicas]-- @IDTipoCaracteristica = 0, @IDUsuario = 1
(
	@IDTipoCaracteristica int,
	@query varchar(20) = null,
	@SoloActivos bit = 0,
	@IDUsuario int
) as

	DECLARE  
		@IDIdioma varchar(225);

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


	select
		IDTipoCaracteristica,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoCaracteristica,
		Activo,
		Traduccion
	from RH.tblCatTiposCaracteristicas with (nolock)
	where 
		(IDTipoCaracteristica = @IDTipoCaracteristica or isnull(@IDTipoCaracteristica, 0) = 0) 
		and (Activo = case when ISNULL(@SoloActivos, 0) = 1 then 1 else Activo end)
GO
