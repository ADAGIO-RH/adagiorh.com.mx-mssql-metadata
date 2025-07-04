USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los campos que estan relacionados con la notificación.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-24
** Paremetros		: @IDTipoNotificacion	Identificador de la notificación.
**					: @IDUsuario			Identificador del usuario.
** IDAzure			: #67

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [App].[spBuscarCamposDinamicosNotificaciones](
	@IDTipoNotificacion	VARCHAR(50)	
	, @IDUsuario			INT
)
AS
	BEGIN		

		DECLARE @IDIdioma			VARCHAR(225)
				, @Tabla			VARCHAR(100) = ''
				, @NoTablasNoti		INT = 0
				, @ListaTablasNoti	VARCHAR(MAX) = ''
				;		
		
		-- Detectamos idioma
		SELECT @IDIdioma = [APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');

		-- Tabla temporal
		DECLARE @TblTablasNoti TABLE(
			ID	INT IDENTITY(1,1),
			Tabla VARCHAR(100)
		)

		-- Busca las tablas o vistas donde existe la notificacion
		INSERT INTO @TblTablasNoti
		SELECT CDN.Tabla
		FROM [App].[tblCamposDinamicosNotificaciones] CDN
		CROSS APPLY
			OPENJSON(CDN.TiposNotificaciones) WITH (
				IDTipoNotificacion NVARCHAR(255) '$.IDTipoNotificacion'
			) AS TN
		WHERE TN.IDTipoNotificacion = @IDTipoNotificacion;


		-- Cuenta cuántas tablas o vistas existen para la notificación
		SELECT @NoTablasNoti = COUNT(*), @Tabla = MAX(Tabla) FROM @TblTablasNoti;


		-- Validación si existen más de una tabla o vista relacionada
		IF(@NoTablasNoti > 1)
			BEGIN
				SELECT @ListaTablasNoti = STRING_AGG(Tabla, ', ') FROM @TblTablasNoti;				
				RAISERROR('Los tags relacionados a la notificación fueron encontrados en las siguientes tablas: %s. Por favor, indique de cuál tabla se tomarán los tags.', 16, 1, @ListaTablasNoti);
				RETURN
			END



		-- Selecciona los campos dinámicos de la tabla/vista seleccionada
		SELECT IDCampoDinamico
				, Campo
				, Tabla
				, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) AS Descripcion
				--, IDCampo
				, AliasCampo
				, GrupoCampo
		FROM [App].[tblCatCamposDinamicos]
		WHERE Tabla = @Tabla
		ORDER BY IDCampoDinamico


	END
GO
