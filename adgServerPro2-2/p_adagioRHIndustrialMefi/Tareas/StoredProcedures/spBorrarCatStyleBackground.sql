USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Tareas].[spBorrarCatStyleBackground]
(
	@IDStyleBackground int
)
AS
BEGIN	    
    delete from Tareas.tblCatStylesBackground where IDStyleBackground=@IDStyleBackground
END
GO
