USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Normalizar la información de incapacidades
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-04
** Paremetros		: @FechaNormalizacion
** IDAzure			: 811

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spNormalizarIncapacidades]
(
	@FechaNormalizacion DATE
)
AS
	BEGIN		
		
		-- VARIABLES
		DECLARE @EmpleadoVigente INT = 1;
		DECLARE @NoAutorizado INT = 0;
		DECLARE @Autorizado INT = 1;
		DECLARE @Incapacidad VARCHAR(1) = 'I';
		
		-- VARIABLES DE TIPO TABLA
		DECLARE @TempVigenciaEmpleados AS TABLE (
			IDEmpleado INT NOT NULL,
			Fecha DATE NOT NULL,
			Vigente INT NOT NULL
		)

		DECLARE @TempDetalle AS TABLE (
			FechaNormalizacion DATE,
			IDEmpleado INT,
			IDTipoIncapacidad INT,
			FechaIncapacidad DATE,
			Total INT,
			Autorizado INT,			
			IDCliente INT,
			IDRazonSocial INT,
			IDRegPatronal INT,
			IDCentroCosto INT,
			IDDepartamento INT,
			IDArea INT,
			IDPuesto INT,
			IDTipoPrestacion INT,
			IDSucursal INT,
			IDDivision INT,
			IDRegion INT,
			IDClasificacionCorporativa INT
		);


		-- OBTIENE EL HISTORIAL (IDEmpleado, Fecha, Vigente) DE LOS EMPLEADOS EN LA FECHA CONFIGURADA
		INSERT INTO @TempVigenciaEmpleados
		EXEC [InfoDir].[spEmpleadosVigentesXDia] @FechaNormalizacion

		
		-- ELIMINAR NORMALIZACION 
		DELETE [InfoDir].[tblIncapacidadesNormalizadas] WHERE FechaNormalizacion = @FechaNormalizacion

		
		;WITH TblDetalleAux(Fecha, IDEmpleado, IDTipoIncapacidad, FechaIncapacidad, Total, Autorizado)
		AS(
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,		    
				   (SELECT IE.IDTipoIncapacidad
					FROM [Asistencia].[tblIncapacidadEmpleado] IE
						INNER JOIN [Asistencia].[tblIncidenciaEmpleado] INE ON INE.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
					WHERE INE.IDIncidencia = @Incapacidad AND
						  INE.IDEmpleado = TV.IDEmpleado AND
						  INE.Fecha = @FechaNormalizacion
					GROUP BY IE.IDTipoIncapacidad) AS IDTipoIncapacidad,
				   (SELECT INE.Fecha
					FROM [Asistencia].[tblIncapacidadEmpleado] IE
						INNER JOIN [Asistencia].[tblIncidenciaEmpleado] INE ON INE.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
					WHERE INE.IDIncidencia = @Incapacidad AND
						  INE.IDEmpleado = TV.IDEmpleado AND
						  INE.Fecha = @FechaNormalizacion
					GROUP BY INE.Fecha) AS FechaIncapacidad,
					(SELECT COUNT(IE.IDTipoIncapacidad)
					FROM [Asistencia].[tblIncapacidadEmpleado] IE
						INNER JOIN [Asistencia].[tblIncidenciaEmpleado] INE ON INE.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
					WHERE INE.IDIncidencia = @Incapacidad AND
						  INE.IDEmpleado = TV.IDEmpleado AND
						  INE.Fecha = @FechaNormalizacion
					GROUP BY IE.IDTipoIncapacidad) AS Total,
					(SELECT INE.Autorizado
					 FROM [Asistencia].[tblIncapacidadEmpleado] IE
						INNER JOIN [Asistencia].[tblIncidenciaEmpleado] INE ON INE.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
					 WHERE INE.IDIncidencia = @Incapacidad AND
						   INE.IDEmpleado = TV.IDEmpleado AND
						   INE.Fecha = @FechaNormalizacion		   
					 GROUP BY INE.Autorizado) AS Autorizado
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente --AND
				  --TV.IDEmpleado = 1279
		)
		INSERT INTO @TempDetalle
		SELECT *,
			   ISNULL((SELECT CE.IDCliente FROM [RH].[tblClienteEmpleado] CE WITH(NOLOCK) WHERE D.IDEmpleado = CE.IDEmpleado AND CE.FechaIni <= D.Fecha AND CE.FechaFin >= D.Fecha), 0) AS IDCliente,
			   ISNULL((SELECT RS.IDRazonSocial FROM [RH].[tblRazonSocialEmpleado] RS WITH(NOLOCK) WHERE D.IDEmpleado = RS.IDEmpleado AND RS.FechaIni <= D.Fecha AND RS.FechaFin >= D.Fecha), 0) AS IDRazonSocial,
			   ISNULL((SELECT RPE.IDRegPatronal FROM [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK) WHERE D.IDEmpleado = RPE.IDEmpleado AND RPE.FechaIni <= D.Fecha AND RPE.FechaFin >= D.Fecha), 0) AS IDRegPatronal,
			   ISNULL((SELECT CCE.IDCentroCosto FROM [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK) WHERE D.IDEmpleado = CCE.IDEmpleado AND CCE.FechaIni <= D.Fecha AND CCE.FechaFin >= D.Fecha), 0) AS IDCentroCosto,
			   ISNULL((SELECT DE.IDDepartamento FROM [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK) WHERE D.IDEmpleado = DE.IDEmpleado AND DE.FechaIni <= D.Fecha AND DE.FechaFin >= D.Fecha), 0) AS IDDepartamento,
			   ISNULL((SELECT AE.IDArea FROM [RH].[tblAreaEmpleado] AE WITH(NOLOCK) WHERE D.IDEmpleado = AE.IDEmpleado AND AE.FechaIni <= D.Fecha AND AE.FechaFin >= D.Fecha), 0) AS IDArea,
			   ISNULL((SELECT PE.IDPuesto FROM [RH].[tblPuestoEmpleado] PE WITH(NOLOCK) WHERE D.IDEmpleado = PE.IDEmpleado AND PE.FechaIni <= D.Fecha AND PE.FechaFin >= D.Fecha), 0) AS IDPuesto,
			   ISNULL((SELECT PRE.IDTipoPrestacion FROM [RH].[TblPrestacionesEmpleado] PRE WITH(NOLOCK) WHERE D.IDEmpleado = PRE.IDEmpleado AND PRE.FechaIni <= D.Fecha AND PRE.FechaFin >= D.Fecha), 0) AS IDTipoPrestacion,
			   ISNULL((SELECT SE.IDSucursal FROM [RH].[tblSucursalEmpleado] SE WITH(NOLOCK) WHERE D.IDEmpleado = SE.IDEmpleado AND SE.FechaIni <= D.Fecha AND SE.FechaFin >= D.Fecha), 0) AS IDSucursal,
			   ISNULL((SELECT DVE.IDDivision FROM [RH].[tblDivisionEmpleado] DVE WITH(NOLOCK) WHERE D.IDEmpleado = DVE.IDEmpleado AND DVE.FechaIni <= D.Fecha AND DVE.FechaFin >= D.Fecha), 0) AS IDDivision,
			   ISNULL((SELECT RE.IDRegion FROM [RH].[tblRegionEmpleado] RE WITH(NOLOCK) WHERE D.IDEmpleado = RE.IDEmpleado AND RE.FechaIni <= D.Fecha AND RE.FechaFin >= D.Fecha), 0) AS IDRegion,
			   ISNULL((SELECT CPE.IDClasificacionCorporativa FROM [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) WHERE D.IDEmpleado = CPE.IDEmpleado AND CPE.FechaIni <= D.Fecha AND CPE.FechaFin >= D.Fecha), 0) AS IDClasificacionCorporativa
		FROM TblDetalleAux D

		

		-- INSERTAR NORMALIZACION NUEVA
		INSERT INTO [InfoDir].[tblIncapacidadesNormalizadas] 
		SELECT FechaNormalizacion,
			   ISNULL(IDTipoIncapacidad , 0) AS IDTipoIncapacidad, 
			   ISNULL(FechaIncapacidad, '') AS FechaIncapacidad,			   
			   ISNULL(SUM(Total), 0) AS Total,
			   ISNULL(Autorizado, 0) AS Autorizado,
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
		FROM @TempDetalle		
		GROUP BY FechaNormalizacion,
				 IDTipoIncapacidad,
				 FechaIncapacidad,
				 Autorizado,
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
		--HAVING SUM(NoAusentismosAut) > 0
		--HAVING SUM(NoAusentismosSinAut) > 0
		--HAVING SUM(NoRetardosAut) > 0
		--HAVING SUM(NoRetardosSinAut) > 0

	END
GO
