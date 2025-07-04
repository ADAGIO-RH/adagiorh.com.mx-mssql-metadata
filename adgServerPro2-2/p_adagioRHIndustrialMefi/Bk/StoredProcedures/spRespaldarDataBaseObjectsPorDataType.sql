USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [Bk].[spRespaldarDataBaseObjectsPorDataType](
    @DataType varchar(256),
	@BKID varchar(50)
) as

    insert into [Bk].[tblDatabaseObjects]([Definition],[Nombre],BKID, Tipo)
    select m.definition, '['+s.name+'].['+o.name+']',@BKID, o.type
    From sys.sql_modules m
	    join sys.objects o
		    on m.object_ID = o.object_ID
	   join sys.schemas s on o.schema_id = s.schema_id 
    where o.Name in (Select SPECIFIC_NAME 
				    From   Information_Schema.PARAMETERS 
				    Where  USER_DEFINED_TYPE_NAME = @DataType
						--and SPECIFIC_SCHEMA = @schema
						)

    select *
    from [Bk].[tblDatabaseObjects]
    where BKID = @BKID
GO
