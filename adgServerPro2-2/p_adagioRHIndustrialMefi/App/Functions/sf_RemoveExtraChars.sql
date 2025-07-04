USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION App.sf_RemoveExtraChars (@NAME nvarchar(50))
RETURNS nvarchar(50)
AS
BEGIN
  declare @TempString nvarchar(100)
  set @TempString = @NAME 
  set @TempString = LOWER(@TempString)
  set @TempString =  replace(@TempString,'à', 'a')
  set @TempString =  replace(@TempString,'è', 'e')
  set @TempString =  replace(@TempString,'é', 'e')
  set @TempString =  replace(@TempString,'ì', 'i')
  set @TempString =  replace(@TempString,'ò', 'o')
  set @TempString =  replace(@TempString,'ù', 'u')
  
  set @TempString =  replace(@TempString,'á', 'a')
  set @TempString =  replace(@TempString,'é', 'e')
  set @TempString =  replace(@TempString,'í', 'i')
  set @TempString =  replace(@TempString,'ó', 'o')
  set @TempString =  replace(@TempString,'ú', 'u')

  return @TempString
END
GO
