USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Tzdb].[GetTimezone]
(
    @ZoneId int
   
)
RETURNS varchar(10)
AS
BEGIN

DECLARE 
		
		@OffsetMinutes int,
		@utc datetime2 = GetDate(),

		@ID int = 0,
		@DevSN varchar(50) = null,
		@final varchar(6)

   SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
    FROM [Tzdb].[Intervals]
    WHERE [ZoneId] = @ZoneId
      AND [UtcStart] <= @utc AND [UtcEnd] > @utc

	select 
		@final = 
		/* agrega signo de - cuando @OffsetMinutes sea menor a 0*/
			case when @OffsetMinutes < 0 then '-' else '' end +
		/* 		
			agrega 0 a la izquierda
			multiplica por -1 cuando @OffsetMinutes sea menor a 0 para que no agregue el signo de - al resultado
		*/
			case when @OffsetMinutes < 0 then App.fnAddString(2, cast((@OffsetMinutes / 60) * -1 as varchar), '0', 1) else cast((@OffsetMinutes / 60) as varchar(2)) end
		/* agregamos la división : entre horas y minutos */
			 + ':' + 
		/* determinamos los minutos y agregamos 0 a la izquierda */
		App.fnAddString(2, cast((@OffsetMinutes % 60) as varchar), '0', 1)

    RETURN @final
END
GO
