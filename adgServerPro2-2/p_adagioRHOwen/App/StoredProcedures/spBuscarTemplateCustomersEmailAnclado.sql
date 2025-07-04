USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca el template anclado de cada tipo de notificación.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-27
** Paremetros		: @IDTipoNotificacion		Identificador del tipo de notificación.
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

CREATE   PROC [App].[spBuscarTemplateCustomersEmailAnclado](
	@IDTipoNotificacion		VARCHAR(50) = ''	
	, @IDUsuario			INT
)
AS
BEGIN

	-- VARIABLES
	DECLARE @IDTemplateNotificacion		INT = 0			
			, @IDIdioma					VARCHAR(20)
			, @Subject					VARCHAR(MAX)
			, @SI						BIT = 1
			, @NO						BIT = 0
			, @CONTAINER_DEFAULT		INT = 1
			, @NO_EXISTE				BIT = 0
			, @PIXELES_DEFAULT			INT = 600
			-- TEMPLATE BASE
			, @Container				VARCHAR(MAX) = ''
			, @Head						VARCHAR(MAX) = ''
			, @Body						VARCHAR(MAX) = ''
			, @Footer					VARCHAR(MAX) = ''
			, @HeadCustomer				VARCHAR(MAX) = ''
			, @BodyCustomerContainer	VARCHAR(MAX) = ''
			, @FooterCustomer			VARCHAR(MAX) = ''
			, @CloseDiv					VARCHAR(MAX) = ''
			-- TEMPLATE PERSONALIZADO
			, @IDCustomer				INT	= 0
			, @BodyCustomer				VARCHAR(MAX) = ''
			, @PixelesWidth				INT = 0	
			, @FooterCustomerGral		NVARCHAR(MAX)
			-- TEMPLATE DEFAULT
			, @BodyDefault				VARCHAR(MAX) = ''
			;


	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'es-MX');
	--SELECT @IDIdioma	

	
	-- OBTENEMOS EL FOOTER DEL CLIENTE
	SELECT @FooterCustomerGral = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'FooterEmails';

	
	-- OBTENEMOS EL ASUNTO
	 SELECT @Subject = Asunto FROM [App].[tblTiposNotificaciones] WHERE IDTipoNotificacion = @IDTipoNotificacion;
	

	-- IDENTIFICAMOS EL IDTemplateNotificacion SEGUN EL IDIOMA CONFIGURADO
	SELECT @IDTemplateNotificacion = IDTemplateNotificacion
	FROM [App].[tblTemplateNotificaciones]
	WHERE IDTipoNotificacion = @IDTipoNotificacion
			AND IDIdioma = @IDIdioma

	
	-- OBTENEMOS LA ESTRUCTURA DEL TEMPLATE BASE
	SELECT @Container = Container
			, @Head = Head
			, @Body = Body
			, @Footer = Footer
			, @HeadCustomer = HeadCustomer
			, @BodyCustomerContainer = BodyCustomerContainer
			, @FooterCustomer = REPLACE(CAST(FooterCustomer AS VARCHAR(MAX)), '{footerCustomer}', @FooterCustomerGral) + CAST(CloseDiv AS VARCHAR(10)) 
			, @CloseDiv = CloseDiv
	FROM [App].[tblTemplateContainersEmail]
	WHERE IDContainer = @CONTAINER_DEFAULT


	-- IDENTIFICAMOS LA PERSONALIZACION ANCLADA DEL BODY
	SELECT @IDCustomer = IDCustomer
			, @BodyCustomer = BodyCustomer
			, @PixelesWidth = PixelesWidth
	FROM [App].[tblTemplateCustomersEmail]
	WHERE IDTemplateNotificacion = @IDTemplateNotificacion
			AND IsAnclado = @SI
			AND Personalizado = @SI


	-- OBTENEMOS PERSONALIZACION DEFAULT SI NO HAY PERSONALIZACION DEL BODY O NO ESTE ANCLADA
	IF(@IDCustomer = @NO_EXISTE)
		BEGIN
			SELECT @IDCustomer = IDCustomer
					, @BodyCustomer = BodyCustomer
					, @PixelesWidth = PixelesWidth
			FROM [App].[tblTemplateCustomersEmail]
			WHERE IDTemplateNotificacion = @IDTemplateNotificacion
					AND IsAnclado = @NO
					AND Personalizado = @NO
			
			-- OBTENEMOS @MjsDefault SI NO HAY PERSONALIZACION ANCLADA O PERSONALIZACION DEFAULT
			IF(@IDCustomer = @NO_EXISTE)
				BEGIN
					DECLARE @MjsDefault VARCHAR(255);
					SELECT @MjsDefault = Nombre FROM [App].[tblTiposNotificaciones] WHERE IDTipoNotificacion = @IDTipoNotificacion;
					SET @BodyDefault = '<br><center><h3>' + @MjsDefault + '</h3></center><br>'
				END			 
		END


	-- ENSAMBLAMOS EL HTML
	    SELECT
			@Subject AS [Subject]
			-- BODY
			, REPLACE(@Container, '{pixelesWidth}',
				CASE WHEN @IDCustomer = @NO_EXISTE
						THEN @PIXELES_DEFAULT
						ELSE CAST(@PixelesWidth AS VARCHAR)
				END)
				+ @Head
				+ @HeadCustomer
				+ @Body
				+ REPLACE(@BodyCustomerContainer, '{bodyCustomer}',
						  CASE WHEN @IDCustomer = @NO_EXISTE
							   THEN @BodyDefault
							   ELSE @BodyCustomer
						  END) + @CloseDiv				 
				+ @CloseDiv AS Body
			-- FOOTER
			, REPLACE(@Container, '{pixelesWidth}',
				CASE WHEN @IDCustomer = @NO_EXISTE
						THEN @PIXELES_DEFAULT
						ELSE CAST(@PixelesWidth AS VARCHAR)
				END)
				+ @FooterCustomer
				+ @Footer
				+ @CloseDiv
			AS Footer

END
GO
