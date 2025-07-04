USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Schedule].[fnMustRunHour]  (  
    @MultipleFrecuencyValueTypes varchar(30),  
    @startdate time(0),  
    @current time(0),  
    @count int  
)  
RETURNS bit  
AS  
BEGIN  
    declare 
        @delta int  
        , @result bit  
    ;
  
    set @count =  isnull(@count, 1)
    if @count = 0 set @count = 1

    if @current < @startdate  
        return 0  
  
    if @MultipleFrecuencyValueTypes = 'Minutes'  
        set @delta = DateDiff(mi, @startdate, @current) 
        
    if @MultipleFrecuencyValueTypes = 'Hours'  
    begin  
        set @delta = DateDiff(mi, @startdate, @current)  
        set @count = @count * 60;  
        --set @delta = DateDiff(hh, @startdate, @current)  
    end  
  
    if (@delta % @count) = 0  
        set @result = 1  
    else  
        set @result = 0  
  
    return @result  
END
GO
