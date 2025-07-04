USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Bk].[spRespaldarSPPorDataType]'dtUserInfo','20231123_ZK'

CREATE   PROCEDURE [Bk].[spRespaldarSPPorDataType](
   -- @schema varchar(256)
    @DataType varchar(256)
    ,@BKID varchar(50)
)
as
BEGIN
    insert into [Bk].[tblStoredProcedures]([Definition],NombreSP,BKID, [Type])
    select m.definition, '['+s.name+'].['+o.name+']',@BKID, CASE WHEN (o.type = 'P') THEN 'PROCEDURE' 
																 WHEN (o.type = 'TF') THEN 'FUNCTION'
																 WHEN (o.type = 'FN') THEN 'FUNCTION'
																END
    From sys.sql_modules m
	    join sys.objects o
		    on m.object_ID = o.object_ID
	   join sys.schemas s on o.schema_id = s.schema_id 
    where o.Name in (Select SPECIFIC_NAME 
				    From   Information_Schema.PARAMETERS 
				    Where  USER_DEFINED_TYPE_NAME = @DataType
						--and SPECIFIC_SCHEMA = @schema
						) and o.type  in ('P','TF','FN')

    select *
    from [Bk].[tblStoredProcedures]
    where BKID = @BKID
END
GO
