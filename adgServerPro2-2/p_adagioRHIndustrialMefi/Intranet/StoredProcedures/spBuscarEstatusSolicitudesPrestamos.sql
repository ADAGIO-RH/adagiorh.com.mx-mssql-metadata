USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarEstatusSolicitudesPrestamos] (
	@IDEstatusSolicitudPrestamo int = 0,
    @IDUsuario int 
) as

    DECLARE @IDIdioma varchar(225)
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

	select
		IDEstatusSolicitudPrestamo,
        case when  JSON_VALUE(sp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  =JSON_VALUE(s.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  		 or s.Descripcion is null  
			then JSON_VALUE(sp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) 
			else  JSON_VALUE(sp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))   +' / ' + JSON_VALUE(s.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  end [Nombre]
		,CssClass
	from [Intranet].[tblCatEstatusSolicitudesPrestamos] sp
    left join Intranet.tblCatEstatusSolicitudes s on s.IDEstatusSolicitud=sp.IDEstatusSolicitudReferencia
	where (IDEstatusSolicitudPrestamo = @IDEstatusSolicitudPrestamo or isnull(@IDEstatusSolicitudPrestamo, 0) = 0)
GO
