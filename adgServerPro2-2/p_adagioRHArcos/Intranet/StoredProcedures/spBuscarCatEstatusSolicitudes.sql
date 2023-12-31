USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarCatEstatusSolicitudes] (	
	@IDUsuario int 
) as

	DECLARE @IDIdioma varchar(225)
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

	select 
    	sp.IDEstatusSolicitudPrestamo [IDEstatus],
    	case when  JSON_VALUE(sP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  =JSON_VALUE(s.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  		 or s.Descripcion is null  
			then JSON_VALUE(sp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) 
			else  JSON_VALUE(sP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))   +' / ' + JSON_VALUE(s.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  end [Descripcion]
 	From Intranet.tblCatEstatusSolicitudesPrestamos  sp
	left join Intranet.tblCatEstatusSolicitudes s on s.IDEstatusSolicitud=sp.IDEstatusSolicitudReferencia
GO
