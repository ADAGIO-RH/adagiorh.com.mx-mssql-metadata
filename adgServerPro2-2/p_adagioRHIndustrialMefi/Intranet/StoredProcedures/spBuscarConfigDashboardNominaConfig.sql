USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarConfigDashboardNominaConfig](
	@IDConfigDashboardNomina int = 0,
	@IDUsuario int
) 
AS
BEGIN
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		cdn.IDConfigDashboardNomina
		--,cdn.BotonLabel
		,JSON_VALUE(cdn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'BotonLabel')) as BotonLabel
		,cdn.Filtro
		,isnull(cdn.IDPais, 151) as IDPais
		,isnull(p.Descripcion, 'MEXICO') as Pais
		,cdn.Traduccion
	from Intranet.tblConfigDashboardNomina cdn
		left join SAT.tblCatPaises p on p.IDPais = cdn.IDPais
	where cdn.IDConfigDashboardNomina = @IDConfigDashboardNomina or @IDConfigDashboardNomina = 0
END
GO
