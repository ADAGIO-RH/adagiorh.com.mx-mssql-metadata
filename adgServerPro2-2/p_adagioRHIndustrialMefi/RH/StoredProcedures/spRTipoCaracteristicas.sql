USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los tipos de caracteristicas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-06-21
** Parametros		: 
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [RH].[spRTipoCaracteristicas]
AS
	BEGIN			
	
		DECLARE
        @IDIdioma varchar(20) ;

	    select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

		SELECT TC.IDTipoCaracteristica,
			   JSON_VALUE(TC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS TipoCaracteristica
		FROM [RH].[tblCatTiposCaracteristicas] TC
		ORDER BY TC.IDTipoCaracteristica	

	END
GO
