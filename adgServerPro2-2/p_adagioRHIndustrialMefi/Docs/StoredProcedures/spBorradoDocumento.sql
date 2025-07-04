USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[Docs].[spBorradoDocumento] 39
CREATE proc [Docs].[spBorradoDocumento](
	@IDDocumento int,
	@IDUsuario int
) as
declare  
	 @SQLScriptSelect nvarchar(max)
	,@SQLScriptDelete nvarchar(max)
;


--select *
--from RH.tblEmpleadosMaster
--where IDCliente <> 1

--select * from RH.tblCatClientes

--select *
--from RH.tblEmpleados

	if object_id('tempdb..#tempFksIDDocumento') is not null drop table #tempFksIDDocumento;


	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDDocumento = '+CAST(@IDDocumento as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDDocumento = '+CAST(@IDDocumento as varchar(100))
	INTO #tempFksIDDocumento
	from  sysobjects f
	inner join sys.objects c on f.parent_obj = c.object_id
	inner join sysreferences r on f.id = r.constid
	inner join sysobjects p on r.rkeyid = p.id
	inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
	inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDDocumento' and p.name = 'tblCarpetasDocumentos'


	--SELECT SCHEMA_NAME(schema_id) As SchemaName 
 --     ,name As TableName 
 --  FROM sys.objects
 --  WHERE type = 'U'

	--select * from sys.objects where object_id = 2099048
	--select * from sysobjects where id = 2099048
	--select * from sys.schemas
	--select * from #tempFksIDEmpleado

--	select * from #tempFksIDDocumento



	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDDocumento
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDDocumento

	SELECT @SQLScriptSelect = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDDocumento
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDDocumento

	--print @SQLScriptSelect	
	--print @SQLScriptDelete	
	--select @SQLScriptSelect	
	--select @SQLScriptDelete

--	execute(@SQLScriptSelectUsuario)	
	--execute(@SQLScriptDeleteUsuario)

--	execute(@SQLScriptSelect)	
	execute(@SQLScriptDelete)

	delete from docs.tblCarpetasDocumentos where IDItem = @IDDocumento
GO
