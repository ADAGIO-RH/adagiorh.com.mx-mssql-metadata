USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Utilerias].[GET_DIGIT2WORD] (
  @M_AMOUNT AS NUMERIC(18,0)
) RETURNS VARCHAR(100)
BEGIN
  DECLARE @M_FIRST AS VARCHAR(50)
  DECLARE @M_LAST AS VARCHAR(50)
  
  SELECT @M_FIRST = 
    CASE WHEN @M_AMOUNT >= 10 AND @M_AMOUNT <= 19 THEN
      CASE @M_AMOUNT 
        WHEN 10 THEN 'TEN'
        WHEN 11 THEN 'ELEVEN'
        WHEN 12 THEN 'TWELVE'
        WHEN 13 THEN 'THIRTEEN'
        WHEN 14 THEN 'FOURTEEN'
        WHEN 15 THEN 'FIFTEEN'
        WHEN 16 THEN 'SIXTEEN'
        WHEN 17 THEN 'SEVENTEEN'
        WHEN 18 THEN 'EIGHTEEN'
        WHEN 19 THEN 'NINETEEN'
        ELSE ''  
      END
    ELSE
      CASE WHEN LEN(@M_AMOUNT) = 2 THEN
        CASE LEFT(@M_AMOUNT,1) 
          WHEN  2 THEN 'TWENTY '
          WHEN  3 THEN 'THIRTY '
          WHEN  4 THEN 'FORTY '
          WHEN  5 THEN 'FIFTY '
          WHEN  6 THEN 'SIXTY '
          WHEN  7 THEN 'SEVENTY '
          WHEN  8 THEN 'EIGHTY '
          WHEN  9 THEN 'NINETY '
          ELSE ''
        END
      ELSE
        ''
      END
    END
  SELECT @M_LAST = 
  CASE WHEN @M_AMOUNT >= 10 AND @M_AMOUNT <= 19 THEN
    ''
  ELSE
    CASE RIGHT(@M_AMOUNT,1) 
      WHEN  1 THEN 'ONE'
      WHEN  2 THEN 'TWO'
      WHEN  3 THEN 'THREE'
      WHEN  4 THEN 'FOUR'
      WHEN  5 THEN 'FIVE'
      WHEN  6 THEN 'SIX'
      WHEN  7 THEN 'SEVEN'
      WHEN  8 THEN 'EIGHT'
      WHEN  9 THEN 'NINE'
      ELSE ''
    END
  END
  RETURN RTRIM(LTRIM(@M_FIRST + @M_LAST))
END
GO
