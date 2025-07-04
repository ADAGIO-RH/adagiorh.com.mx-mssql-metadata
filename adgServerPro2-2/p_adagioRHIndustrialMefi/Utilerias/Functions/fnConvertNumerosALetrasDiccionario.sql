USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Utilerias].[fnConvertNumerosALetrasDiccionario]
(
	@Numero Decimal(25,4)
)
returns Varchar(Max)
AS
BEGIN
	
	DECLARE @NumeroTexto Varchar(MAX) = ''
		,@value bigint 

	set @value = cast(isnull(@Numero,0.00) as bigint)


	  if (@value = 0)      BEGIN set @NumeroTexto = 'CERO';END
      ELSE IF (@value = 1) BEGIN SET @NumeroTexto = 'UNO';END
      ELSE if (@value = 2) BEGIN set @NumeroTexto = 'DOS';END
      ELSE if (@value = 3) BEGIN set @NumeroTexto = 'TRES';END
      ELSE IF (@value = 4) BEGIN set @NumeroTexto = 'CUATRO';	END
      ELSE IF (@value = 5) BEGIN set @NumeroTexto = 'CINCO';	END
      ELSE IF (@value = 6) BEGIN set @NumeroTexto = 'SEIS';	END
      ELSE IF (@value = 7) BEGIN set @NumeroTexto = 'SIETE';	END
      ELSE IF (@value = 8) BEGIN set @NumeroTexto = 'OCHO';	END
      ELSE IF (@value = 9) BEGIN set @NumeroTexto = 'NUEVE';	END
      ELSE IF (@value = 10) BEGIN set @NumeroTexto = 'DIEZ';	END
      ELSE IF (@value = 11) BEGIN set @NumeroTexto = 'ONCE';	END
      ELSE IF (@value = 12) BEGIN set @NumeroTexto = 'DOCE';	END
      ELSE IF (@value = 13) BEGIN set @NumeroTexto = 'TRECE';	END
      ELSE IF (@value = 14) BEGIN set @NumeroTexto = 'CATORCE';	END
      ELSE IF (@value = 15) BEGIN set @NumeroTexto = 'QUINCE';	END
      ELSE IF (@value < 20) BEGIN set @NumeroTexto = 'DIECI' + [Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 10); END
      ELSE IF (@value = 20) BEGIN SET @NumeroTexto = 'VEINTE'; END
      ELSE IF (@value < 30)  BEGIN SET @numeroTexto = 'VEINTI' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 20); END
      ELSE IF (@value  = 30) BEGIN SET @numeroTexto = 'TREINTA';	END			
      ELSE IF (@value  = 40) BEGIN SET @numeroTexto = 'CUARENTA';	END
      ELSE IF (@value  = 50) BEGIN SET @numeroTexto = 'CINCUENTA';	END
      ELSE IF (@value  = 60) BEGIN SET @numeroTexto = 'SESENTA';	END
      ELSE IF (@value  = 70) BEGIN SET @numeroTexto = 'SETENTA';	END
      ELSE IF (@value  = 80) BEGIN SET @numeroTexto = 'OCHENTA';	END
      ELSE IF (@value  = 90) BEGIN SET @numeroTexto = 'NOVENTA';	END
      ELSE IF (@value < 100) BEGIN SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](cast(@value / 10 as int) * 10) + ' Y ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value % 10); END
      ELSE IF (@value = 100) BEGIN SET @numeroTexto = 'CIEN';	END
	  ELSE IF ((@value = 200) OR (@value = 300) OR (@value = 400) OR (@value = 600) OR (@value = 800)) BEGIN SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario]( cast(@value / 100 as int)) + 'CIENTOS'; END
      ELSE IF (@value = 500) BEGIN SET @numeroTexto = 'QUINIENTOS'; END
      ELSE IF (@value = 700) BEGIN SET @numeroTexto = 'SETECIENTOS'; END
      ELSE IF (@value = 900) BEGIN SET @numeroTexto = 'NOVECIENTOS'; END
	  ELSE IF (@value < 200) BEGIN SET @numeroTexto = 'CIENTO ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 100); END
	  ELSE IF (@value < 300) BEGIN SET @numeroTexto = 'DOSCIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 200); END
      ELSE IF (@value < 400) BEGIN SET @numeroTexto = 'TRESCIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 300); END
      ELSE IF (@value < 500) BEGIN SET @numeroTexto = 'CUATROCIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 400); END
      ELSE IF (@value < 600) BEGIN SET @numeroTexto = 'QUINIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 500); END
      ELSE IF (@value < 700) BEGIN SET @numeroTexto = 'SEISCIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 600); END
      ELSE IF (@value < 800) BEGIN SET @numeroTexto = 'SETECIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 700); END
      ELSE IF (@value < 900) BEGIN SET @numeroTexto = 'OCHOCIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 800); END
	  ELSE IF (@value < 1000) BEGIN SET @numeroTexto = 'NOVECIENTOS ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - 900); END
      ELSE IF (@value = 1000) BEGIN SET @numeroTexto = 'MIL'; END
      ELSE IF (@value < 2000) BEGIN SET @numeroTexto = 'MIL ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value % 1000); END
      ELSE IF (@value < 1000000)
            BEGIN
                
                IF(RIGHT(CAST(CAST(@value/1000 AS INT) AS varchar),1)=1)
                BEGIN
                    SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](CAST( @value / 1000 as int)) --+ ' MIL';
                    
                    IF(RIGHT(@NumeroTexto,1)='O')
                    BEGIN
                        SET @NumeroTexto = SUBSTRING(@NumeroTexto,1,LEN(@NumeroTexto)-1)+ ' MIL'; 
                    END
                    ELSE
                    BEGIN
                    SET @NumeroTexto = @NumeroTexto+' MIL'; 
                    END
                    
                END
                ELSE
                BEGIN 
                    SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](CAST( @value / 1000 as int)) + ' MIL';
                END
            
    
                if ((@value % 1000) > 0) SET @numeroTexto = @numeroTexto + ' ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value % 1000);
            END

            else if (@value = 1000000)BEGIN SET @numeroTexto = 'UN MILLON'; END
           else if (@value < 2000000) BEGIN SET @numeroTexto = 'UN MILLON ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value % 1000000); END
           else if (@value < 1000000000000)
            BEGIN
                
                
                IF (RIGHT(CAST(CAST(@value / 1000000 AS INT) AS VARCHAR(MAX)), 1) = 1)
                BEGIN
                    SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](Cast(@value / 1000000 AS BIGINT));
                    IF (RIGHT(@NumeroTexto, 1) = 'O')
                    BEGIN
                        SET @NumeroTexto = SUBSTRING(@NumeroTexto, 1, LEN(@NumeroTexto) - 1) + ' MILLONES';
                    END
                    ELSE
                    BEGIN
                        SET @NumeroTexto = @NumeroTexto + ' MILLONES';
                    END
                END
                ELSE
                BEGIN
                    SET @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](Cast(@value / 1000000 AS BIGINT)) + ' MILLONES ';
                END

                if ((@value - Cast(@value / 1000000 as bigint) * 1000000) > 0)BEGIN SET @numeroTexto = @numeroTexto + ' ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - Cast(@value / 1000000 as bigint) * 1000000); END
            END
            else if (@value = 1000000000000)BEGIN SET @numeroTexto = 'UN BILLON'; END
           else if(@value < 2000000000000) BEGIN SET @numeroTexto = 'UN BILLON ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value -Cast(@value / 1000000000000 as bigint) * 1000000000000); END
           else
           BEGIN
              
                
                IF (RIGHT(CAST(CAST(@value / 1000000000000 AS INT)AS VARCHAR), 1) = 1)
                BEGIN
                    SET  @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](Cast(@value / 1000000000000 as bigint)) --+ ' BILLONES';
                    IF(RIGHT(@NumeroTexto,1)='O')
                        BEGIN
                            SET @NumeroTexto = SUBSTRING(@NumeroTexto,1,LEN(@NumeroTexto)-1)+ ' BILLONES'; 
                        END
                    ELSE
                        BEGIN
                        SET @NumeroTexto = @NumeroTexto+' BILLONES'; 
                    END                
                END
                ELSE
                BEGIN
                     SET  @numeroTexto = [Utilerias].[fnConvertNumerosALetrasDiccionario](Cast(@value / 1000000000000 as bigint)) + ' BILLONES';
                END
                
                if ((@value - cast(@value / 1000000000000 as bigint) * 1000000000000) > 0) set @numeroTexto = @numeroTexto + ' ' +[Utilerias].[fnConvertNumerosALetrasDiccionario](@value - cast(@value / 1000000000000 as bigint) * 1000000000000);
            END

		 
	REturn @numeroTexto;
	
END
GO
