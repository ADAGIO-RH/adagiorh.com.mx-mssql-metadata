USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Tzdb].[ConvertZone]
(
    @dt datetime2,
    @source_tz varchar(50),
    @dest_tz varchar(50),
    @SkipOnSpringForwardGap bit = 1,
    @FirstOnFallBackOverlap bit = 1
)
RETURNS datetimeoffset
AS
BEGIN
    DECLARE @utc datetimeoffset
    SET @utc = [Tzdb].[LocalToUtc](@dt, @source_tz, @SkipOnSpringForwardGap, @FirstOnFallBackOverlap)
    RETURN [Tzdb].[UtcToLocal](@utc, @dest_tz)
END
GO
