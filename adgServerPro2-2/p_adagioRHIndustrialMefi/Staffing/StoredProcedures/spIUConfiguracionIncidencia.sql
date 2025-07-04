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
CREATE   PROCEDURE [Staffing].[spIUConfiguracionIncidencia](
	@ConfiguracionJson NVARCHAR(MAX) = ''
	,@IDUsuario	BIT = 0
)
AS
	BEGIN
	

		DECLARE @OldJSON VARCHAR(MAX)
				,@NewJSON VARCHAR(MAX)			
				;		
		
		DECLARE @TblConfIncidencias TABLE(
			[IDConf] INT,
			[IDIncidencia] VARCHAR(50),
			[AliasColumna] VARCHAR(50),
			[Orden] INT,
			[Activo] BIT
		)

		INSERT @TblConfIncidencias(IDConf, IDIncidencia, AliasColumna, Orden, Activo)
		SELECT ISNULL(I2.IDConf, 0) AS IDConf
			   , I1.*
		FROM OPENJSON(JSON_QUERY(@ConfiguracionJson,  '$'))
		  WITH (
			IDIncidencia NVARCHAR(50) '$.IDIncidencia',
			AliasColumna NVARCHAR(50) '$.AliasColumna',
			Orden INT '$.Orden',
			Activo BIT '$.Activo'
		  ) AS I1
		LEFT JOIN [Staffing].[tblConfIncidencias] I2 ON I1.IDIncidencia = I2.IDIncidencia


		
		INSERT INTO [Staffing].[tblConfIncidencias] (IDIncidencia, AliasColumna, Orden, Activo)
		SELECT IDIncidencia, AliasColumna, Orden, Activo
		FROM @TblConfIncidencias
		WHERE IDConf = 0;



		--UPDATE [Staffing].[tblConfIncidencias] 
		--SET			
		--	C.AliasColumna = I.AliasColumna,
		--	C.Orden = I.Orden,
		--	C.Activo = I.Activo
		--FROM [Staffing].[tblConfIncidencias] AS C
		--	INNER JOIN @TblConfIncidencias AS I ON C.IDConf = I.IDConf		


	


	END
GO
