USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Onboarding].[spBuscarPlantillas] (
    @IDPlantilla int = 0,
    @IDUsuario int = NULL
)
AS
BEGIN
    DECLARE @IDIdioma VARCHAR(20) = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    SELECT 
        plantilla.IDPlantilla,
        Upper(plantilla.NombrePlantilla) as NombrePlantilla,
        plantilla.IDsPlaza,
        Cargos = ISNULL(
            STUFF(
                (
                    SELECT ', ' + CONVERT(NVARCHAR(100), ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Descripcion')), 'SIN ASIGNAR'))
                    FROM RH.tblCatPuestos WITH (NOLOCK)
                    WHERE IDPuesto IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(plantilla.IDsPlaza, ','))
                    ORDER BY Traduccion ASC
                    FOR XML PATH('')
                ), 1, 1, ''
            ),
            'CARGOS NO DEFINIDOS'
        ),     
        COUNT(T.IDReferencia) AS CantidadTareas
      
    FROM [Onboarding].[tblPlantillas] plantilla
    LEFT JOIN Tareas.tblTareas T ON T.IDReferencia = plantilla.IDPlantilla AND T.IDTipoTablero = 2
    WHERE (IDPlantilla = @IDPlantilla or isnull(@IDPlantilla, 0) = 0) 
    GROUP BY plantilla.IDPlantilla, plantilla.NombrePlantilla, plantilla.IDsPlaza
END
GO
