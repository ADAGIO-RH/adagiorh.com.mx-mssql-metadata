USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spIUConfigDashboardNominaConfig
(
	@IDConfigDashboardNomina int = 0,
	@BotonLabel varchar(max),
	@Filtro varchar(max)
)
AS
BEGIN

	IF(@IDConfigDashboardNomina = 0)
	BEGIN
		select @IDConfigDashboardNomina = MAX(IDConfigDashboardNomina) + 1 FROM Intranet.tblConfigDashboardNomina

		INSERT INTO Intranet.tblConfigDashboardNomina(IDConfigDashboardNomina,BotonLabel,Filtro)
		Values(@IDConfigDashboardNomina, @BotonLabel,@Filtro)
	END
	ELSE
	BEGIN
		UPDATE Intranet.tblConfigDashboardNomina
			set BotonLabel = @BotonLabel,
				Filtro = @Filtro
		WHERE IDConfigDashboardNomina = @IDConfigDashboardNomina
	END
	EXEC intranet.spBuscarConfigDashboardNominaConfig @IDConfigDashboardNomina
END;
GO
