USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Utilerias].[spBuscarSQLObjectsFilter](
	@Schema varchar(256) = null
	,@filter varchar(100) = null
) as

select o.object_id, '['+s.name+'].['+o.name+']' as [Object]
from sys.all_objects o 
	join sys.schemas s on o.schema_id = s.schema_id
	left join sys.all_sql_modules m on o.object_id = m.object_id
where (s.name = @Schema or @Schema is null)
	and (m.definition like '%'+@filter+'%' or @filter is null)
GO
