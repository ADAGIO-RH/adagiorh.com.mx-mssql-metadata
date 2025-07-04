USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Schedule].[fnGetRelativeWeekOfDay]
(
	@date datetime
)
RETURNS varchar(5)
AS
BEGIN
declare @weekday int
declare @day int
declare @num int
declare @result varchar(5)
	
set @weekday = datepart(weekday, @date)
set @day = datepart(day, @date)
set @num = (@day / 7)+1

set @result = cast(@weekday as varchar(3))+'-'+cast(@num as varchar(2))
return @result

END
GO
