USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spBorrarProceduresDeConceptos]
as
declare @spToDelete varchar(255)
 ,@i int = 0
 ,@sql varchar(max);


 if object_id('tempdb..#tempSPs') is not null
    drop table #tempSPs;

select '['+s.name+'].['+o.name+']' as SP, ROW_NUMBER()over(order by o.name) as [Row]
into #tempSPs
from [sys].[objects] o
join [sys].[schemas] s on (o.schema_id = s.schema_id) and s.name = 'Nomina'
where [o].[type] = 'P' and ('['+s.name+'].['+o.name+']') like '%spConcepto%'

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
