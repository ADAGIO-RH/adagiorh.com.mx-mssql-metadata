USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUTmpFvein] 
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
	
	INSERT INTO [zkteco].[tblTmpFvein] ([Pin], [Fid], [Index], [Size], [Valid], [Tmp], [Ver], [Duress])
	SELECT @Pin, @Fid, @Index, @Size, @Valid, @Tmp, @Ver, @Duress
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [Fid], [Index], [Size], [Valid], [Tmp], [Ver], [Duress]
	FROM   [zkteco].[tblTmpFvein]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
