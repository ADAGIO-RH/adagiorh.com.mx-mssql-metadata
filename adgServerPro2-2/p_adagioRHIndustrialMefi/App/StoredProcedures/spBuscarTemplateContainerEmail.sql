USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca el template container email base.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-18
** Paremetros		:  @IDUsuario				Identificador del usuario
** IDAzure			: #67

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [App].[spBuscarTemplateContainerEmail](
	@IDUsuario	INT
)
AS
BEGIN

	-- VARIABLES
	DECLARE @CONTAINER_DEFAULT INT = 1
			, @FooterCustomerGral NVARCHAR(MAX);
	

	-- OBTENEMOS EL FOOTER DEL CLIENTE
	SELECT @FooterCustomerGral = Valor FROM [App].[tblConfiguracionesGenerales] WHERE IDConfiguracion = 'FooterEmails';
	

	SELECT IDContainer
			, Container
			, Head
			, Body
			, Footer
			, HeadCustomer
			, BodyCustomerContainer			
			, REPLACE(CAST(FooterCustomer AS VARCHAR(MAX)), '{footerCustomer}', @FooterCustomerGral) + CAST(CloseDiv AS VARCHAR(10)) AS FooterCustomer
			, CloseDiv
	FROM [App].[tblTemplateContainersEmail]
	WHERE IDContainer = @CONTAINER_DEFAULT;


END
GO
