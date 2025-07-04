USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Convierte una fecha de String por formato
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-04-05
** Paremetros		:
   @Formato = FL: Fecha Large
			  FM: Fecha Medium
			  FC: Fecha Corta
** DataTypes Relacionados:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2021-11-29			Aneudy Abreu	Correción de format FC para el idioma Ingles
***************************************************************************************************/
CREATE FUNCTION [Utilerias].[fnDateToStringByFormat](
	-- Add the parameters for the function here
	 @Fecha Date
	,@Formato varchar(10)
	,@IdiomaSQL varchar(100)
)
RETURNS varchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @FechaStr varchar(100);

	-- Add the T-SQL statements to compute the return value here
	SELECT @FechaStr = 
		case when @Formato = 'FL' then
				case when @IdiomaSQL = 'Spanish' then UPPER(cast(DATENAME(DW,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' ' +cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' de '+ cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)
								+' del '+ cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar))
				when @IdiomaSQL = 'English' then  UPPER(cast(DATENAME(DW,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+', '+cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)
								+' '+cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+', '+cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar))
				else UPPER(cast(DATENAME(DW,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' ' +cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' de '+ cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)
								+' del '+ cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar)) end
			when @Formato = 'FM' then
				case when @IdiomaSQL = 'Spanish' then UPPER(cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' de '+ (cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar))
								+' del '+ cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar) )
					when @IdiomaSQL = 'English' then UPPER(cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)
								+' '+cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))	
								+', '+ cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar) )
					else UPPER(cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max))
								+' de '+ (cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar))
								+' del '+ cast(DATEPART(YEAR,isnull(@Fecha,'1900-01-01'))as varchar) ) end
			when @Formato = 'FC' then
				case when @IdiomaSQL = 'Spanish' then 
							--Configuracion para el DIA
							CASE WHEN ( DATEPART(day,isnull(@Fecha,'1900-01-01')) BETWEEN 1 AND 9 ) THEN
								+'0'
							ELSE '' END 
								+ UPPER(cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max)) +
							--Configuracion para el MES
							CASE WHEN ( DATEPART(MONTH,isnull(@Fecha,'1900-01-01')) BETWEEN 1 AND 9 ) THEN
								+'/0'
							ELSE '/' END
								+ (cast(DATEPART(MONTH,isnull(@Fecha,'1900-01-01')) as varchar))
								+'/'+ (cast(DATENAME(YEAR,isnull(@Fecha,'1900-01-01')) as varchar)))
					when @IdiomaSQL = 'English' then 
							--Configuracion para el MES
							CASE WHEN ( DATEPART(MONTH,isnull(@Fecha,'1900-01-01')) BETWEEN 1 AND 9 ) THEN
								+'0'
							ELSE ' ' END
								+ (cast(DATEPART(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)) +'/'+
							CASE WHEN ( DATEPART(day,isnull(@Fecha,'1900-01-01')) BETWEEN 1 AND 9 ) THEN
								+'/0'
							ELSE '' END 
								+ UPPER(cast(DATEPART(day,isnull(@Fecha,'1900-01-01')) as varchar(max)) 
								+'/'+ (cast(DATENAME(YEAR,isnull(@Fecha,'1900-01-01')) as varchar)))
							--UPPER(cast(DATENAME(MONTH,isnull(@Fecha,'1900-01-01')) as varchar)
						--	+'/'+ (cast(DATEPART(MONTH,isnull(@Fecha,'1900-01-01')) as varchar))
							--+'/'+ (cast(DATENAME(YEAR,isnull(@Fecha,'1900-01-01')) as varchar)))
				end
			else '' end;
	-- Return the result of the function
	RETURN @FechaStr
END
GO
