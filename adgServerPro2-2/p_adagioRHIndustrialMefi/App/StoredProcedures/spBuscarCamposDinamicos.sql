USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca campos dinamicos
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-08-22
** Paremetros		: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-12-12			Alejandro Paredes	Se agregaron los campos IDCampo, AliasCampo, GrupoCampo
2024- 10-30			Alejandro Paredes	La busqueda de los campos dinamicos se realiza por el campo "Tabla"
***************************************************************************************************/

CREATE PROCEDURE [App].[spBuscarCamposDinamicos]
    @IDUsuario INT,
    @Tabla VARCHAR(100) = NULL
AS
	BEGIN
    
		DECLARE @IDIdioma VARCHAR(225);
		SELECT @IDIdioma = [APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');

		SELECT IDCampoDinamico,
			   Campo,
			   Tabla,
			   JSON_VALUE(sP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) AS Descripcion,
			   --IDCampo,
			   AliasCampo,
			   GrupoCampo
		 FROM [APP].[tblCatCamposDinamicos] SP		
		 WHERE tabla = @Tabla
		 ORDER BY IDCampoDinamico
    
	END
GO
