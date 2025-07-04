USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene la plantilla solicitada
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-02-21
** Paremetros		: @IDPlantilla		- Identificador de la plantilla
**					: @IDUsuario		- Identificador del usuario
** IDIssue			: #812

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spBuscarPlantillas9Box](
	@IDPlantilla	INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE @IDIdioma VARCHAR(20);		
				
		SET @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');
		
		SELECT PL.IDPlantilla
				, PL.Nombre
				, PL.EjeX
				, PL.EjeY
				, PL.IsDefault
				, (SELECT DC.IDCuadro
							, NoCuadro
							, JSON_VALUE(DC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Titulo')) as Titulo
							, JSON_VALUE(DC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
							, DC.Coordenada_X_DE
							, DC.Coordenada_X_A
							, DC.Coordenada_Y_DE
							, DC.Coordenada_Y_A
							, DC.BackgroundColor
							, DC.Color
							, DC.Traduccion
					FROM [Evaluacion360].[tblDetalleCuadros9Box] DC
					WHERE DC.IDPlantilla = PL.IDPlantilla
					ORDER BY NoCuadro ASC
					for JSON AUTO) AS Cuadros
		FROM [Evaluacion360].[tblCatPlantillas9Box] PL
		WHERE ((PL.IDPlantilla = @IDPlantilla OR ISNULL(@IDPlantilla, 0) = 0))

	END
GO
