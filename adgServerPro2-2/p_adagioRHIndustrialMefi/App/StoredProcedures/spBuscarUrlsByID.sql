USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarUrlsByID]
(
	@IDUrl int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))	
	
	Select	
		cu.IDUrl
		,cu.IDModulo
		,JSON_VALUE(cu.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,URL
		,Tipo
		,isnull(cu.IDTipoPermiso,0) as IDTipoPermiso
		,isnull(cu.IDController,0) as IDController
		,isnull(cm.Descripcion,'') as Modulo
		,isnull(ctp.Descripcion,'') as TipoPermiso
		,isnull(cm.IDArea,0) as IDArea
		,isnull(ca.Descripcion,'') as Area
		,isnull(ca.PrefijoURL,0) as PrefijoURL
	from App.tblCatUrls cu
		left join App.tblCatModulos cm on cu.IDModulo = cm.IDModulo
		left join [App].[tblCatTipoPermiso] ctp on cu.IDTipoPermiso = ctp.IDTipoPermiso
		left join [App].[tblCatAreas] ca on cm.IDArea = ca.IDArea
	Where (cu.IDModulo = @IDUrl) OR (isnull(@IDUrl,0) = 0)
END
GO
