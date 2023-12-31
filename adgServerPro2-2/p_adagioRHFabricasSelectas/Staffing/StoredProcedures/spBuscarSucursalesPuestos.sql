USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca sucursales y puestos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-09-07
** Paremetros		: @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarSucursalesPuestos](
	@IDUsuario	INT = 0
)
AS
BEGIN
		
		SET LANGUAGE 'spanish'		
		
		DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
				, @IDIdioma VARCHAR(20)
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		-- NORMALIZAMOS LA INFORMACION OBTENIENDO LA SUCURSAL, PUESTO Y LA CONFIGURACION DEL STAFF		
		SELECT S.IDSucursal
				, S.Codigo + '-' + S.Descripcion AS Sucursal
				, P.IDPuesto
				, P.Codigo + '-' + ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto		
		FROM [RH].[tblCatSucursales] S
		CROSS APPLY (
			SELECT IDPuesto, Codigo, Traduccion
			FROM [RH].[tblCatPuestos]
		) AS P

END
GO
