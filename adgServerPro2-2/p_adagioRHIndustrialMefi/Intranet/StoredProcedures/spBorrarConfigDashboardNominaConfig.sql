USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBorrarConfigDashboardNominaConfig](
	@IDConfigDashboardNomina int
)
AS
BEGIN
	declare 
		@IDUsuarioAdmin int
	;

	SELECT TOP 1 @IDUsuarioAdmin = Valor FROM app.tblConfiguracionesGenerales WITH(NOLOCK) WHERE IDConfiguracion = 'IDUsuarioAdmin' 
	
	EXEC Intranet.spBuscarConfigDashboardNominaConfig @IDConfigDashboardNomina=@IDConfigDashboardNomina,@IDUsuario=@IDUsuarioAdmin
	
	DELETE Intranet.tblConfigDashboardNomina
	WHERE IDConfigDashboardNomina = @IDConfigDashboardNomina
END
GO
