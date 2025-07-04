USE [p_adagioRHIndustrialMefi]
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
    @Ver varchar(20) = NULL,
	@DevSN varchar(20)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

		if exists(select top 1 1 
				from [zkteco].[tblTmpFace] 
				where Pin =@Pin and isnull(Ver,'') = isnull(@Ver,'') and Fid=@Fid and DevSN=@DevSN)
		begin
			update [zkteco].[tblTmpFace]
				set
					Tmp = @Tmp
			where Pin =@Pin and isnull(Ver,'') = isnull(@Ver,'') and Fid=@Fid and DevSN=@DevSN
		end else
		begin
			insert into [zkteco].[tblTmpFace](Pin,Fid,Size,Valid,Tmp,Ver,DevSN)
			values(@Pin,@Fid,@Size,@Valid,@Tmp,@Ver,@DevSN);
		end

	
	COMMIT
GO
