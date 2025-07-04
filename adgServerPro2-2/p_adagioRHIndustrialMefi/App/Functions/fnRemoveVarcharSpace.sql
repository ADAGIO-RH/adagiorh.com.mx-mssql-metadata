USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2022-09-10
-- Description:	Quita los especios, tabs y enter de un los extramos de un varchar
-- =============================================
CREATE FUNCTION App.fnRemoveVarcharSpace 
(
	-- Add the parameters for the function here
	@text varchar(max)
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(max)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = LTRIM(RTRIM(REPLACE(REPLACE(@text, CHAR(13), ''), CHAR(10), '')))

	-- Return the result of the function
	RETURN @Result

END
GO
