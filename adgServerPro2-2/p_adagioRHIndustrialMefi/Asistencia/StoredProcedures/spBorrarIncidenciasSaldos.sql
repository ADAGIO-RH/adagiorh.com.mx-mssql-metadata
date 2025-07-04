USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Asistencia].[spBorrarIncidenciasSaldos]  
(  
  @IDIncidenciaSaldo INT,
  @IDUsuario INT
) 
AS  
	BEGIN  
		
		--Proposito:			Eliminar las incidencias con saldos
		--Fecha Creación:		14-03-2022
		--Autor:				aparedes
		--Fecha Modificación:   
		--Autor Modificación:	
		--Version:				1.0
		--Parametros:			
		--Requerimiento:		745

		DECLARE @OldJSON VARCHAR(MAX), @NewJSON VARCHAR(MAX);

		SELECT @OldJSON = A.JSON 
		FROM [Asistencia].[tblIncidenciasSaldos] S
			CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
		WHERE S.IDIncidenciaSaldo = @IDIncidenciaSaldo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Asistencia].[tblIncidenciasSaldos]', '[Asistencia].[spBorrarIncidenciasSaldos]', 'DELETE', '', @OldJSON
	  
		DELETE Asistencia.tblIncidenciasSaldos
		WHERE IDIncidenciaSaldo = @IDIncidenciaSaldo

	END;
GO
