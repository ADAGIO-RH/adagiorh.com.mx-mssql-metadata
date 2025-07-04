USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarTmpBioData] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Pin], [No], [Index], [Valid], [Duress], [Type], [MajorVer], [MinorVer], [Format], [Tmp] 
	FROM   [zkteco].[tblTmpBioData] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
