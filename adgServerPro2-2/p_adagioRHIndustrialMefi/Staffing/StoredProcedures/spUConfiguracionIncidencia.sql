USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar configuracion de incidencias
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-10-12
** Paremetros		: @ConfiguracionJson	- cadena json con la configuracion.
					  @IDUsuario			- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spUConfiguracionIncidencia](
	@ConfiguracionJson NVARCHAR(MAX) = ''
	,@IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE @TblConfIncidencias TABLE(
			[IDConf] INT,			
			[AliasColumna] VARCHAR(50),
			[Orden] INT,
			[Activo] BIT
		)

		INSERT @TblConfIncidencias(IDConf, AliasColumna, Orden, Activo)
		SELECT I.IDConf
				, AliasColumna 
				, Orden
				, Activo
		FROM OPENJSON(JSON_QUERY(@ConfiguracionJson,  '$'))
		  WITH (
			IDConf INT '$.IDConf',
			AliasColumna VARCHAR(50) '$.AliasColumna',
			Orden INT '$.Orden',
			Activo BIT '$.Activo'
		  ) AS I

		UPDATE [Staffing].[tblConfIncidencias]
		SET 
			AliasColumna = C.AliasColumna,
			Orden = C.Orden,
			Activo = C.Activo
		FROM @TblConfIncidencias C
		WHERE [Staffing].[tblConfIncidencias].IDConf = C.IDConf

	END
GO
