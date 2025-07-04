USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2022-04-11
-- Description:	Convierte en UPPER las keys de un object JSON
-- =============================================
CREATE FUNCTION App.UpperJSONKeys(
	@json nvarchar(max),
	@keys varchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	if (ISJSON(@json) != 1)
	begin
		return null
	end

	declare 
		@IDIdioma varchar(20),
		@key varchar(255)
	;
	
	select @IDIdioma=MIN(IDIdioma) from App.tblIdiomas

	while exists(select top 1 1 
			from App.tblIdiomas 
			where IDIdioma >= @IDIdioma)
	begin
		
		select @key=MIN(item) from App.Split(@keys, '|')

		while exists (select top 1 1
						from App.Split(@keys, '|') where item >= @key)
		begin

			SET @json = JSON_MODIFY(@json, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), @key), UPPER(JSON_VALUE(@json, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), @key))));
			
			select @key=MIN(item) from App.Split(@keys, '|') where item > @key
		end

		select @IDIdioma=MIN(IDIdioma)
		from App.tblIdiomas 
		where IDIdioma > @IDIdioma
	end

	return @json;
END
GO
