USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarOperadoresRacionales]
AS
BEGIN
	SELECT *
    FROM APP.TblCatOperadoresRacionales

END
GO
