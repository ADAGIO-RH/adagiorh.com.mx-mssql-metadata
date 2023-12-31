USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [SAP].[fnFormatUserName]
(
	@UserName varchar(500)
)
RETURNS varchar(500)
AS
BEGIN
	 
	set @UserName = lower(COALESCE(REPLACE(@UserName,'@carhartt.com',''),''))

	-- LCoronel y ATerrones. 
	if (@UserName in ('lcoronel', 'aterrones', 'hhuerta'))
	begin
		set @UserName = UPPER(LEFT(@UserName, 2)) + RIGHT(@UserName, LEN(@UserName) - 2);
	end

	RETURN @UserName;

END
GO
