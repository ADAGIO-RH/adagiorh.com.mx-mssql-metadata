USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorNivelSalarialBonosObjetivosDetalle]
(
    @IDTabuladorNivelSalarialBonosObjetivos INT
    ,@IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]
    WHERE [IDTabuladorNivelSalarialBonosObjetivos] = @IDTabuladorNivelSalarialBonosObjetivos
    ORDER BY Nivel
END;
GO
