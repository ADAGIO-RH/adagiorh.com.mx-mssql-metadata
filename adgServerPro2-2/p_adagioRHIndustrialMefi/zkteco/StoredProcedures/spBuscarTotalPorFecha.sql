USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [zkteco].[spBuscarTotalPorFecha] (
	@AttTime datetime,
	@userID varchar(50)
) as
	select COUNT(*) as Total
	FROM   [zkteco].[tblAttLog] 
	where PIN = @userID and AttTime = @userID
GO
