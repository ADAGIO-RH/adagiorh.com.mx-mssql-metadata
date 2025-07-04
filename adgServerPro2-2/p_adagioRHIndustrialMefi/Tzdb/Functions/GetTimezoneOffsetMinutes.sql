USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   FUNCTION [Tzdb].[GetTimezoneOffsetMinutes]
(
    @ZoneId int
   
)
RETURNS varchar(10)
AS
BEGIN

	DECLARE 		
		@OffsetMinutes int,
		@utc datetime2 = GetDate()
	;

	SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
	FROM [Tzdb].[Intervals]
	WHERE [ZoneId] = @ZoneId AND [UtcStart] <= @utc AND [UtcEnd] > @utc

	return @OffsetMinutes
END
GO
