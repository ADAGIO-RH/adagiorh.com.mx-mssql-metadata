USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spTmpFaceUpdate] 
    @ID int,
    @Pin varchar(50) = NULL,
    @Fid varchar(2) = NULL,
    @Size int = NULL,
    @Valid varchar(1) = NULL,
    @Tmp text = NULL,
    @Ver varchar(20) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [zkteco].[tblTmpFace]
	SET    [Pin] = @Pin, [Fid] = @Fid, [Size] = @Size, [Valid] = @Valid, [Tmp] = @Tmp, [Ver] = @Ver
	WHERE  [ID] = @ID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [Fid], [Size], [Valid], [Tmp], [Ver]
	FROM   [zkteco].[tblTmpFace]
	WHERE  [ID] = @ID	
	-- End Return Select <- do not remove

	COMMIT
GO
