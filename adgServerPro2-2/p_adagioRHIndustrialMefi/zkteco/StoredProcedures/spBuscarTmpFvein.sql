USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarTmpFvein] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Pin], [Fid], [Index], [Size], [Valid], [Tmp], [Ver], [Duress] 
	FROM   [zkteco].[tblTmpFvein] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
