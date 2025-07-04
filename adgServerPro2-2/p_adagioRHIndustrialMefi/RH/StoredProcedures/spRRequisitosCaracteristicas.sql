USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los requisitos con su caracteristica
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-06-20
** Parametros		: 
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [RH].[spRRequisitosCaracteristicas]
AS
	BEGIN				

        DECLARE
        @IDIdioma varchar(20) ;

	    select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

		SELECT R.IDRequisitoPuesto,
			   JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS Puesto,  
			   JSON_VALUE(TC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS TipoCaracteristica,
			   R.Requisito,
			   JSON_VALUE(TC.Color, '$.BackgroundColor') AS BackgroundColor,
			   JSON_VALUE(TC.Color, '$.Color') AS Color
		FROM [RH].[tblRequisitosPuestos] R
			INNER JOIN [RH].[tblCatTiposCaracteristicas] TC ON R.IDTipoCaracteristica = TC.IDTipoCaracteristica	
			INNER JOIN [RH].[tblCatPuestos] P ON R.IDPuesto = P.IDPuesto
		ORDER BY TC.IDTipoCaracteristica, R.Requisito	

	END
GO
