USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [zkteco].[spITmpBioPhoto](
	@Pin 		VARCHAR (50) 
	,@FileName	VARCHAR (100)
	,@Type		VARCHAR (20) 
	,@Size		INT          
	,@Content	TEXT      
	,@DevSN varchar(50)
) as

	if not exists(
		select top 1 1
		from [zkteco].[tblTmpBioPhoto] 
		where Pin = @Pin and [FileName] = @FileName and [Type] = @Type and DevSN = @DevSN
	) 
	begin
		insert [zkteco].[tblTmpBioPhoto] (Pin,[FileName],[Type],Size,Content,DevSN)
		select @Pin, @FileName, @Type, @Size, @Content, @DevSN
	end

	select 
		ID
		,Pin
		,[FileName]
		,[Type]
		,Size
		,Content
		,DevSN
	from [zkteco].[tblTmpBioPhoto] 
	where Pin = @Pin and [FileName] = @FileName and [Type] = @Type and DevSN = @DevSN
GO
