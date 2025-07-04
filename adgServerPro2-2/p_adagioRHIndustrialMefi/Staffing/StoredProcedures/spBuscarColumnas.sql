USE [p_adagioRHIndustrialMefi]
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
					  @IDSucursal			- Identificador de la sucursal.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE PROCEDURE [Staffing].[spBuscarColumnas](
	@IDSucursal		INT = 0
	, @IDUsuario	INT = 0
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
			[enable] VARCHAR(15),
			[order] INT
		)		

		-- COLUMNAS BASE
		INSERT INTO @TblColumnas VALUES('Sucursal', @bold, @background, @textAlign, @verticalAlign, @color, @enable, -2)
		INSERT INTO @TblColumnas VALUES('Departamento', @bold, @background, @textAlign, @verticalAlign, @color, @enable, -1)
		INSERT INTO @TblColumnas VALUES('Puesto', @bold, @background, @textAlign, @verticalAlign, @color, @enable, 0)

		-- COLUMNAS ACTIVAS
		INSERT INTO @TblColumnas ([value], [bold], [background], [textAlign], [verticalAlign], [color], [enable], [order])
		SELECT CAST(CONCAT(CAST(P.PorcentajeInicial AS VARCHAR(3)), '_', CAST(P.PorcentajeFinal AS VARCHAR(3)), '%') AS VARCHAR(7)) AS PorcentajeString
				--Porcentaje
				, @bold
				, @background
				, @textAlign
				, @verticalAlign
				, @color
				, @enable
				, ROW_NUMBER() OVER (ORDER BY P.PorcentajeInicial) AS row_num
		FROM [Staffing].[tblCatPorcentajes] P
		WHERE P.IDSucursal = @IDSucursal AND
			  P.Activo = @Activo
		ORDER BY P.PorcentajeInicial

		-- RESULTADO
		SELECT * FROM @TblColumnas		
		ORDER BY [order]

END
GO
