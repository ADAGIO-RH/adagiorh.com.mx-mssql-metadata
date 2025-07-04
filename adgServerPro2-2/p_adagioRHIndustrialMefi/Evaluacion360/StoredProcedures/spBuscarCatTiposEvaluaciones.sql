USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Busca los tipos de evaluaciones con sus grupos configurados
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2023-02-04
** Paremetros		: @IDTipoEvaluacion		Identificador del tipo de evaluación
					  @IDUsuario			Identificador del usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-02-07			Alejandro Paredes	Se agrego la columna TiposDeGrupos
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarCatTiposEvaluaciones](
	@IDTipoEvaluacion INT = 0,
	@IDUsuario INT
) AS

	DECLARE @IDIdioma VARCHAR(20);
	
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

	SELECT TE.IDTipoEvaluacion,
		   JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Nombre')) AS Nombre,
		   (SELECT TG.IDTipoGrupo,
				   TG.Nombre,
				   TG.Color
		    FROM OPENJSON(TE.TiposDeGrupos, '$')			
				WITH(
					[IDTipoGrupo] INT '$.IDTipoGrupo'					
			    ) TG2
					JOIN [Evaluacion360].[tblCatTipoGrupo] TG ON TG.IDTipoGrupo IN (TG2.IDTipoGrupo) ORDER BY TG.Orden FOR JSON AUTO 					
		   ) AS TiposDeGrupos
		    ,TE.BackGroundColor as BackGroundColor
			,TE.FontColor as FontColor
			,Traduccion
	FROM Evaluacion360.tblCatTiposEvaluaciones TE
	WHERE (TE.IDTipoEvaluacion = @IDTipoEvaluacion OR ISNULL(@IDTipoEvaluacion, 0) = 0)
GO
