USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las sucursales mapeadas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-05-31
** Paremetros		: @Tipo			- Tipo de mapeo (Sucursal, Departamento, Puesto).
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarTiposMapeo](
	@Tipo			VARCHAR(25)
	, @IDUsuario	INT = 0
)
AS
BEGIN
	
	-- DECLARACION DE VARIABLES
	DECLARE @Propiedades NVARCHAR(50);
	DECLARE @Qry2 NVARCHAR(MAX);

	-- TABLAS TEMPORALES
	CREATE TABLE #tblMapeoPuestos (
		IDMapeo					INT
		, IDSucursal			INT
		, CodigoSucursal		VARCHAR(20)
		, Sucursal				VARCHAR(255)
		, IDDepartamento		INT
		, CodigoDepartamento	VARCHAR(20)
		, Departamento			VARCHAR(255)
		, IDPuesto				INT
		, CodigoPuesto			VARCHAR(20)
		, Puesto				VARCHAR(255)
		, ROWNUMBER				INT
		, TotalPage				INT
		, TotalRows				INT
	);

	-- INFORMACION DE LOS DATOS MAPEADOS
	INSERT INTO #tblMapeoPuestos
	EXEC [Staffing].[spBuscarMapeoPuestos]


	-- CONSTRUCCION DE CONSULTA DINAMICA
	IF @Tipo = 'Sucursal'
		BEGIN
			SET @Propiedades = 'IDSucursal, CodigoSucursal, Sucursal';		
		END
	
	IF @Tipo = 'Departamento'
		BEGIN
			SET @Propiedades = 'IDDepartamento, CodigoDepartamento, Departamento';
		END

	IF @Tipo = 'Puesto'
		BEGIN
			SET @Propiedades = 'IDPuesto, CodigoPuesto, Puesto';
		END

	--
	SET @Qry2 = 'SELECT ' + @Propiedades + '
				 FROM #tblMapeoPuestos
				 GROUP BY ' + @Propiedades + '';
	
	
	-- RESULTADO
	EXEC sp_executesql @Qry2;

END
GO
