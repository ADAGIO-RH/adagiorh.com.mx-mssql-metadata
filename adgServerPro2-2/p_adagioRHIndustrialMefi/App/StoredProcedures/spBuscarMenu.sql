USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarMenu] (
	@IDAplicacion nvarchar(100),
	@IDUsuario int
)
AS  
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	select  
		M.IDMenu  
		,M.IDUrl  
		,ISnull(M.ParentID,0)as ParentID  
		,M.CssClass   
		,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,U.URL  
		,isnull(M.Orden,0) as Orden  
	from App.tblMenu M  
		Inner join App.tblCatUrls u on m.IDUrl = u.IDUrl  
	where U.Tipo = 'V' and m.IDAplicacion = @IDAplicacion 
	order by M.Orden  
END
GO
