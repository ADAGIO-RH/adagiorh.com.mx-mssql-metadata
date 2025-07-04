USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los templates personalizados de email.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-12
** Paremetros		: @IDTipoNotificacion		Identificador del tipo de notificación.
**					: @IDMedioNotificacion		Identificador del medio de notificacion (Celular, Email, etc).
**					: @IDIdioma					Identificador del idioma.
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #67

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-11-13			Alejandro Paredes	Se agrego el flujo de la columna personalizada
***************************************************************************************************/

CREATE   PROC [App].[spBuscarTemplateCustomersEmail](
	@IDTipoNotificacion   VARCHAR(50) = ''
	, @IDMedioNotificacion	VARCHAR(50) = ''
	, @IDIdioma				VARCHAR(10) = ''
	, @IDUsuario			INT
)
AS
BEGIN

	-- VARIABLES
	DECLARE @IDTemplateNotificacion INT = 0;


	-- IDENTIFICAMOS EL IDTemplateNotificacion
	SELECT @IDTemplateNotificacion = IDTemplateNotificacion
	FROM [App].[tblTemplateNotificaciones]
	WHERE IDTipoNotificacion = @IDTipoNotificacion
		AND IDMedioNotificacion = @IDMedioNotificacion
		AND IDIdioma = @IDIdioma;

	
	-- RESULTADO DE BUSQUEDA
	SELECT CU.IDCustomer
			, CU.BodyCustomer
			, CU.PixelesWidth
			, CU.IsAnclado
			, CU.Personalizado
			, CU.IDTemplateNotificacion			
	FROM [App].[tblTemplateCustomersEmail] CU		
	WHERE CU.IDTemplateNotificacion = @IDTemplateNotificacion
	ORDER BY CU.IDCustomer DESC

END
GO
