USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBuscarEstatusAumentoMasivo]
(
    @IDEstatusAumentoMasivo INT = 0,
    @IDUsuario INT
)
AS
BEGIN

    DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    SELECT 
        e.IDEstatusAumentoMasivo
        ,JSON_VALUE(e.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(e.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
    FROM Nomina.tblCatEstatusAumentoMasivo e
    WHERE (e.IDEstatusAumentoMasivo = @IDEstatusAumentoMasivo OR ISNULL(@IDEstatusAumentoMasivo, 0) = 0)
    ORDER BY e.Orden 
END;
GO
