USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Normalizar la información de colaboradores
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-03-29
** Paremetros		: @FechaNormalizacion
** IDAzure			: 811

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spNormalizarColaboradores]
(
	@FechaNormalizacion DATE
)
AS
	BEGIN

		-- VARIABLES DE TIPO TABLA
		DECLARE @TempVigenciaEmpleados AS TABLE (
			IDEmpleado INT NOT NULL,
			Fecha DATE NOT NULL,
			Vigente INT NOT NULL
		)


		-- OBTIENE EL HISTORIAL (IDEmpleado, Fecha, Vigente) DE LOS EMPLEADOS EN LA FECHA CONFIGURADA
		INSERT INTO @TempVigenciaEmpleados
		EXEC [InfoDir].[spEmpleadosVigentesXDia] @FechaNormalizacion


		-- ELIMINAR NORMALIZACION 
		DELETE [InfoDir].[tblColaboradoresNormalizados] WHERE FechaNormalizacion = @FechaNormalizacion
		

		-- OBTIENE EL DETALLE E HISTORIAL DEL COLABORADOR
		;WITH TblColaboradoresDetalle(FechaNormalizacion, IDEmpleado, EmpleadoVigente, FechaAlta, FechaBaja, IDCliente, IDRazonSocial, IDRegPatronal, IDCentroCosto, IDDepartamento, IDArea, IDPuesto, IDTipoPrestacion, IDSucursal, IDDivision, IDRegion, IDClasificacionCorporativa)
		AS(
			SELECT TV.Fecha AS FechaNormalizacion,
				   TV.IDEmpleado,
				   TV.Vigente AS EmpleadoVigente,
				   (SELECT TOP 1 CASE WHEN M.Fecha IS NULL THEN 0 ELSE 1 END
					FROM [IMSS].[tblMovAfiliatorios] M WITH(NOLOCK)
						JOIN [IMSS].[tblCatTipoMovimientos] C WITH(NOLOCK) ON M.IDTipoMovimiento = C.IDTipoMovimiento
					WHERE M.IDEmpleado = TV.IDEmpleado AND M.Fecha = TV.Fecha AND C.Codigo = 'A'
					ORDER BY M.Fecha DESC, C.Prioridad DESC) AS FechaAlta,
					(SELECT TOP 1 CASE WHEN M.Fecha IS NULL THEN 0 ELSE 1 END
					FROM [IMSS].[tblMovAfiliatorios] M WITH(NOLOCK)
						JOIN [IMSS].[tblCatTipoMovimientos] C WITH(NOLOCK) ON M.IDTipoMovimiento = C.IDTipoMovimiento
					WHERE M.IDEmpleado = TV.IDEmpleado AND M.Fecha = TV.Fecha AND C.Codigo = 'B'
					ORDER BY M.Fecha DESC, C.Prioridad DESC) AS FechaBaja,
					(SELECT CE.IDCliente FROM [RH].[tblClienteEmpleado] CE WITH(NOLOCK) WHERE TV.IDEmpleado = CE.IDEmpleado AND CE.FechaIni <= TV.Fecha AND CE.FechaFin >= TV.Fecha),
					(SELECT RS.IDRazonSocial FROM [RH].[tblRazonSocialEmpleado] RS WITH(NOLOCK) WHERE TV.IDEmpleado = RS.IDEmpleado AND RS.FechaIni <= TV.Fecha AND RS.FechaFin >= TV.Fecha),
					(SELECT RPE.IDRegPatronal FROM [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK) WHERE TV.IDEmpleado = RPE.IDEmpleado AND RPE.FechaIni <= TV.Fecha AND RPE.FechaFin >= TV.Fecha),
					(SELECT CCE.IDCentroCosto FROM [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK) WHERE TV.IDEmpleado = CCE.IDEmpleado AND CCE.FechaIni <= TV.Fecha AND CCE.FechaFin >= TV.Fecha),
					(SELECT DE.IDDepartamento FROM [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK) WHERE TV.IDEmpleado = DE.IDEmpleado AND DE.FechaIni <= TV.Fecha AND DE.FechaFin >= TV.Fecha),
					(SELECT AE.IDArea FROM [RH].[tblAreaEmpleado] AE WITH(NOLOCK) WHERE TV.IDEmpleado = AE.IDEmpleado AND AE.FechaIni <= TV.Fecha AND AE.FechaFin >= TV.Fecha),
					(SELECT PE.IDPuesto FROM [RH].[tblPuestoEmpleado] PE WITH(NOLOCK) WHERE TV.IDEmpleado = PE.IDEmpleado AND PE.FechaIni <= TV.Fecha AND PE.FechaFin >= TV.Fecha),
					(SELECT PRE.IDTipoPrestacion FROM [RH].[TblPrestacionesEmpleado] PRE WITH(NOLOCK) WHERE TV.IDEmpleado = PRE.IDEmpleado AND PRE.FechaIni <= TV.Fecha AND PRE.FechaFin >= TV.Fecha),
					(SELECT SE.IDSucursal FROM [RH].[tblSucursalEmpleado] SE WITH(NOLOCK) WHERE TV.IDEmpleado = SE.IDEmpleado AND SE.FechaIni <= TV.Fecha AND SE.FechaFin >= TV.Fecha),
					(SELECT DVE.IDDivision FROM [RH].[tblDivisionEmpleado] DVE WITH(NOLOCK) WHERE TV.IDEmpleado = DVE.IDEmpleado AND DVE.FechaIni <= TV.Fecha AND DVE.FechaFin >= TV.Fecha),
					(SELECT RE.IDRegion FROM [RH].[tblRegionEmpleado] RE WITH(NOLOCK) WHERE TV.IDEmpleado = RE.IDEmpleado AND RE.FechaIni <= TV.Fecha AND RE.FechaFin >= TV.Fecha),
					(SELECT CPE.IDClasificacionCorporativa FROM [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) WHERE TV.IDEmpleado = CPE.IDEmpleado AND CPE.FechaIni <= TV.Fecha AND CPE.FechaFin >= TV.Fecha)
			FROM @TempVigenciaEmpleados TV
			--WHERE TV.IDEmpleado = 197
			--ORDER BY TV.IDEmpleado
		)
		INSERT INTO [InfoDir].[tblColaboradoresNormalizados]
		SELECT FechaNormalizacion,	
			   COUNT(IDEmpleado) NoEmpleados,
			   SUM(CASE WHEN EmpleadoVigente = 1 THEN 1 ELSE 0 END) AS EmpleadosVigentes,
			   SUM(CASE WHEN FechaAlta IS NULL THEN 0 ELSE 1 END) AS NoAltas,
			   SUM(CASE WHEN FechaBaja IS NULL THEN 0 ELSE 1 END) AS NoBajas,
			   ISNULL(IDCliente, 0) AS IDCliente,
			   ISNULL(IDRazonSocial, 0) AS IDRazonSocial,
			   ISNULL(IDRegPatronal, 0) AS IDRegPatronal,
			   ISNULL(IDCentroCosto, 0) AS IDCentroCosto,
			   ISNULL(IDDepartamento, 0) AS IDDepartamento,
			   ISNULL(IDArea, 0) AS IDArea,
			   ISNULL(IDPuesto, 0) AS IDPuesto,
			   ISNULL(IDTipoPrestacion, 0) AS IDTipoPrestacion,
			   ISNULL(IDSucursal, 0) AS IDSucursal,
			   ISNULL(IDDivision, 0) AS IDDivision,
			   ISNULL(IDRegion, 0) AS IDRegion,
			   ISNULL(IDClasificacionCorporativa, 0) AS IDClasificacionCorporativa
		FROM TblColaboradoresDetalle		
		GROUP BY FechaNormalizacion,
				 IDCliente,
			     IDRazonSocial,
			     IDRegPatronal,
			     IDCentroCosto,
			     IDDepartamento,
			     IDArea, 
			     IDPuesto,
			     IDTipoPrestacion,
			     IDSucursal,
			     IDDivision,
			     IDRegion,
			     IDClasificacionCorporativa

	END
GO
