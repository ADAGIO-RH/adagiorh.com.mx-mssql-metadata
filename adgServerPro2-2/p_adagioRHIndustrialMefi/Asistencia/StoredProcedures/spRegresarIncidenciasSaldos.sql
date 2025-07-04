USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Asistencia].[spRegresarIncidenciasSaldos]
AS
	BEGIN  

		--Proposito:			Obtiene las incidencias administradas por saldos
		--Fecha Creación:		10-03-2022
		--Autor:				aparedes
		--Fecha Modificación:   
		--Autor Modificación:	
		--Version:				1.0
		--Parametros:			
		--Requerimiento:		745
		
		DECLARE @AdministrarSaldos INT = 1;
	
		SELECT 
			I.IDIncidencia,
			JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')) as Descripcion
		FROM [Asistencia].[tblCatIncidencias] I
		WHERE I.AdministrarSaldos = @AdministrarSaldos
			
	END
GO
