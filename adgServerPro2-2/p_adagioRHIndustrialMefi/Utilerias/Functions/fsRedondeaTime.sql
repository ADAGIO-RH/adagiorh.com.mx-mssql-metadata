USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Utilerias].[fsRedondeaTime](
    @t time 
) returns time as
-- declare @t time = '06:59:59.9970000'
begin

    SELECT @t = cast(DATEADD(MINUTE, CEILING(DATEDIFF(SECOND, 0, CAST(CAST(@t AS DATETIME) AS TIME)) / 60.0), DATEDIFF(DAY, 0, @t)) as time) 

    return @t;
end;
GO
