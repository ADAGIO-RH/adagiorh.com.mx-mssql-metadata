USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Bk].[spCrearDataBaseObjectsBackup](
    @BKID varchar(50)
)
as
	declare 
		@spToCreate nvarchar(max)
		 ,@i int = 0
		 ,@sql varchar(max)
	;


	 if object_id('tempdb..#tempSPs') is not null drop table #tempSPs;

	select Definition as SP, ROW_NUMBER()over(order by Nombre) as [Row]
	into #tempSPs
	from [Bk].[tblDatabaseObjects]
	where BKID = @BKID

	select @i=min([Row]) from #tempSPs

	while exists(select 1 from #tempSPs where [Row] >= @i)
	begin
		select @spToCreate=SP
		from #tempSPs
		where [Row] = @i      

		begin try
			execute(@spToCreate);
		end try
		begin catch
			print ERROR_MESSAGE()
		end catch

		select @i=min([Row]) from #tempSPs where [Row] > @i
	end;
GO
