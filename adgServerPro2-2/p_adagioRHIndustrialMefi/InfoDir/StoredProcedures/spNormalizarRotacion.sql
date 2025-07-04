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

CREATE   PROC [InfoDir].[spNormalizarRotacion]
(
	@FechaInicio DATE,
	@FechaFin DATE
)
AS
	BEGIN
		
		SELECT CN.FechaNormalizacion,
			   CN.EmpleadosVigentes,
			   CN.NoBajas,
			   CAST((CAST(CN.NoBajas AS FLOAT) / CN.EmpleadosVigentes) * 100 AS DECIMAL(18, 2)) AS RotacionB
		FROM [InfoDir].[tblColaboradoresNormalizados] CN
		WHERE CN.NoBajas > 0 AND
			  CN.FechaNormalizacion BETWEEN @FechaInicio AND @FechaFin


		SELECT CN.FechaNormalizacion,
			   CN.EmpleadosVigentes,
			   CN.NoAltas,
			   CAST((CAST(CN.NoAltas AS FLOAT) / CN.EmpleadosVigentes) * 100 AS DECIMAL(18, 2)) AS RotacionA
		FROM [InfoDir].[tblColaboradoresNormalizados] CN
		WHERE CN.NoAltas > 0 AND
			  CN.FechaNormalizacion BETWEEN @FechaInicio AND @FechaFin



		SELECT AN.FechaNormalizacion,
			   AN.Total AS NoFaltas,
			   CAST((CAST(AN.Total AS FLOAT) / 150) * 100 AS DECIMAL(18, 2)) AS Faltas
		FROM [InfoDir].[tblAsistenciasNormalizadas] AN
		WHERE AN.Tipo = 'Falta' AND 
			  AN.Total > 0


	END
GO
