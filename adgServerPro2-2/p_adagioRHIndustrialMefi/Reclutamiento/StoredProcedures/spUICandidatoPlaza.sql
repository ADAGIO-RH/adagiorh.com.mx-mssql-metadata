USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-01
-- Description:	sp para Relacionar un candidato con la aplicación
--				a una plaza
-- [Reclutamiento].[spUICandidatoPlaza]0, 53, 31, '2022-01-02'
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spUICandidatoPlaza](
	@IDCandidatoPlaza int = 0,
	@IDCandidato	int,
	@IDPlaza		int,
	@IDProceso		int = 0,
	@SueldoDeseado decimal(18,2) = 0.00,
	@FechaAplicacion datetime = null,
	@IDReclutador int = null,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@Orden int = 0
		--@IDReclutador int
	;

	declare @tempTotalesPorReclutador as table (
		IDReclutador int,
		Total int
	);

	set @FechaAplicacion = getdate();

	IF(@IDCandidatoPlaza = 0)
	BEGIN
		IF(ISNULL(@IDProceso,0) = 0)
		BEGIN
			SELECT top 1 @IDProceso = IDEstatusProceso 
			from Reclutamiento.tblCatEstatusProceso with(nolock) 
			where MostrarEnProcesoSeleccion = 1  
			order by Orden asc
		END

		IF NOT EXISTS (
			Select top 1 1 
			from [Reclutamiento].[tblCandidatoPlaza] with(nolock)
			where 
				IDCandidato = @IDCandidato and 
				IDPlaza = @IDPlaza and 
				IDProceso not in (
									Select IDEstatusProceso 
									from Reclutamiento.tblCatEstatusProceso with(nolock) 
									where ProcesoFinal = 1 
								)
		)
		BEGIN

			/*
				Seleccionamos el Reclutador 
			*/
			insert @tempTotalesPorReclutador(IDReclutador, Total)
			select IDReclutador, SUM(Total)
			from (
				select p.IDReclutador,
					(
						 select count(*)
						 from Reclutamiento.tblCandidatoPlaza cp 
						 where cp.IDPlaza = p.IDPlaza and cp.IDReclutador = p.IDReclutador
					) as Total
				from RH.tblCatPosiciones p 
				where p.IDPlaza = @IDPlaza and p.IDReclutador is not null
			) info
			group by IDReclutador

			select top 1 @IDReclutador=IDReclutador
			from @tempTotalesPorReclutador
			order by Total asc

			INSERT INTO [Reclutamiento].[tblCandidatoPlaza]([IDCandidato],[IDPlaza],[FechaAplicacion],[SueldoDeseado],[IDProceso], [IDReclutador])
			VALUES (
				@IDCandidato
				,@IDPlaza
				,@FechaAplicacion
				,@SueldoDeseado
				,@IDProceso
				, case when isnull(@IDReclutador, 0) = 0 then null else @IDReclutador end
			)

			set @IDCandidatoPlaza = SCOPE_IDENTITY()

			exec App.spINotificacionNuevoCandidato @IDCandidatoPlaza = @IDCandidatoPlaza
		END
		ELSE
		BEGIN
			RAISERROR('La postulación a la vacante no se puede realizar porque existe una previa en proceso.',16,1)
		END
	END
	ELSE
	BEGIN
		IF(ISNULL(@IDProceso,0) = 0)
		BEGIN
			SELECT top 1 @IDProceso = IDProceso from [Reclutamiento].[tblCandidatoPlaza] cp with(nolock) WHERE IDCandidatoPlaza = @IDCandidatoPlaza
				
			SELECT top 1 @Orden = ep.Orden
			from Reclutamiento.tblCatEstatusProceso ep with(nolock)
			where MostrarEnProcesoSeleccion = 1  
			and IDEstatusProceso = @IDProceso
			
			UPDATE [Reclutamiento].[tblCandidatoPlaza]
				SET 
					[IDReclutador] = case when isnull(@IDReclutador, 0) = 0 then null else @IDReclutador end,
					[IDProceso]  = (Select top 1 IDEstatusProceso from Reclutamiento.tblCatEstatusProceso WHERE Orden > @Orden and MostrarEnProcesoSeleccion = 1 order by Orden asc)
			WHERE IDCandidatoPlaza = @IDCandidatoPlaza
			
		END
		ELSE
		BEGIN
			UPDATE [Reclutamiento].[tblCandidatoPlaza]
				SET [IDProceso]  = @IDProceso,
					[SueldoDeseado] = isnull(@SueldoDeseado,0.0),
					[IDReclutador] = case when isnull(@IDReclutador, 0) = 0 then null else @IDReclutador end
			WHERE IDCandidatoPlaza = @IDCandidatoPlaza
		END
	END
END
GO
