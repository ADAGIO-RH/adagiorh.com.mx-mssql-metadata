USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBuscarTipoAumentoMasivo]
(
    @IDTipoAumentoMasivo INT = 0,
    @IDUsuario INT
)
AS
BEGIN

    DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    
    SELECT 
        t.IDTipoAumentoMasivo
        ,JSON_VALUE(t.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(t.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
    FROM Nomina.tblCatTipoAumentoMasivo t
    WHERE (t.IDTipoAumentoMasivo = @IDTipoAumentoMasivo OR ISNULL(@IDTipoAumentoMasivo, 0) = 0)
    order by T.orden 
    
END;
GO
