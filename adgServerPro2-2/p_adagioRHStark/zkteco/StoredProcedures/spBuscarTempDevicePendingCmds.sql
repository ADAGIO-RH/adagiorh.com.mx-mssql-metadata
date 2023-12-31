USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE proc [zkteco].[spBuscarTempDevicePendingCmds](
		@DevSN	varchar(50)
	) as
		select *
		from [zkteco].[tblTempDeviceCmds]
		where DevSN = @DevSN and ISNULL(Executed, 0) = 0
GO
