USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca licencia en aplicaciones
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-02-09
** Paremetros		: @IDAplicacion			- Identificador de la aplicación.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Licencia].[spBuscarLicencia](
	@IDAplicacion	NVARCHAR(100)
	, @IDUsuario	INT	= 0
)
AS
BEGIN

	SELECT IDConfiguracion
			, IDAplicacion
			, Configuracion AS ResultJson
	FROM [Licencia].[tblConfiguracionAplicaciones]
	WHERE IDAplicacion = @IDAplicacion

END
GO
