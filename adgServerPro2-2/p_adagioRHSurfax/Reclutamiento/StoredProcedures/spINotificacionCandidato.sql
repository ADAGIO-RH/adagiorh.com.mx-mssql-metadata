USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-30
-- Description:	SP para agregar la notificación de cambio de estado del candidato
-- =============================================
-- [Reclutamiento].[spINotificacionCandidato]
CREATE PROCEDURE [Reclutamiento].[spINotificacionCandidato] 
	(
		@Contenido varchar(max) = ''
		,@Asunto varchar(max) = ''
		,@IDCandidato int = 0
	)
AS
BEGIN
	
	declare @IDNotificacion int = 0,
	@Email varchar(255) = '',
	@ParametrosJSON varchar(max),
    @IDTIPO_REFERENCIA_CANDIDATOS varchar(255)

    set @IDTIPO_REFERENCIA_CANDIDATOS='[Reclutamiento].[tblCandidatos]'
    
	DECLARE @Parametros TABLE
	(
		[subject] varchar(max),
		[body] varchar(max)
	)

	insert into @Parametros
	select @Asunto, @Contenido

	 select top 1 @ParametrosJSON = 
	 (
		SELECT
			subject, 
			body
		FOR JSON PATH, 
			INCLUDE_NULL_VALUES, 
			WITHOUT_ARRAY_WRAPPER
		)
	 from @Parametros

	select @Email = Email from Reclutamiento.tblCandidatos where IDCandidato = @IDCandidato
	
	if (@IDCandidato is not null and @IDCandidato<>0)
	begin
		
		if (LEN(@Email) > 0)
		begin
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)    
			select 'ReclutamientoProcesos',@ParametrosJSON  
  
			set @IDNotificacion = @@IDENTITY    
     
			insert [App].[tblEnviarNotificacionA](IDNotifiacion,IDMedioNotificacion,Destinatario,TipoReferencia,IDReferencia)    
			select @IDNotificacion    
				,templateNot.IDMedioNotificacion    
				,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end    
                ,@IDTIPO_REFERENCIA_CANDIDATOS
                ,@IDCandidato
			from [App].[tblTiposNotificaciones] tn    
				join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion    
			where tn.IDTipoNotificacion = 'ReclutamientoProcesos'    

		 end

	end; 



END
GO
