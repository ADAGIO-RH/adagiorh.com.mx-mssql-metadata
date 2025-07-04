USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca value de campos dinamicos
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-08-22
** Paremetros		: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-12-12			Alejandro Paredes	Se agregaron los campos IDCampo, AliasCampo, GrupoCampo y se cambio al esquema [APP]
2024-10-23			Alejandro Paredes	Se agrego "CONSULTA NUEVA" que obtiene los valores dinamicos, desde un json o desde un valor comun. Se aplico el Idioma.
***************************************************************************************************/

CREATE PROCEDURE [App].[spBuscarValorCamposDinamicos]    
    @IDUsuario INT,
	@IDValor INT,
    @FiltroTablas VARCHAR(100)
AS
	BEGIN

		DECLARE @IDIdioma VARCHAR(225)
		DECLARE @QuerySelect VARCHAR(MAX)
		DECLARE @Total INT
		DECLARE @ROW INT
				
		DECLARE @tblCamposDinamicos TABLE(
			[KEY] VARCHAR(MAX),
			[VALUE] VARCHAR(MAX)
		);
    
		DECLARE @tblTablaValores TABLE(
			[Tabla] VARCHAR(100),
			[IDCampo] VARCHAR(50),
			[Campos] VARCHAR(MAX),
			[RowNumber] INT
		)    

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');				

		INSERT INTO @tblTablaValores(Tabla, IDCampo, Campos, RowNumber)
		SELECT C.Tabla,
			   C.IDCampo,
			   STRING_AGG(C.Campo, ', ') AS Campos,
			   ROW_NUMBER() OVER(ORDER BY C.Tabla)
		FROM [APP].[tblCatCamposDinamicos] C 
		WHERE C.Tabla IN(SELECT item FROM [APP].[Split](@FiltroTablas,','))
		GROUP BY C.Tabla, IDCampo		
		--SELECT * FROM @tblTablaValores


		SELECT @Total = COUNT(*) FROM @tblTablaValores
		SET @Row = 1    
    
		WHILE(@Row <= @Total)
			BEGIN
			
				DECLARE @tabla VARCHAR(100)
				DECLARE @idCampo VARCHAR(50)
				DECLARE @campos VARCHAR(MAX)
			
				SELECT @tabla = V.Tabla,
					   @idCampo = V.IDCampo,
					   @campos = V.Campos
				FROM @tblTablaValores V WHERE V.RowNumber = @Row
				
				/***** CONSULTA VIEJA *****/
				/*
				SELECT @QuerySelect = CONCAT('SELECT B.[Key],
													 ISNULL(B.[Value], ''SIN DATO'')
											  FROM (SELECT ', @campos, ' FROM ', @tabla, ' WHERE ', @idCampo, ' = ', @IDValor, ') A
											  CROSS APPLY OPENJSON((SELECT A.* FOR JSON PATH, INCLUDE_NULL_VALUES, Without_Array_Wrapper)) B')
				*/											  
										 
				/***** CONSULTA NUEVA *****/
				SELECT @QuerySelect = CONCAT(
											'SELECT B.[Key], 
													ISNULL(
														CASE
															WHEN ISJSON(B.[Value]) = 1 
																THEN ISNULL(JSON_VALUE(B.[Value], FORMATMESSAGE(''$.%s.%s'', LOWER(REPLACE(''' + @IDIdioma + ''', ''-'', '''')), ''ValorDinamico'')), NULL)
															ELSE NULL
														END,
														ISNULL(B.[Value], ''SIN DATO'')
													) AS [Value]
												FROM (SELECT ', @campos, ' FROM ', @tabla, ' WHERE ', @idCampo, ' = ', @IDValor, ') A 
												CROSS APPLY OPENJSON((SELECT A.* FOR JSON PATH, INCLUDE_NULL_VALUES, Without_Array_Wrapper)) B'
											);
				--select @querySelect
				INSERT INTO @tblCamposDinamicos ([KEY],[VALUE])
				EXEC(@querySelect)		 				
			
				SET @Row = @Row + 1;

			END

		-- RESULTADO FINAL
		SELECT distinct * 
		FROM @tblCamposDinamicos
		
	END
GO
