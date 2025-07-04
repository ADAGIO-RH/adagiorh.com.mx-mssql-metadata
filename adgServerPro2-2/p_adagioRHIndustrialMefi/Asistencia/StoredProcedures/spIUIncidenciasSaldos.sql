USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Asistencia].[spIUIncidenciasSaldos]
(
	@IDIncidenciaSaldo INT = 0,
	@FechaInicio DATE,
	@FechaFin DATE,
	@Cantidad INT,
	@IDEmpleado INT,
	@IDIncidencia VARCHAR(10),
	@IDUsuario INT	
)
AS
	BEGIN  

		--Proposito:			Registrar y/o actualizar las incidencias con saldos
		--Fecha Creación:		10-03-2022
		--Autor:				aparedes
		--Fecha Modificación:   
		--Autor Modificación:	
		--Version:				1.0
		--Parametros:			
		--Requerimiento:		745
		
		DECLARE @OldJSON VARCHAR(MAX), @NewJSON VARCHAR(MAX);
		DECLARE @FechaRegistro DATETIME = GETDATE();

		DECLARE @FechaInicioAux DATE = CONVERT (DATE, @FechaInicio, 103);
		DECLARE @FechaFinAux DATE = CONVERT (DATE, @FechaFin, 103);
		
		IF(@IDIncidenciaSaldo = 0 OR @IDIncidencia = NULL)
			BEGIN
				
				INSERT INTO [Asistencia].[tblIncidenciasSaldos]([FechaInicio], [FechaFin], [FechaRegistro], [Cantidad], [IDEmpleado], [IDIncidencia], [IDUsuario])
				VALUES(@FechaInicioAux, @FechaFinAux, @FechaRegistro, @Cantidad, @IDEmpleado, @IDIncidencia, @IDUsuario)


				/* BITACORA AUDITORIA */

				SET @IDIncidenciaSaldo = @@identity  

				SELECT @NewJSON = A.JSON 
				FROM [Asistencia].[tblIncidenciasSaldos] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDIncidenciaSaldo = @IDIncidenciaSaldo

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Asistencia].[tblIncidenciasSaldos]', '[Asistencia].[spIUIncidenciasSaldos]', 'INSERT', @NewJSON, ''

			END
		ELSE
			BEGIN

				SELECT @OldJSON = A.JSON 
				FROM [Asistencia].[tblIncidenciasSaldos] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDIncidenciaSaldo = @IDIncidenciaSaldo


				UPDATE [Asistencia].[tblIncidenciasSaldos] SET [FechaInicio] = @FechaInicioAux,
															   [FechaFin] = @FechaFinAux,
															   [Cantidad] = @Cantidad,
															   [IDIncidencia] = @IDIncidencia
														   WHERE [IDIncidenciaSaldo] = @IDIncidenciaSaldo

				/* BITACORA AUDITORIA */

				SELECT @NewJSON = A.JSON 
				FROM [Asistencia].[tblIncidenciasSaldos] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDIncidenciaSaldo = @IDIncidenciaSaldo

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Asistencia].[tblIncidenciasSaldos]', '[Asistencia].[spIUIncidenciasSaldos]', 'UPDATE', @NewJSON, @OldJSON

			END		
	END
GO
