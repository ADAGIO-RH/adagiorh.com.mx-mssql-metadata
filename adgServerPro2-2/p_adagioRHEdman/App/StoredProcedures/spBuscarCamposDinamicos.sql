USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-08-22
-- Description:	
-- =============================================
CREATE PROCEDURE [App].[spBuscarCamposDinamicos]
    @Tabla varchar(100)=null,
    @IDUsuario int
    -- Add the parameters for the stored procedure here	
AS
BEGIN
    
    DECLARE @IDIdioma varchar(225)
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

    select 
        [IDCampoDinamico],sp.Campo,Tabla,
        JSON_VALUE(sP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
     From [App].[tblCatCamposDinamicos] sp		
	 WHERE SP.Tabla IN (Select item from App.Split(@Tabla,',')) OR
		   @Tabla IS NULL    
    
END
GO
