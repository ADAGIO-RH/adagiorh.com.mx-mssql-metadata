USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [Asistencia].[fnTimeDiffWithDatetimes]  
(  
@StartDate datetime  
, @EndDate datetime  
)  
RETURNS  time  
AS  
BEGIN  
declare @value time,
         @minutes int


       if(@EndDate > @StartDate)begin
             set @minutes = datediff(MINUTE,@StartDate,@EndDate)

             set @value = cast(format(DATEADD(MINUTE,@minutes,CAST(CAST(0 AS FLOAT) AS DATETIME)),'HH:mm:ss') as time)
       end else
       begin
       set @value = '00:00:00.000'
       end
return @value  
END
GO
