USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Utilerias.udf_NumToWords ( 
                @num AS INTEGER 
)       RETURNS VARCHAR(50)
AS
BEGIN

DECLARE @words AS VARCHAR(50)

IF      @num =     0 SELECT @words = 'Zero'
ELSE IF @num <    20 SELECT @words = word FROM sequence WHERE seq = @num
ELSE IF @num <   100 (SELECT @words = TTens.word + ' ' + TUnits.word 
                      FROM Sequence AS TUnits
                     CROSS JOIN Sequence AS TTens
                     WHERE TUnits.seq = (@num % 100) % 10
                       AND TTens.seq = (@num % 100) - (@num % 100) % 10 
                    )
ELSE IF @num =   100 (SELECT @words = THundreds.word + ' Hundred'
                      FROM Sequence AS THundreds
                     WHERE THundreds.seq = (@num / 100)
                    )
ELSE IF @num <  1000 (
                    SELECT @words = THundreds.word + ' Hundred and ' 
                                    + TTens.word + ' ' + TUnits.word 
                      FROM Sequence AS TUnits
                     CROSS JOIN Sequence AS TTens
                     CROSS JOIN Sequence AS THundreds
                     WHERE TUnits.seq = (@num % 100) % 10
                       AND TTens.seq = (@num % 100) - (@num % 100) % 10 
                       AND THundreds.seq = (@num / 100)
                    )
ELSE IF @num =  1000 (SELECT @words = TThousand.word + ' Thousand'
                      FROM Sequence AS TThousand
                     WHERE TThousand.seq = (@num / 1000)
                    )
ELSE IF @num < 10000 (
                    SELECT @words = TThousand.word + ' Thousand ' 
                                    + THundreds.word + ' Hundred and ' 
                                    + TTens.word + ' ' + TUnits.word 
                      FROM Sequence AS TUnits
                     CROSS JOIN Sequence AS TTens
                     CROSS JOIN Sequence AS THundreds
                     CROSS JOIN Sequence AS TThousand
                     WHERE TUnits.seq = (@num % 100) % 10
                       AND TTens.seq = (@num % 100) - (@num % 100) % 10 
                       AND THundreds.seq = (@num / 100) - (@num / 1000) * 10
                       AND TThousand.seq = (@num / 1000)
                    )
ELSE SELECT @words = STR(@num)

RETURN @words

END
GO
