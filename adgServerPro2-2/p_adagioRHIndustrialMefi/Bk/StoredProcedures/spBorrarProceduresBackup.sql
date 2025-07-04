USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Bk].[spBorrarProceduresBackup](
    @BKID varchar(50)
)
as
declare @spToDelete varchar(255)
 ,@Type varchar(255)
 ,@i int = 0
 ,@sql varchar(max);


 if object_id('tempdb..#tempSPs') is not null
    drop table #tempSPs;

select NombreSP as SP, [Type] [Type] ,ROW_NUMBER()over(order by NombreSP) as [Row]
into #tempSPs
from [Bk].[tblStoredProcedures]
where BKID = @BKID

select @i=min([Row]) from #tempSPs

while exists(select 1 from #tempSPs where [Row] >= @i)
begin
    select @spToDelete=SP
	, @Type = [type]
    from #tempSPs
    where [Row] = @i
   
    set @sql = 'drop '+ @Type +' '+@spToDelete;
    print @sql

 execute(@sql);

    select @i=min([Row]) from #tempSPs where [Row] > @i
end;
GO
