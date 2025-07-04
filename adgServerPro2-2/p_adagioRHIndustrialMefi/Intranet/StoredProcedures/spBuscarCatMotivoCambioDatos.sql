USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarCatMotivoCambioDatos]  
    @IDUsuario int=0,
	@Disponible bit=1
	AS
BEGIN  

    declare           @IDIdioma varchar(225);
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

   select IDMotivoCambio
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion         
   from [Intranet].[tblCatMotivoCambioDatos]
   where Disponible = @Disponible
END
GO
