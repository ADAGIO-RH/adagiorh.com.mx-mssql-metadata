USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUTmpBioData] 
	@ID int = 0,
    @Pin varchar(50) = NULL,
    @No varchar(2) = NULL,
    @Index varchar(2) = NULL,
    @Valid varchar(1) = NULL,
    @Duress varchar(1) = NULL,
    @Type varchar(2) = NULL,
    @MajorVer varchar(20) = NULL,
    @MinorVer varchar(20) = NULL,
    @Format varchar(20) = NULL,
    @Tmp text = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	if (ISNULL(@ID, 0) = 0)
	begin
		INSERT INTO [zkteco].[tblTmpBioData] ([Pin], [No], [Index], [Valid], [Duress], [Type], [MajorVer], [MinorVer], [Format], [Tmp])
		SELECT @Pin, @No, @Index, @Valid, @Duress, @Type, @MajorVer, @MinorVer, @Format, @Tmp
		
		set @ID = SCOPE_IDENTITY()
	end else
	begin
		UPDATE [zkteco].[tblTmpBioData]
		SET    [Pin] = @Pin, [No] = @No, [Index] = @Index, [Valid] = @Valid, [Duress] = @Duress, [Type] = @Type, [MajorVer] = @MajorVer, [MinorVer] = @MinorVer, [Format] = @Format, [Tmp] = @Tmp
		WHERE  [ID] = @ID

	end
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [No], [Index], [Valid], [Duress], [Type], [MajorVer], [MinorVer], [Format], [Tmp]
	FROM   [zkteco].[tblTmpBioData]
	WHERE  [ID] = @ID
	-- End Return Select <- do not remove
               
	COMMIT
GO
