USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca las Url para el TreeView    
** Autor   : José R. Román Gil    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2018-01-01    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
2018-05-31		Aneudy Abreu  Se le agregó a la descripción el Área y Módulo al que pertenecen las Urls.    
2018-09-25		Aneudy Abreu  Cambió en la Descripción el Módulo por el Controller         
***************************************************************************************************/    
CREATE PROCEDURE [App].[spBuscarUrlsView] (
	@IDUsuario int
)   
AS    
BEGIN   
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	Select  
		url.IDUrl    
		,url.IDModulo    
		,m.Descripcion as Modulo    
		,coalesce(a.Descripcion,'')
			+'/'+coalesce(m.Descripcion,'')
			+'/'+JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion2
		,coalesce(a.Descripcion,'')
			+'/'+coalesce(c.Nombre,'[SIN CONTROLLER]')
			+'/'+JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion   
		,[url].[URL]
		,[url].Tipo   
		,isnull(url.IDTipoPermiso,0) as IDTipoPermiso  
		,isnull(tp.Descripcion,'Sin tipo de permiso') as TipoPermiso  
		,tp.Hologacion  
		,isnull(url.IDController,0) as IDController
		,isnull(c.Nombre,'[Sin Controller]') as Controller  
	from App.tblCatUrls [url]    
		join App.tblCatModulos m on url.IDModulo = m.IDModulo    
		join app.tblCatAreas a on m.IDArea = a.IDArea    
		left join App.tblCatTipoPermiso TP on TP.IDTipoPermiso = [url].IDTipoPermiso  
		left join app.tblCatControllers c on c.IDController = [url].IDController  
	Where Tipo = 'V'
	order by a.Descripcion, c.Nombre, url.IDUrl
END
GO
