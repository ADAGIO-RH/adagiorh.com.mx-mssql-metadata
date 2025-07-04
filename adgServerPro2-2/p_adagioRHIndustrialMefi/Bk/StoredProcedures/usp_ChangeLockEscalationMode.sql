USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE BK.usp_ChangeLockEscalationMode 
   (@mode varchar(10),
   @schema varchar(30),
   @tableNamepattern varchar(30),
   @patternLen int = 5)
AS
BEGIN
   DECLARE @tsql varchar(200)
   DECLARE @tablename varchar(60)
 
   DECLARE cur CURSOR FOR
    ( SELECT object_name (t.object_id) as table_name
      FROM sys.tables t , sys.schemas s
      WHERE charindex ( @tableNamepattern , object_name (t.object_id) ,1) > 0 
       and s.schema_id = t.schema_id 
       and s.name = @schema
       and t.is_ms_shipped = 0
       and len(@tableNamepattern) >= @patternLen )
   
   OPEN cur
   FETCH NEXT FROM cur INTO @tablename
 
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @tsql = 'ALTER TABLE ' + @schema + '.[' + @tableName + ']'+ ' SET ' + 
      '( LOCK_ESCALATION = ' + @mode + ' )'

      PRINT @tsql 
      EXEC (@tsql)

      FETCH NEXT FROM cur INTO @tablename
   END

   CLOSE cur
   DEALLOCATE cur
END
GO
