USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Evaluacion360].[fnBuscarValorLadoDerechoControlDeslizable] (
	@text varchar(max)
) returns varchar(max)
as 
begin
	declare @ValueToFind varchar(max) = '"LadoDerecho":"',
		@resp varchar(max);

	select 
		@resp = substring(substring(@text, CHARINDEX(@ValueToFind,@text) + LEN(@ValueToFind), len(@text)), 0,CHARINDEX('"', substring(@text, 38, len(@text))))

	return @resp
end
GO
