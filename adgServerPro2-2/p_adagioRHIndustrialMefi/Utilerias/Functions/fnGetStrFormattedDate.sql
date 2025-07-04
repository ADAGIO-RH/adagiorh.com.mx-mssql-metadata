USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Utilerias.fnGetStrFormattedDate (
    @IDIdioma NVARCHAR(5),
    @Date DATETIME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @FormattedDate NVARCHAR(MAX)

    SELECT @FormattedDate =
        CASE 
            WHEN @IDIdioma = 'en-US' THEN
                CASE 
                    WHEN DATEDIFF(HOUR, @Date, GETDATE()) = 0 AND DATEDIFF(MINUTE, @Date, GETDATE()) < 10 THEN 'Just now'
                    WHEN DATEDIFF(HOUR, @Date, GETDATE()) = 0 AND DATEDIFF(MINUTE, @Date, GETDATE()) >= 10 THEN 'About ' + CAST(DATEDIFF(MINUTE, @Date, GETDATE()) AS NVARCHAR) + ' minutes ago'
                    WHEN DATEDIFF(DAY, @Date, GETDATE()) = 0 AND DATEDIFF(HOUR, @Date, GETDATE()) = 1 THEN 'An hour ago'
                    WHEN DATEDIFF(DAY, @Date, GETDATE()) = 0 AND DATEDIFF(HOUR, @Date, GETDATE()) > 1 THEN 'About ' + CAST(DATEDIFF(HOUR, @Date, GETDATE()) AS NVARCHAR) + ' hours ago'
                    WHEN DATEDIFF(WEEK, @Date, GETDATE()) = 0 AND DATEDIFF(DAY, @Date, GETDATE()) = 1 THEN 'A day ago'
                    WHEN DATEDIFF(WEEK, @Date, GETDATE()) = 0 AND DATEDIFF(DAY, @Date, GETDATE()) > 1 THEN 'About ' + CAST(DATEDIFF(DAY, @Date, GETDATE()) AS NVARCHAR) + ' days ago'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 0 AND DATEDIFF(WEEK, @Date, GETDATE()) = 1 THEN 'A week ago'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 0 AND DATEDIFF(WEEK, @Date, GETDATE()) > 1 THEN 'About ' + CAST(DATEDIFF(WEEK, @Date, GETDATE()) AS NVARCHAR) + ' weeks ago'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) < 12 AND DATEDIFF(MONTH, @Date, GETDATE()) = 1 THEN 'A month ago'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) < 12 AND DATEDIFF(MONTH, @Date, GETDATE()) > 1 THEN 'About ' + CAST(DATEDIFF(MONTH, @Date, GETDATE()) AS NVARCHAR) + ' months ago'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 12 THEN 'A year ago'
                    WHEN DATEDIFF(YEAR, @Date, GETDATE()) > 1 THEN 'About ' + CAST(DATEDIFF(YEAR, @Date, GETDATE()) AS NVARCHAR) + ' years ago'
                    ELSE CAST(@Date AS NVARCHAR)
                END
            WHEN @IDIdioma = 'es-MX' THEN
                CASE 
                    WHEN DATEDIFF(HOUR, @Date, GETDATE()) = 0 AND DATEDIFF(MINUTE, @Date, GETDATE()) < 10 THEN 'Hace un momento'
                    WHEN DATEDIFF(HOUR, @Date, GETDATE()) = 0 AND DATEDIFF(MINUTE, @Date, GETDATE()) >= 10 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(MINUTE, @Date, GETDATE()) AS NVARCHAR) + ' minutos'
                    WHEN DATEDIFF(DAY, @Date, GETDATE()) = 0 AND DATEDIFF(HOUR, @Date, GETDATE()) = 1 THEN 'Hace una hora'
                    WHEN DATEDIFF(DAY, @Date, GETDATE()) = 0 AND DATEDIFF(HOUR, @Date, GETDATE()) > 1 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(HOUR, @Date, GETDATE()) AS NVARCHAR) + ' horas'
                    WHEN DATEDIFF(WEEK, @Date, GETDATE()) = 0 AND DATEDIFF(DAY, @Date, GETDATE()) = 1 THEN 'Hace un día'
                    WHEN DATEDIFF(WEEK, @Date, GETDATE()) = 0 AND DATEDIFF(DAY, @Date, GETDATE()) > 1 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(DAY, @Date, GETDATE()) AS NVARCHAR) + ' días'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 0 AND DATEDIFF(WEEK, @Date, GETDATE()) = 1 THEN 'Hace una semana'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 0 AND DATEDIFF(WEEK, @Date, GETDATE()) > 1 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(WEEK, @Date, GETDATE()) AS NVARCHAR) + ' semanas'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) < 12 AND DATEDIFF(MONTH, @Date, GETDATE()) = 1 THEN 'Hace un mes'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) < 12 AND DATEDIFF(MONTH, @Date, GETDATE()) > 1 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(MONTH, @Date, GETDATE()) AS NVARCHAR) + ' meses'
                    WHEN DATEDIFF(MONTH, @Date, GETDATE()) = 12 THEN 'Hace un año'
                    WHEN DATEDIFF(YEAR, @Date, GETDATE()) > 1 THEN 'Hace aproximadamente ' + CAST(DATEDIFF(YEAR, @Date, GETDATE()) AS NVARCHAR) + ' años'
                    ELSE CAST(@Date AS NVARCHAR)
                END
            ELSE CAST(@Date AS NVARCHAR)
        END

    RETURN @FormattedDate
END;
GO
