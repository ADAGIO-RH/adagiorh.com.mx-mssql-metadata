USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Formula de transformacion lineal.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-03-12
** Paremetros		: @Valor					Valor a transformar.
**					: @Escala_Vieja_Minima		Numero minimo de escala vieja.
**					: @Escala_Vieja_Maxima		Numero maximo de escala vieja.
**					: @Escala_Nueva_Minima		Numero minimo de escala nueva.
**					: @Escala_Nueva_Maxima		Numero maximo de escala nueva.
** IDAzure			: 830

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   FUNCTION [Evaluacion360].[fnTransformacionLineal]
(
	@Valor					DECIMAL(18, 2)
	, @Escala_Vieja_Minima	INT
	, @Escala_Vieja_Maxima	INT
	, @Escala_Nueva_Minima DECIMAL(18, 2)
    , @Escala_Nueva_Maxima DECIMAL(18, 2)
)
RETURNS DECIMAL(18,2)
AS
	BEGIN

		DECLARE @Resultado DECIMAL(18,2);

		-- FORMULA DE LA FUNCION
		SET @Resultado = ((@Valor - @Escala_Vieja_Minima) * (@Escala_Nueva_Maxima - @Escala_Nueva_Minima)) / (@Escala_Vieja_Maxima - @Escala_Vieja_Minima) + @Escala_Nueva_Minima;
				
		RETURN @Resultado;
	END;
GO
