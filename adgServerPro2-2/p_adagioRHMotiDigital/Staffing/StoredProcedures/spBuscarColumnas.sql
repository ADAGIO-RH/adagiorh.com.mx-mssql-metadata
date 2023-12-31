USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar columnas porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-09-04
** Paremetros		: @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarColumnas](
	@IDUsuario	  INT = 0	
)
AS
	BEGIN	
		
		DECLARE @Activo INT = 1
				, @bold VARCHAR(15) = 'true'
				, @background VARCHAR(15) = '#5d77ff'
				, @textAlign VARCHAR(15) = 'center'
				, @verticalAlign VARCHAR(15) = 'center'
				, @color VARCHAR(15) = 'white'
				, @enable VARCHAR(15) = 'false'
				;

		DECLARE @TblColumnas TABLE(
			[value] VARCHAR(15),
			[bold] VARCHAR(15),
			[background] VARCHAR(15),
			[textAlign] VARCHAR(15),
			[verticalAlign] VARCHAR(15),
			[color] VARCHAR(15),
			[enable] VARCHAR(15)
		)		

		-- COLUMNAS BASE
		INSERT INTO @TblColumnas VALUES('Sucursal', @bold, @background, @textAlign, @verticalAlign, @color, @enable)
		INSERT INTO @TblColumnas VALUES('Puesto', @bold, @background, @textAlign, @verticalAlign, @color, @enable)

		-- COLUMNAS ACTIVAS
		INSERT INTO @TblColumnas ([value], [bold], [background], [textAlign], [verticalAlign], [color], [enable])
		SELECT   CAST(CONCAT(CAST(Porcentaje AS varchar(20)), '%') AS varchar(25)) AS PorcentajeString
				--Porcentaje
				, @bold
				, @background
				, @textAlign
				, @verticalAlign
				, @color
				, @enable
		FROM [Staffing].[tblCatPorcentajes]
		WHERE Activo = @Activo

		-- RESULTADO
		SELECT * FROM @TblColumnas

END
GO
