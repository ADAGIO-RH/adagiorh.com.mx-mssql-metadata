USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarCatPermisos](
	@IDUsuario int
) AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	select 
		A.IDArea
		,A.Descripcion as Area
		,M.IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
		,U.Tipo
	From App.tblCatAreas A
		left join App.tblCatModulos M on A.IDArea = M.IDArea
		left join App.tblCatUrls U on M.IDModulo = U.IDModulo
	order by A.Descripcion desc		
END
GO
