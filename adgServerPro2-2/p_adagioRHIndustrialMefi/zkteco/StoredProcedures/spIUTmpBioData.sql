USE [p_adagioRHIndustrialMefi]
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
    @Tmp text = NULL,
	@DevSN varchar(50)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
		if not exists(
			select top 1 1
			from [zkteco].[tblTmpBioData]
            where   isnull([pin]     , '') = isnull(@Pin     , '')
                and isnull([no]      , '') = isnull(@No      , '')
                and isnull([index]   , '') = isnull(@Index   , '')
                and isnull([Type]    , '') = isnull(@Type    , '')
                and isnull([MajorVer], '') = isnull(@MajorVer, '')
                and isnull([MinorVer], '') = isnull(@MinorVer, '')
                and isnull([DevSN]	 , '') = isnull(@DevSN	 , '')
		
		)
		begin
			INSERT INTO [zkteco].[tblTmpBioData] ([Pin], [No], [Index], [Valid], [Duress], [Type], [MajorVer], [MinorVer], [Format], [Tmp], DevSN)
			SELECT @Pin, @No, @Index, @Valid, @Duress, @Type, @MajorVer, @MinorVer, @Format, @Tmp, @DevSN
		
			set @ID = SCOPE_IDENTITY()

			exec [Scheduler].[spSchedulerQueryUsersDataZKTECO] 
						@DevSN=@DevSN
						,@PINs=@Pin
		end else
		begin
			UPDATE [zkteco].[tblTmpBioData]
			SET    [Pin] = @Pin, [No] = @No, [Index] = @Index, [Valid] = @Valid, [Duress] = @Duress, [Type] = @Type, [MajorVer] = @MajorVer, [MinorVer] = @MinorVer, [Format] = @Format, [Tmp] = @Tmp
			where   isnull([pin]     , '') = isnull(@Pin     , '')
                and isnull([no]      , '') = isnull(@No      , '')
                and isnull([index]   , '') = isnull(@Index   , '')
                and isnull([Type]    , '') = isnull(@Type    , '')
                and isnull([MajorVer], '') = isnull(@MajorVer, '')
                and isnull([MinorVer], '') = isnull(@MinorVer, '')
                and isnull([DevSN]	 , '') = isnull(@DevSN	 , '')

		end
	
		-- Begin Return Select <- do not remove
		SELECT [ID], [Pin], [No], [Index], [Valid], [Duress], [Type], [MajorVer], [MinorVer], [Format], [Tmp], DevSN
		FROM   [zkteco].[tblTmpBioData]
		WHERE  [ID] = @ID
		-- End Return Select <- do not remove
               
	COMMIT
GO
