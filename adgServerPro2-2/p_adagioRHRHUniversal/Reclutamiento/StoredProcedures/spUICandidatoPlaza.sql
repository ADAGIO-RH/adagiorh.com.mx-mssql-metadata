USE [p_adagioRHRHUniversal]
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
CREATE PROCEDURE [Reclutamiento].[spUICandidatoPlaza]
	(
		@IDCandidatoPlaza int = 0,
		@IDCandidato int = 0,
		@IDPlaza int = 0,
		@IDProceso int = 0,
		@SueldoDeseado decimal(18,2) = 0.00,
		@FechaAplicacion datetime = null,
		@IDUsuario int
	)

AS
BEGIN
DECLARE @Orden int = 0

	IF(ISNULL(@FechaAplicacion,'') = '')
	BEGIN
		set @FechaAplicacion = GETDATE()
	END

	IF(@IDCandidatoPlaza = 0)
	BEGIN

		IF(ISNULL(@IDProceso,0) = 0)
		BEGIN
			SELECT top 1 @IDProceso = IDEstatusProceso 
			from Reclutamiento.tblCatEstatusProceso with(nolock) 
			where MostrarEnProcesoSeleccion = 1  
			order by Orden asc
		END
		IF NOT EXISTS (Select top 1 1 from [Reclutamiento].[tblCandidatoPlaza] with(nolock) where IDCandidato = @IDCandidato and IDPlaza = @IDPlaza and IDProceso not in (Select IDEstatusProceso from Reclutamiento.tblCatEstatusProceso with(nolock) where MostrarEnProcesoSeleccion = 1 and ProcesoFinal = 1 ))
		BEGIN
			INSERT INTO [Reclutamiento].[tblCandidatoPlaza]
					   ([IDCandidato]
					   ,[IDPlaza]
					   ,[FechaAplicacion]
					   ,[SueldoDeseado]
					   ,[IDProceso])
				 VALUES
					   (@IDCandidato
					   ,@IDPlaza
					   ,@FechaAplicacion
					   ,@SueldoDeseado
					   ,@IDProceso)
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
				SET [IDProceso]  = (Select top 1 IDEstatusProceso from Reclutamiento.tblCatEstatusProceso WHERE Orden > @Orden and MostrarEnProcesoSeleccion = 1 order by Orden asc)
			WHERE IDCandidatoPlaza = @IDCandidatoPlaza
			
		END
		ELSE
		BEGIN
			UPDATE [Reclutamiento].[tblCandidatoPlaza]
				SET [IDProceso]  = @IDProceso,
					[SueldoDeseado] = isnull(@SueldoDeseado,0.0)
			WHERE IDCandidatoPlaza = @IDCandidatoPlaza
		END

		
		
	END

end
GO
