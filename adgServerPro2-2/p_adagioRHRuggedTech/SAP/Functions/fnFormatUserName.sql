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
	if (@UserName in ('aterrones', 'hhuerta', 'lcoronel', 'mmonteno', 'smiranda'))
	begin
		set @UserName = UPPER(LEFT(@UserName, 2)) + RIGHT(@UserName, LEN(@UserName) - 2);
	end else
	if (@UserName in ('mirodriguez'))
	begin
		set @UserName = UPPER(LEFT(@UserName, 3)) + RIGHT(@UserName, LEN(@UserName) - 3);
	end

	RETURN @UserName;

END
GO
