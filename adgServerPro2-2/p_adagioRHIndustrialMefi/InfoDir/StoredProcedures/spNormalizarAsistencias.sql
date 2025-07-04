USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Normalizar la información de asistencia
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-01
** Paremetros		: @FechaNormalizacion
** IDAzure			: 811

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spNormalizarAsistencias]
(
	@FechaNormalizacion DATE
)
AS
	BEGIN		
		
		-- VARIABLES
		DECLARE @EmpleadoVigente INT = 1;
		DECLARE @NoAutorizado INT = 0;
		DECLARE @Autorizado INT = 1;
		DECLARE @EsAsentismo INT = 0;
		DECLARE @NoEsAsentismo INT = 1;		
		DECLARE @Retardo VARCHAR(1) = 'R';
		DECLARE @Falta VARCHAR(1) = 'F';
		
		-- VARIABLES DE TIPO TABLA
		DECLARE @TempVigenciaEmpleados AS TABLE (
			IDEmpleado INT NOT NULL,
			Fecha DATE NOT NULL,
			Vigente INT NOT NULL
		)

		DECLARE @TempDetalle AS TABLE (
			FechaNormalizacion DATE,
			IDEmpleado INT,
			Tipo VARCHAR(15),
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
		DELETE [InfoDir].[tblAsistenciasNormalizadas] WHERE FechaNormalizacion = @FechaNormalizacion

		
		;WITH TblDetalleAux(Fecha, IDEmpleado, Tipo, Total, Autorizado)
		AS(
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Ausentismo' AS Tipo,				   
				   (SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.Autorizado = @Autorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,
					@Autorizado AS Autorizado			
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
			UNION ALL			
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Ausentismo' AS Tipo,				   
				   (SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.Autorizado  = @NoAutorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,					
					@NoAutorizado AS Autorizado				   
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
			UNION ALL
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Retardo' AS Tipo,
					(SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.IDIncidencia = @Retardo AND
						  IE.Autorizado  = @Autorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,
					@Autorizado AS Autorizado
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
			UNION ALL
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Retardo' AS Tipo,
					(SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.IDIncidencia = @Retardo AND
						  IE.Autorizado  = @NoAutorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,
					@NoAutorizado AS Autorizado
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
			UNION ALL
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Falta' AS Tipo,
					(SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.IDIncidencia = @Falta AND
						  IE.Autorizado  = @Autorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,
					@Autorizado AS Autorizado
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
			UNION ALL
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   TV.IDEmpleado,
				   'Falta' AS Tipo,
					(SELECT COUNT(IE.IDIncidencia)
					FROM [Asistencia].[tblIncidenciaEmpleado] IE
						INNER JOIN [Asistencia].[tblCatIncidencias] I ON IE.IDIncidencia = I.IDIncidencia
					WHERE IE.IDEmpleado = TV.IDEmpleado AND
						  IE.IDIncidencia = @Falta AND
						  IE.Autorizado  = @NoAutorizado AND
						  Fecha = @FechaNormalizacion AND
						  I.EsAusentismo = @EsAsentismo) AS Total,
					@NoAutorizado AS Autorizado
			FROM @TempVigenciaEmpleados TV
			WHERE TV.Vigente = @EmpleadoVigente
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
		INSERT INTO [InfoDir].[tblAsistenciasNormalizadas] 
		SELECT FechaNormalizacion,
			   Tipo,
			   SUM(Total) AS Total,
			   Autorizado,
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
				 Tipo,
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
