USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Busca e inserta configuraciones de incidencias nuevas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-10-13
** Paremetros		: @IDUsuario			- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spSincronizarIncidencias](
	@IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE
			@AliasColumna VARCHAR(10) = ''
			, @Activo BIT = 0 

		
		INSERT INTO [Staffing].[tblConfIncidencias] (IDIncidencia, AliasColumna, Orden, Activo)	
		SELECT I.IDIncidencia
			   , @AliasColumna
			   , ROW_NUMBER() OVER (ORDER BY I.IDIncidencia) + (SELECT COUNT(*) FROM [Staffing].[tblConfIncidencias]) AS Orden
			   , @Activo
			   --, CI.IDIncidencia
		FROM
			(
				SELECT CI.IDIncidencia						
				FROM [Asistencia].[tblCatIncidencias] CI
			) AS I		
		LEFT JOIN [Staffing].[tblConfIncidencias] CI ON I.IDIncidencia = CI.IDIncidencia
		WHERE ISNULL(CI.IDIncidencia, '') = ''

	END
GO
