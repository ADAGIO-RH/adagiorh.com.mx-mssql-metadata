USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Demo.spBuscarInfoTablas(
	@Schema varchar(255)
) as

SELECT info.[Schema]
		,'['+e.name+'].['+o.name+']' as Tabla
		,Lower(e.name+'_'+o.name) as IDElement
		,info.[Url]
		,ddps.row_count as Total
FROM sys.indexes AS i
  INNER JOIN sys.objects AS o ON i.OBJECT_ID = o.OBJECT_ID
  INNER JOIN sys.dm_db_partition_stats AS ddps ON i.OBJECT_ID = ddps.OBJECT_ID
  AND i.index_id = ddps.index_id 
  JOIN sys.schemas e on o.schema_id = e.schema_id
  join Demo.tblInfo info on info.Tabla = '['+e.name+'].['+o.name+']'
WHERE i.index_id < 2  AND o.is_ms_shipped = 0 
	and info.[Schema] = @Schema
ORDER BY e.name,o.name
GO
