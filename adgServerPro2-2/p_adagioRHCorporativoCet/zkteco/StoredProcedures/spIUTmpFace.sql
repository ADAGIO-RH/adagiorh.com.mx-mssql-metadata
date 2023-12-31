USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUTmpFace] 
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
	
	INSERT INTO [zkteco].[tblTmpFace] ([Pin], [Fid], [Size], [Valid], [Tmp], [Ver])
	SELECT @Pin, @Fid, @Size, @Valid, @Tmp, @Ver
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [Fid], [Size], [Valid], [Tmp], [Ver]
	FROM   [zkteco].[tblTmpFace]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
