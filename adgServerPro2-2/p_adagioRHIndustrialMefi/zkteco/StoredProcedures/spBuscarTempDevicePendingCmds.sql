USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [zkteco].[spBuscarTempDevicePendingCmds](
		@DevSN	varchar(50)
	) as
		if object_id('tempdb..#tempDevPendingCmds') is not null drop table #tempDevPendingCmds

		select top 20 *
		INTO #tempDevPendingCmds
		from [zkteco].[tblTempDeviceCmds]
		where DevSN = @DevSN and ISNULL(Executed, 0) = 0
		order by CreatedAt ASC

		update temp1
			set temp1.Executed = 1,
				temp1.ExecutedAt = getdate()
		from zkteco.tblTempDeviceCmds temp1
			join #tempDevPendingCmds t on t.ID = temp1.ID

		select * from #tempDevPendingCmds
GO
