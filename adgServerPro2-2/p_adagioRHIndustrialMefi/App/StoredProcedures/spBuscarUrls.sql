USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarUrls]
(
	@IDModulo int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
	Select 
		IDUrl
		,cu.IDModulo
		,JSON_VALUE(cu.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,URL
		,Tipo
		,cm.Descripcion as Modulo
	from App.tblCatUrls cu
		left join App.tblCatModulos cm on cu.IDModulo = cm.IDModulo
	Where (cu.IDModulo = @IDModulo) OR (@IDModulo = 0)
END
GO
