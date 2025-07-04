USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [App].[fnRegexMatch] (
  @Input VARCHAR(MAX),
  @Pattern VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
  DECLARE @IsMatch BIT;

  IF PATINDEX('%' + @Pattern + '%', @Input) > 0
    SET @IsMatch = 1;
  ELSE
    SET @IsMatch = 0;

  RETURN @IsMatch;
END;
GO
