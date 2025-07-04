USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author...........  : Aneudy Abreu
-- Create date........: 15/10/2012
-- Last Date Modified.: 30/Nov/2017
-- Description........: Parse un string y lo retorna como una tabla.
--
-- Versión..........: 1.0
-- ========================================================

CREATE FUNCTION [App].[Split](@String nvarchar(max), @Delimiter char(1))       
    returns @temptable TABLE (item varchar(8000), id int identity(1,1))       
as       
begin       
    declare @idx int       
           ,@slice nvarchar(max);
          
    select @idx = 1       
        if len(@String)<1 or @String is null  return;       
          
    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,@String)       
        if @idx!=0       
            set @slice = left(@String,@idx - 1)       
        else       
            set @slice = @String;       
              
        if(len(@slice)>0)  
            insert into @temptable(item) values(@slice);       
      
        set @String = right(@String,len(@String) - @idx);      
        if len(@String) = 0 break;       
    end;   
return;       
end;
GO
