USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Schedule].[fnMustRunPeriod]
(
	@datestart datetime,
	@date datetime, 
	@ocurrsFrecuency varchar(50),
	@count int
)
RETURNS bit
AS
BEGIN
	declare 
		@result bit
		,@start int	
		,@end int
		,@delta int
		,@periodlength int = 1
	;
	
	set @count =  isnull(@count, 1)
	if @count = 0 set @count = 1

	if @ocurrsFrecuency = 'Diario' set @periodlength = 1
	if @ocurrsFrecuency = 'Semanal' set @periodlength = 7

	if @ocurrsFrecuency = 'Diario' or @ocurrsFrecuency = 'Semanal'
	begin
		if @periodlength = 7
		begin
		  set @datestart = dateadd(dd,-datepart(dw,@datestart)+1, @datestart)
		end	
		set @start = cast(@datestart as int)
		set @end = cast(@date as int)  
		set @delta = @end - @start
		set @result = 0

		if (@delta / @periodlength) % @count = 0
			set @result = 1
	end
	if @ocurrsFrecuency = 'Mensual'
	begin

		declare @deltayear int
		declare @deltamonth int
		declare @totalmonths int 
		set @deltayear =  datepart(year, @date) -  datepart(year, @datestart)
		set @deltamonth =  datepart(month, @date) -  datepart(month, @datestart)
		set @totalmonths = (@deltayear*12) + @deltamonth

		if (@totalmonths) % @count = 0
			set @result = 1
		else
			set @result = 0
	end
	return @result
END
GO
