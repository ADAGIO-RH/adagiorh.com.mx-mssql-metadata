USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Bk].[spRespaldarSPPorSchemas](
    @schema varchar(256)
    ,@BKID varchar(50)
)
as
    insert into [Bk].[tblStoredProcedures]([Definition],NombreSP,BKID)
    select sqlm.definition, '['+s.name+'].['+o.name+']',@BKID
    from sys.sql_modules sqlm
	   join sys.objects o on sqlm.object_id = o.object_id and o.type = 'P'
	   join sys.schemas s on o.schema_id = s.schema_id and s.name = @schema

    select *
    from [Bk].[tblStoredProcedures]
    where BKID = @BKID
GO
