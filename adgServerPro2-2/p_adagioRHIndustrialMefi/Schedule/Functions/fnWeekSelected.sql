USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Schedule].[fnWeekSelected]
(
@date date,
@days int
)
RETURNS bit
AS
BEGIN

	declare @tmp int
	declare @tmp2 int
	declare @result bit
	set @tmp = datepart(weekday, @date)
	set @tmp2 = power(2,@tmp-1)		
	if (@days & @tmp2 != 0)
		set @result = 1
	else
		set @result = 0

	return @result
END
GO
