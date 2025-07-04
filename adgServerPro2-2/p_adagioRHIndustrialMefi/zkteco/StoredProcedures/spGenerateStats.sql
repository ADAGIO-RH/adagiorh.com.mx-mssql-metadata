USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc zkteco.spGenerateStats as

	declare @Orden int

	select @Orden=isnull(max(Orden), 0)+1 from zkteco.tblStats

	insert zkteco.tblStats(DevSN, LastRequestTime, Total, Orden)
	select *, @Orden
	from (
		select tdc.DevSN, d.LastRequestTime, count(tdc.DevSN) Total
		from zkteco.tblDeviceCmds tdc with (nolock)  
			join zkteco.tblDevice d with (nolock) on d.DevSN = tdc.DevSN
		where (ReturnValue is null or len(ReturnValue)=0) 
		group by tdc.DevSN, d.LastRequestTime
	) info
	order by Total
GO
