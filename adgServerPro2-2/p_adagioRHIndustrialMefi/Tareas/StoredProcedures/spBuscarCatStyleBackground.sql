USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Tareas].[spBuscarCatStyleBackground]
(
	@IDStyleBackground int
)


AS
BEGIN	

    select IDStyleBackground,BackgroundTypes,Value FROM Tareas.tblCatStylesBackground    
    where IDStyleBackground=@IDStyleBackground or ISNULL(@IDStyleBackground,0)=0

END
GO
