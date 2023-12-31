USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Utilerias].[fnCapitalize] ( @Cadena VARCHAR(max) )
    RETURNS VARCHAR(max)
AS 
BEGIN
 
    return stuff((
       select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
       from (select cast(replace((select @Cadena as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
         cross apply T1.X.nodes('text()') as T2(X)
         cross apply (select T2.X.value('.', 'varchar(30)')) as T3(V)
       for xml path(''), type
       ).value('text()[1]', 'varchar(30)'), 1, 1, '') 
    --Replace accent marks
    --RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Cadena, 'á', 'A'), 'é','E'), 'í', 'I'), 'ó', 'O'), 'ú','U'),'ñ','N') 
END
GO
