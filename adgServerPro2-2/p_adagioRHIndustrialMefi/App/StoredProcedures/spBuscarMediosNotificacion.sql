USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarMediosNotificacion](
    @IDMedioNotificacion varchar(50) = null
	,@IDUsuario int = 0
) as
	declare  
	   @IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	
    select 
		IDMedioNotificacion, 
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
		Traduccion
    from [App].[tblMediosNotificaciones]
    where (IDMedioNotificacion = @IDMedioNotificacion or @IDMedioNotificacion is null)
GO
