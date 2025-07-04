USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spIUConfigDashboardNominaConfig](
	@IDConfigDashboardNomina int = 0,
	@BotonLabel varchar(max),
	@Filtro varchar(max),
	@IDPais int,
	@Traduccion varchar(max),
	@IDUsuario int
)
AS
BEGIN
	declare
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
	IF( isnull(@BotonLabel,'') = '')
	BEGIN
		set @BotonLabel = JSON_VALUE(@Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'BotonLabel'))
	END

	IF(@IDConfigDashboardNomina = 0)
	BEGIN
		select @IDConfigDashboardNomina = MAX(IDConfigDashboardNomina) + 1 FROM Intranet.tblConfigDashboardNomina

		INSERT INTO Intranet.tblConfigDashboardNomina(IDConfigDashboardNomina, BotonLabel, Filtro, IDPais, Traduccion)
		Values(@IDConfigDashboardNomina, @BotonLabel, @Filtro, @IDPais, case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)
	END
	ELSE
	BEGIN
		UPDATE Intranet.tblConfigDashboardNomina
			set BotonLabel = @BotonLabel,
				Filtro = @Filtro,
				IDPais = @IDPais,
				Traduccion = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		WHERE IDConfigDashboardNomina = @IDConfigDashboardNomina
	END

	EXEC Intranet.spBuscarConfigDashboardNominaConfig @IDConfigDashboardNomina=@IDConfigDashboardNomina,@IDUsuario=@IDUsuario
END;
GO
