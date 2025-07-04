USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarTmpFP] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Pin], [Fid], [Size], [Valid], [Tmp], [MajorVer], [MinorVer], [Duress] 
	FROM   [zkteco].[tblTmpFP] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
