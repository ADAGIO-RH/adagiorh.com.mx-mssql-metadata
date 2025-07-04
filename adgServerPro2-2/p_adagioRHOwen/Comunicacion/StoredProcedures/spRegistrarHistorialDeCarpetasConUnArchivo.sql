USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Registra la ruta de las carpetas que contienen un solo archivo y crea un historial indicando si fue eliminada o no.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-03-26
** Parametros		: @dtCarpetasConUnArchivo	TYPE que contiene la info de las carpetas y archivos
**					: @IDUsuario				Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Comunicacion].[spRegistrarHistorialDeCarpetasConUnArchivo](
	@dtCarpetasConUnArchivo	[App].[dtCarpetasConUnArchivo] READONLY
	, @IDUsuario						INT
)
AS
	BEGIN
		
		DECLARE @SI INT = 1;		

		INSERT INTO [App].[tblHistorialDeCarpetasConUnArchivo]
		SELECT C.TipoReferencia
				, C.IDReferencia
				, C.[Path]
				, C.[File]
				, C.IsDeleted
		FROM @dtCarpetasConUnArchivo C
		WHERE C.IsDeleted = @SI
				AND NOT EXISTS (
								SELECT 1
								FROM [App].[tblHistorialDeCarpetasConUnArchivo] HIS 
								WHERE HIS.TipoReferencia = C.TipoReferencia
										AND HIS.IDReferencia = C.IDReferencia										
							   )

	END
GO
