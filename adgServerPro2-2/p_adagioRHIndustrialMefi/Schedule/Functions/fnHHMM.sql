USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create function [Schedule].[fnHHMM]
(
	@currenttime time(0)
)
RETURNS time(0)
AS
BEGIN
	declare @result time(0)
	declare @tmp varchar(10) 
	set @tmp = cast(datepart(hh, @currenttime) as varchar(2))+':'+cast(datepart(mi, @currenttime) as varchar(2))
	set @result = @tmp
	return @result
END
GO
