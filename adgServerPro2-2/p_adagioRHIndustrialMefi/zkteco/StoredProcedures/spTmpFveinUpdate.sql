USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spTmpFveinUpdate] 
    @ID int,
    @Pin varchar(50) = NULL,
    @Fid varchar(2) = NULL,
    @Index varchar(2) = NULL,
    @Size int = NULL,
    @Valid varchar(1) = NULL,
    @Tmp text = NULL,
    @Ver varchar(20) = NULL,
    @Duress varchar(1) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [zkteco].[tblTmpFvein]
	SET    [Pin] = @Pin, [Fid] = @Fid, [Index] = @Index, [Size] = @Size, [Valid] = @Valid, [Tmp] = @Tmp, [Ver] = @Ver, [Duress] = @Duress
	WHERE  [ID] = @ID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [Fid], [Index], [Size], [Valid], [Tmp], [Ver], [Duress]
	FROM   [zkteco].[tblTmpFvein]
	WHERE  [ID] = @ID	
	-- End Return Select <- do not remove

	COMMIT
GO
