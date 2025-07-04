USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-23
-- Description:	sp para enviar notificaciones de tipo 
--				candidato proceso
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spINotificacionEstadoCandidatoPlaza] 
	(
		@IDCandidatoPlaza int 
	)
AS
BEGIN


declare 
	@EmailCandidato varchar(50) = '',
	@IDNotificacion int = 0,
	@Parametros varchar(max)

	IF NOT EXISTS(select count(*) from App.tblNotificaciones WHERE IDTipoNotificacion = 'CambioEstatusProcesoReclutamiento')
		BEGIN

			insert into App.tblNotificaciones
			 (IDTipoNotificacion,FechaHoraCreacion, IDIdioma) values
			 ('CambioEstatusProcesoReclutamiento', GETDATE(),'es-MX')
			 set @IDNotificacion = @@IDENTITY
		end
	else
		begin
			select @IDNotificacion = IDNotifiacion from App.tblNotificaciones where IDTipoNotificacion = 'CambioEstatusProcesoReclutamiento'
		END

	SELECT
		cp.IDCandidatoPlaza, cp.IDCandidato, cp.IDPlaza, cp.FechaAplicacion, 
		cp.IDProceso, cp.SueldoDeseado, c.Nombre, 
		c.SegundoNombre, c.Paterno, c.Materno, c.Sexo, c.FechaNacimiento, 
        c.IDPaisNacimiento, c.IDEstadoNacimiento, c.IDMunicipioNacimiento, 
		c.IDLocalidadNacimiento, c.RFC, c.CURP, c.NSS, c.IDAFORE, 
		c.IDEstadoCivil, c.Estatura, c.Peso, c.TipoSangre, c.Extranjero, 
		c.Email, c.Password, c.IDEmpleado
FROM    
		Reclutamiento.tblCandidatoPlaza AS cp LEFT OUTER JOIN
        Reclutamiento.tblCandidatos AS c ON cp.IDCandidato = c.IDCandidato

	exec [Reclutamiento].[spPlantillaCuerpo]@IDCandidatoPlaza


	INSERT INTO [App].[tblEnviarNotificacionA]
           ([IDNotifiacion]
           ,[IDMedioNotificacion]
           ,[Destinatario]
           ,[Enviado]
           ,[FechaHoraEnvio]
           ,[FechaHoraCreacion]
           ,[Adjuntos]
           ,[Parametros])
     VALUES
           (@IDNotificacion
           ,'Email'
           ,@EmailCandidato
           ,0
           ,null
           ,GETDATE()
           ,null
           ,@Parametros)



END
GO
