USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Normalizar la información de colaboradores con ausentismos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-03-30
** Paremetros		: @FechaNormalizacion
** IDAzure			: 811

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spNomalizacionAusentismo]
(
	@FechaNormalizacion DATE
)
AS
	BEGIN		

		DECLARE @IncAutorizada INT = 1;
		
		DECLARE @TempAusentismo AS TABLE (
			FechaNormalizacion DATE,
			IDIncidencia VARCHAR(10),
			EsAusentismo INT,
			GoceSueldo INT,
			EmpleadosActivos INT,
			Total INT,
			Ausentismo DECIMAL(18, 2)
		)
		
		
		;WITH TblAusentismos(FechaNormalizacion, IDIncidencia, EsAusentismo, GoceSueldo, EmpleadosActivos, Total)
		AS(
			SELECT @FechaNormalizacion AS FechaNormalizacion,
				   I.IDIncidencia,
				   I.EsAusentismo,
				   I.GoceSueldo,
				   C.EmpleadosActivos,
				   COUNT(I.IDIncidencia) AS Total
			FROM [Asistencia].[tblIncidenciaEmpleado] IE
				INNER JOIN [Asistencia].[tblCatIncidencias] I  ON IE.IDIncidencia = I.IDIncidencia
				INNER JOIN [InfoDir].[tblColaboradoresRotacion] C ON C.FechaNormalizacion = @FechaNormalizacion
			WHERE IE.Fecha = @FechaNormalizacion AND
				  IE.Autorizado = @IncAutorizada
			GROUP BY I.IDIncidencia,
					 I.EsAusentismo,
					 I.GoceSueldo,
					 C.EmpleadosActivos		
		  )
		INSERT INTO @TempAusentismo(FechaNormalizacion, IDIncidencia, EsAusentismo, GoceSueldo, EmpleadosActivos, Total, Ausentismo)
		SELECT FechaNormalizacion,
			   IDIncidencia,
			   EsAusentismo,
			   GoceSueldo,
			   EmpleadosActivos,
			   Total,
			   CAST((CAST(Total AS FLOAT) / EmpleadosActivos) * 100 AS DECIMAL(18, 2)) AS Ausentismo			   
		FROM TblAusentismos


		-- SE UTILIZA PARA PROBAR	
		-- SELECT * FROM @TempAusentismo		

									   
		-- INSERTAR ROTACION NUEVA
		INSERT INTO [InfoDir].[tblAusentismos](FechaNormalizacion, IDIncidencia, EsAusentismo, GoceSueldo, Total, Ausentismo)
		SELECT TA.FechaNormalizacion,
			   TA.IDIncidencia,
			   TA.EsAusentismo,
			   TA.GoceSueldo,
			   TA.Total,
			   TA.Ausentismo
		FROM @TempAusentismo TA
		WHERE NOT EXISTS (SELECT A.FechaNormalizacion FROM [InfoDir].[tblAusentismos] A WHERE A.FechaNormalizacion = TA.FechaNormalizacion AND A.IDIncidencia = TA.IDIncidencia)
		
		
		-- ACTUALIZAR ROTACION
		UPDATE [InfoDir].[tblAusentismos] SET EsAusentismo = TA.EsAusentismo,
											  GoceSueldo = TA.GoceSueldo,
											  Total = TA.Total,
											  Ausentismo = TA.Ausentismo
		--SELECT TA.*
		FROM @TempAusentismo TA
			INNER JOIN [InfoDir].[tblAusentismos] A ON A.FechaNormalizacion = TA.FechaNormalizacion AND A.IDIncidencia = TA.IDIncidencia
		WHERE TA.EsAusentismo != A.EsAusentismo OR
			  TA.GoceSueldo != A.GoceSueldo OR 
			  TA.Total != A.Total OR
			  TA.Ausentismo != A.Ausentismo
		

	END
GO
