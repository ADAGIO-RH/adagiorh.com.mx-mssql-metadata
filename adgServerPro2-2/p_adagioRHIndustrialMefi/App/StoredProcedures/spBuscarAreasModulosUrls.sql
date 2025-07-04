USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [App].[spBuscarAreasModulosUrls] (
	@IDUsuario int
) 
as
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
    select IDArea, Descripcion
    from App.tblCatAreas

    select *
    from App.tblCatModulos 

    select
		IDUrl
		,IDModulo
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,[URL]
		,Tipo
		,IDTipoPermiso
		,IDController
		,Traduccion
    from App.tblCatUrls
    where Tipo = 'V'
GO
