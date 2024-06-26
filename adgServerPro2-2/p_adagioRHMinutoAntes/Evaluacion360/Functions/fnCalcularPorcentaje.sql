USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2023-01-22
-- Description:	
--	@IDTipoMedicionObjetivo
--	IDTipoMedicionObjetivo Nombre          TipoDato
--	---------------------- -------------------------
--	1                      Porcentaje     DECIMAL
--	2                      Cantidad       INT
--	3                      Fecha          DATE
--	4                      Días           INT
--	5                      Unidades       INT

-- =============================================
CREATE FUNCTION [Evaluacion360].[fnCalcularPorcentaje]
(
	@IDTipoMedicionObjetivo int,
	@Objetivo varchar(max),
	@Actual varchar(max),
	@FechaInicio date = NULL
)
RETURNS decimal(18,2)
AS
BEGIN
	declare
		@response decimal(18,2)
	;

	if (@IDTipoMedicionObjetivo in (1, 2, 4, 5))
	begin
		if (cast(@Objetivo as decimal(18,2)) < 1.0)
		begin
			set @response = 0
		end else
		begin
			set @response = ((cast(@Actual as decimal(18,2)) / cast(@Objetivo as decimal(18,2))) * 100.00)
		end
	end else if (@IDTipoMedicionObjetivo = 3)
	begin
		set @response = 
			(cast(DATEDIFF(DAY, @FechaInicio, @Actual) as decimal(18,2)) 
				/ 
			cast(DATEDIFF(DAY, @FechaInicio, @Objetivo) as decimal(18,2))) * 100
	end

	RETURN @response
END
GO
