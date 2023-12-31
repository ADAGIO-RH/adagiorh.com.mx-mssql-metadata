USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [App].[spBorradoFisicoCliente](
	@IDCliente int
) as
declare  
	 @SQLScriptSelect nvarchar(max)
	,@SQLScriptDelete nvarchar(max)

	,@SQLScriptSelectUsuario nvarchar(max)
	,@SQLScriptDeleteUsuario nvarchar(max)

	,@IDUsuario int
;

--	select @IDUsuario = IDUsuario
--	from Seguridad.tblUsuarios
--	where IDEmpleado = @IDEmpleado



	if object_id('tempdb..#tempFksIDCliente') is not null drop table #tempFksIDCliente;
	if object_id('tempdb..#tempFksIDUsuario') is not null drop table #tempFksIDUsuario;

	/*select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDUsuario = '+CAST(@IDUsuario as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDUsuario = '+CAST(@IDUsuario as varchar(100))
	INTO #tempFksIDUsuario
	from  sysobjects f
	inner join sys.objects c on f.parent_obj = c.object_id
	inner join sysreferences r on f.id = r.constid
	inner join sysobjects p on r.rkeyid = p.id
	inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
	inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDUsuario' and p.name = 'tblUsuarios'
	*/
	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDCliente = '+CAST(@IDCliente as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDCliente = '+CAST(@IDCliente as varchar(100))
	INTO #tempFksIDCliente
	from  sysobjects f
	inner join sys.objects c on f.parent_obj = c.object_id
	inner join sysreferences r on f.id = r.constid
	inner join sysobjects p on r.rkeyid = p.id
	inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
	inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDCliente' and p.name = 'tblCatClientes'

	--SELECT SCHEMA_NAME(schema_id) As SchemaName 
 --     ,name As TableName 
 --  FROM sys.objects
 --  WHERE type = 'U'

	--select * from sys.objects where object_id = 2099048
	--select * from sysobjects where id = 2099048
	--select * from sys.schemas
	--select * from #tempFksIDEmpleado
/*
	SELECT @SQLScriptDeleteUsuario = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDUsuario
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

	SELECT @SQLScriptSelectUsuario = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDUsuario
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado
	*/

	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDCliente
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDCliente

	SELECT @SQLScriptSelect = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDCliente
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDCliente

	--print @SQLScriptSelect	
	print @SQLScriptDelete	
	--select @SQLScriptSelect	
	select @SQLScriptDelete

--	execute(@SQLScriptSelectUsuario)	
--	execute(@SQLScriptDeleteUsuario)

--	execute(@SQLScriptSelect)	
--	execute(@SQLScriptDelete)

--delete rh.tblCatClientes WHERE IDCliente = @IDCliente

GO
