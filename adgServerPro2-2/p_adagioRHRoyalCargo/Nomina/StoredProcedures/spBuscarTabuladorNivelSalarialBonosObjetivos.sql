USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorNivelSalarialBonosObjetivos]
(
    @IDTabuladorNivelSalarialBonosObjetivos INT
   ,@IDUsuario INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivos]
    WHERE [IDTabuladorNivelSalarialBonosObjetivos] = @IDTabuladorNivelSalarialBonosObjetivos;
END;
GO
