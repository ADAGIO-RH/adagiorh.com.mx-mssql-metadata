USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [App].[spBorradoFisicoConceptos]
as


raiserror('¿Estás seguro de realizar esta acción?',16,1);
return


declare  
	 @SQLScriptSelect nvarchar(max)
	,@SQLScriptDelete nvarchar(max)
	,@SQLScriptDropSPs nvarchar(max)
;

	if object_id('tempdb..#tempFksIDConceptos') is not null drop table #tempFksIDConceptos;
	if object_id('tempdb..#tempSpConceptos') is not null drop table #tempSpConceptos;

	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))
	INTO #tempFksIDConceptos
	from  sysobjects f
		inner join sys.objects c on f.parent_obj = c.object_id
		inner join sysreferences r on f.id = r.constid
		inner join sysobjects p on r.rkeyid = p.id
		inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
		inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDConcepto' and p.name = 'tblCatConceptos'

	select 
		SQLScriptDropSPs = N'drop proc '+NombreProcedure
	INTO #tempSpConceptos
	from Nomina.tblCatConceptos

	SELECT @SQLScriptDropSPs = STUFF((
            SELECT CHAR(10) + SQLScriptDropSPs
            FROM #tempSpConceptos
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempSpConceptos

	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDConceptos
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDConceptos

	SELECT @SQLScriptSelect = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDConceptos
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDConceptos

	print @SQLScriptDropSPs
	print @SQLScriptSelect
	print @SQLScriptDelete

	execute(@SQLScriptSelect)	
	execute(@SQLScriptDelete)
	execute(@SQLScriptDropSPs)

	delete from Nomina.tblCatConceptos

--delete from Nomina.tblPrestamosDetalles
--delete from Nomina.tblPrestamos
--delete from Nomina.tblDetallePeriodo
--delete from Nomina.tblCatTiposPrestamo
--delete from Nomina.tblDetallePeriodoFiniquito
--delete from RH.tblPagoEmpleado
--delete from Reportes.tblConfigReporteRayas
--delete from Nomina.TblLayoutPagoParametros
--delete from Nomina.tblLayoutPago  
--select * from Nomina.TblLayoutPagoParametros
GO
