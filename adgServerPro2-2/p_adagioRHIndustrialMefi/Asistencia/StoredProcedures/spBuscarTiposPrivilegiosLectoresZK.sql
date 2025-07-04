USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Asistencia].[spBuscarTiposPrivilegiosLectoresZK](
	@IDTipoPrivilegioLectorZK int = 0,
	@IDUsuario int
) as
	
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
			[IDTipoPrivilegioLectorZK],
			JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
			Traduccion
	from Asistencia.[tblCatTiposPrivilegiosLectoresZK]
	where [IDTipoPrivilegioLectorZK] = @IDTipoPrivilegioLectorZK or isnull(@IDTipoPrivilegioLectorZK, 0) = 0
GO
