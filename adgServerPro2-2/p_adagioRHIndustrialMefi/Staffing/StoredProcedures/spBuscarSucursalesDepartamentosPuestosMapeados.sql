USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca sucursales, departamentos y puestos mapeados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-05-31
** Paremetros		: @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE     PROCEDURE [Staffing].[spBuscarSucursalesDepartamentosPuestosMapeados](
	@IDUsuario	INT = 0
)
AS
BEGIN
		
		SET LANGUAGE 'spanish'
		
		DECLARE @IDIdioma VARCHAR(20)
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		-- NORMALIZAMOS LA INFORMACION OBTENIENDO LA SUCURSAL, PUESTO Y LA CONFIGURACION DEL STAFF		
		SELECT	MP.IDMapeo
				, S.IDSucursal
				, S.Codigo + '-' + S.Descripcion AS Sucursal
				, D.IDDepartamento
				, D.Codigo + '-' + D.Descripcion AS Departamento
				, P.IDPuesto
				, P.Codigo + '-' + ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto
		FROM [Staffing].[tblCatMapeoPuestos] MP
			JOIN [RH].[tblCatSucursales] S ON MP.IDSucursal = S.IDSucursal
			JOIN [RH].[tblCatDepartamentos] D ON MP.IDDepartamento = D.IDDepartamento
			JOIN [RH].[tblCatPuestos] P ON MP.IDPuesto = P.IDPuesto
		

END
GO
