USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Utilerias].[fnHTMLStr] ( @HTMLText VARCHAR (Max))
Returns varchar(max)
AS

BEGIN
SET @HTMLText=UPPER(@HTMLText)
DECLARE @Start INT
DECLARE @FinalString VARCHAR(max)

		DECLARE @End INT
		DECLARE @Length INT

		SET @Start = CHARINDEX('<',@HTMLText)
		SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
		SET @Length = (@End - @Start) + 1
		WHILE @Start > 0
		AND @End > 0
		AND @Length > 0
		BEGIN
		SET @HTMLText = STUFF(@HTMLText,@Start,@Length,' ')
		SET @Start = CHARINDEX('<',@HTMLText)
		SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
		SET @Length = (@End - @Start) + 1
		END

        
		SET @FinalString= LTRIM(RTRIM(@HTMLText))
        SET @FinalString= REPLACE(@FinalString,'&nbsp;',' ')
        SET @FinalString= REPLACE(@FinalString,'&AACUTE;','Á')
        SET @FinalString= REPLACE(@FinalString,'&EACUTE;','É')
        SET @FinalString= REPLACE(@FinalString,'&IACUTE;','Í')
        SET @FinalString= REPLACE(@FinalString,'&OACUTE;','Ó')
        SET @FinalString= REPLACE(@FinalString,'&UACUTE;','Ú')
        SET @FinalString= REPLACE(@FinalString,'&NTILDE;','Ñ')
        SET @FinalString= REPLACE(@FinalString,'&EURO;','')
        SET @FinalString= REPLACE(@FinalString,'&IEXCL;','¡')
        SET @FinalString= REPLACE(@FinalString,'&IQUEST;','¿')
        
        

        
        RETURN @FinalString

END

GO
