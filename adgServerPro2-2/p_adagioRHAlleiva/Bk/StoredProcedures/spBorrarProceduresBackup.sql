USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Bk].[spBorrarProceduresBackup](
    @BKID varchar(50)
)
as
declare @spToDelete varchar(255)
 ,@i int = 0
 ,@sql varchar(max);


 if object_id('tempdb..#tempSPs') is not null
    drop table #tempSPs;

select NombreSP as SP, ROW_NUMBER()over(order by NombreSP) as [Row]
into #tempSPs
from [Bk].[tblStoredProcedures]
where BKID = @BKID

select @i=min([Row]) from #tempSPs

while exists(select 1 from #tempSPs where [Row] >= @i)
begin
    select @spToDelete=SP
    from #tempSPs
    where [Row] = @i
   
    set @sql = 'drop procedure '+@spToDelete;
    print @sql

 execute(@sql);

    select @i=min([Row]) from #tempSPs where [Row] > @i
end;
GO
