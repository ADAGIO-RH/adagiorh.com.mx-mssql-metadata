USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [App].[fnBuscarDataTypes]()
RETURNS @DataTypes TABLE
(
	TipoDato Varchar(250)
)
AS
BEGIN
		insert into @DataTypes
		select TipoDato from [App].[tblCatTiposDatos]
		--SELECT 'CHAR'

		--insert into @DataTypes
		--SELECT 'VARCHAR'

		--insert into @DataTypes
		--SELECT 'BIT'

		--insert into @DataTypes
		--SELECT 'SMALLINT'

		--insert into @DataTypes
		--SELECT 'INT'

		--insert into @DataTypes
		--SELECT 'DECIMAL'

		--insert into @DataTypes
		--SELECT 'NUMERIC'

		--insert into @DataTypes
		--SELECT 'REAL'

		--insert into @DataTypes
		--SELECT 'FLOAT'

		--insert into @DataTypes
		--SELECT 'DATE'

		--insert into @DataTypes
		--SELECT 'TIME'

		--insert into @DataTypes
		--select 'json_object'

		--insert into @DataTypes
		--select 'ArrayInt'

		--insert into @DataTypes
		--select 'bool'

		--insert into @DataTypes
		--select 'string'
	--SELECT * FROM @DataTypes
	RETURN

END
GO
