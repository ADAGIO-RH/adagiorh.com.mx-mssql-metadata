USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar configuracion de porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		: @IDConfiguracion			- Identificador de la configuracion.
					  @IDSucursal				- Identificador de la sucursal.
					  @IDPuesto					- Identificador del puesto.
					  @Porcentaje 				- Pordentaje asignado
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarConfPorcentajes](
	@IDConfiguracion INT = 0
	,@IDSucursal  	 INT = 0
	,@IDPuesto		 INT = 0
	,@Porcentaje	 INT = 0
	,@query			 VARCHAR(100) = '""'
	,@IDUsuario		 INT = 0
)
AS
BEGIN

	SET FMTONLY OFF;	

		SET LANGUAGE 'spanish'

		DECLARE @IDIdioma VARCHAR(20);

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					 ELSE '"' + @query + '*"' END

	
		SELECT CP.IDConfiguracion
			   , CP.IDSucursal
			   , S.Descripcion AS Sucursal
			   , CP.IDPuesto
			   ,ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto
			   , CP.Porcentaje
			   , 1 + IDConfiguracion AS Cantidad
		INTO #ConfFiltrados FROM [Staffing].[tblConfPorcentajes] CP
			JOIN [RH].[tblCatSucursales] S ON CP.IDSucursal = S.IDSucursal
			JOIN [RH].[tblCatPuestos] P ON CP.IDPuesto = P.IDPuesto
		WHERE ((CP.IDConfiguracion = @IDConfiguracion OR ISNULL(@IDConfiguracion, 0) = 0)) 
				AND ((CP.IDSucursal = @IDSucursal OR ISNULL(@IDSucursal, 0) = 0)) 
				AND ((CP.IDPuesto = @IDPuesto OR ISNULL(@IDPuesto, 0) = 0))
				AND ((CP.Porcentaje = @Porcentaje OR ISNULL(@Porcentaje, 0) = 0))
				AND (
					(@query = '""' OR CONTAINS(S.Descripcion, @query)) 
					OR
					(@query = '""' OR CONTAINS(P.Descripcion, @query))
					)

		
		SELECT * FROM #ConfFiltrados

		
		SELECT
			IDSucursal,
			sucursal,
			IDPuesto,
			puesto,
			[10], [20], [30], [40], [50], [60], [70], [80], [90], [100]
		FROM (
			SELECT
			    IDSucursal,
				sucursal,
				IDPuesto,
				puesto,
				cantidad,
				porcentaje
			FROM #ConfFiltrados
		) AS SourceTable
		PIVOT (
			MAX(cantidad)
			FOR porcentaje IN ([10], [20], [30], [40], [50], [60], [70], [80], [90], [100])
		) AS PivotTable
		ORDER BY IDSucursal, IDPuesto;

END
GO
