USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spBorrarAplicacion (@IDAplicacion varchar(255)) as
declare  
	 @SQLScriptSelect nvarchar(max)
	,@SQLScriptDelete nvarchar(max)

	,@IDUsuario int
	--,@IDAplicacion varchar(255) = 'ConfiguracionNorma035'
;

	if object_id('tempdb..#tempFksAplicacion') is not null drop table #tempFksAplicacion;

	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDAplicacion = '''+@IDAplicacion+''''
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDAplicacion = '''+@IDAplicacion+''''
	INTO #tempFksAplicacion
	from  sysobjects f
	inner join sys.objects c on f.parent_obj = c.object_id
	inner join sysreferences r on f.id = r.constid
	inner join sysobjects p on r.rkeyid = p.id
	inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
	inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDAplicacion' and p.name = 'tblCatAplicaciones'


	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksAplicacion
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksAplicacion

	SELECT @SQLScriptSelect = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksAplicacion
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksAplicacion

	print @SQLScriptDelete
	execute(@SQLScriptSelect)	
	execute(@SQLScriptDelete)

	delete from App.tblCatAplicaciones where IDAplicacion = @IDAplicacion
GO
