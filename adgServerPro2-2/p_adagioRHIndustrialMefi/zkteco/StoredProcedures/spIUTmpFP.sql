USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUTmpFP] 
    @Pin varchar(50) = NULL,
    @Fid varchar(2) = NULL,
    @Size int = NULL,
    @Valid varchar(1) = NULL,
    @Tmp text = NULL,
    @MajorVer varchar(20) = NULL,
    @MinorVer varchar(20) = NULL,
    @Duress varchar(1) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [zkteco].[tblTmpFP] ([Pin], [Fid], [Size], [Valid], [Tmp], [MajorVer], [MinorVer], [Duress])
	SELECT @Pin, @Fid, @Size, @Valid, @Tmp, @MajorVer, @MinorVer, @Duress
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [Fid], [Size], [Valid], [Tmp], [MajorVer], [MinorVer], [Duress]
	FROM   [zkteco].[tblTmpFP]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
