USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function zkteco.fnGetQtyComandosPendientes
(
	@DevSN varchar(50)
) returns int 
AS
BEGIN
	return (
		(select count(*)Qty 
		from [zkteco].[tblDeviceCmds] with(nolock) 
		where DevSN = @DevSN and  (ISNULL(ReturnValue,'') = '')
	)+(
		select count(*)Qty 
		from [zkteco].[tblTempDeviceCmds] with(nolock) 
		where DevSN = @DevSN and (isnull(Executed, 0)=0)
	))
END
GO
