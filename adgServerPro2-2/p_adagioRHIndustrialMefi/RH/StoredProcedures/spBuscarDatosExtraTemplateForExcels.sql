USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2023-08-13
-- Description:	 
-- SP PARA BUSCAR LOS EMPLEADOS, PARA LA IMPORTACION DE CONTROLES DE ACCESOS
-- =============================================


CREATE PROCEDURE [RH].[spBuscarDatosExtraTemplateForExcels]
    @IDUsuario INT   
AS
BEGIN
   SELECT             
        Nombre,
        TipoDato    
    FROM [RH].[tblCatDatosExtra] 
END;
GO
