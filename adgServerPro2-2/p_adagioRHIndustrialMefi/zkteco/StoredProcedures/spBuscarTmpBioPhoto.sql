USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [zkteco].[spBuscarTmpBioPhoto](
	 @Pin	varchar(50)
	,@Type	varchar(20)
)
 as
	select 
		ID
		,Pin
		,[FileName]
		,[Type]
		,Size
		,Content
		,DevSN
	from [zkteco].[tblTmpBioPhoto] 
	where pin = @Pin and [Type] = @Type
GO
