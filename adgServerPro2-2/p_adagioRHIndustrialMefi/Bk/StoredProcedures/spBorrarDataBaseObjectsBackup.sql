USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Bk].[spBorrarDataBaseObjectsBackup](
    @BKID varchar(50)
)
as
	declare 
		@spToDelete varchar(255),
		@i int = 0,
		@sql varchar(max),
		@tipo varchar(255)
	;


	if object_id('tempdb..#tempSPs') is not null drop table #tempSPs;

	select Nombre as SP, Tipo, ROW_NUMBER()over(order by Nombre) as [Row]
	into #tempSPs
	from [Bk].[tblDatabaseObjects]
	where BKID = @BKID

	select @i=min([Row]) from #tempSPs

	while exists(select 1 from #tempSPs where [Row] >= @i)
	begin
		select 
			@spToDelete=SP,
			@tipo = tipo
		from #tempSPs
		where [Row] = @i
   
		set @sql = FORMATMESSAGE(
			'drop %s %s', 
			case 
				when @tipo = 'P' then 'procedure'
				when @tipo in ('FN', 'IF', 'TF') then 'function'
			else 'procedure' end,
			@spToDelete
		);

		print @sql

		execute(@sql);

		select @i=min([Row]) from #tempSPs where [Row] > @i
	end;
GO
