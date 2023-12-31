USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Utilerias.fn_DateDiff_YMDMHS
(   
    @Startdate as datetime2(0),
    @Enddate as datetime2(0)
)
RETURNS TABLE 
AS
RETURN 
(
    select 
        TotalYears [Years],
        datediff(month, dateadd(Year, TotalYears, @Startdate), @Enddate) Months,
        datediff(day, dateadd(month, TotalMonths, @Startdate), @Enddate) [Days],
        datediff(hour, dateadd(day, TotalDays, @Startdate), @Enddate) [Hours],
        datediff(minute, dateadd(hour, TotalHours, @Startdate), @Enddate) [Minutes],
        datediff(second, dateadd(minute, TotalMinutes, @Startdate), @Enddate) [Seconds]
    from (
    select 
        datediff(SECOND, @Startdate, @Enddate) TotalSeconds,
        datediff(minute, @Startdate, @Enddate) TotalMinutes,
        datediff(hour, @Startdate, @Enddate) TotalHours,
        datediff(day, @Startdate, @Enddate) TotalDays,
        datediff(month, @Startdate, @Enddate) TotalMonths,
        datediff(year, @Startdate, @Enddate) TotalYears) DateDiffs
    )
GO
