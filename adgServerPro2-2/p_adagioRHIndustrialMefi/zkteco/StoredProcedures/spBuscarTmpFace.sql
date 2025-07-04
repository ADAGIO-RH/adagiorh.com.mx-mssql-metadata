USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarTmpFace] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Pin], [Fid], [Size], [Valid], [Tmp], [Ver] 
	FROM   [zkteco].[tblTmpFace] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
