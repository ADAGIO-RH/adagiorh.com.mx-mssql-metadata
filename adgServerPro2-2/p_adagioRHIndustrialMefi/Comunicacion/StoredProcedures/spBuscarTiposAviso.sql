USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comunicacion].[spBuscarTiposAviso] (	
    @IDUsuario int 
) as

    DECLARE @IDIdioma varchar(225)
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

    select 
        [IDTipoAviso],
        JSON_VALUE(t.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Titulo')) [Titulo],
        JSON_VALUE(t.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) [Descripcion],        
        t.ClassStyle
     From  [Comunicacion].[tblCatTiposAviso] t
GO
