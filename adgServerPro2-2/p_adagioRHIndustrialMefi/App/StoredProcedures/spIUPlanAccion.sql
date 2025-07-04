USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spIUPlanAccion](
	@IDPlanAccion INT = 0,
    @IDTipoPlanAccion INT,
    @IDReferencia INT,
    @Fecha DATE,
    @Accion VARCHAR(MAX),
    @PorcentajeAlcanzado DECIMAL(18,2),
    @IDEstatusPlanAccionObjetivo INT,
    @IDUsuarioResponsable INT=0,
	@IDUsuario INT
) AS

	DECLARE 
		@OldJSON varchar(Max),
        @Message varchar(MAX),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20),
        @IDEmpleado INT,
        @IDCicloMedicionObjetivo INT,
        @IDEstatusAutorizacion INT,
        @IDEstatusCicloMedicionObjetivo INT,
        @ID_TIPO_PLAN_ACCION_OBJETIVOS INT=1,
        @ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR int = 1,
        @ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO int = 2,
        @ID_ESTATUS_AUTORIZACION_AUTORIZADO int = 2
	;


    IF(@IDTipoPlanAccion=@ID_TIPO_PLAN_ACCION_OBJETIVOS)
        BEGIN
         SELECT 
           
           @IDCicloMedicionObjetivo = IDCicloMedicionObjetivo           
           ,@IDEstatusAutorizacion   = IDEstatusAutorizacion
        FROM Evaluacion360.tblObjetivosEmpleados
        WHERE IDObjetivoEmpleado=@IDReferencia

        SELECT             
            @IDEstatusCicloMedicionObjetivo=CMO.IDEstatusCicloMedicion
        FROM Evaluacion360.tblCatCiclosMedicionObjetivos CMO WITH (NOLOCK)
        WHERE CMO.IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo


        IF(@IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR AND @IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO)
        BEGIN 
                set @Message = FORMATMESSAGE('El estatus actual del ciclo de medición no permite capturar o realizar cambios en planes de acción')
	    		raiserror(@Message,16,1)
	    		return;						
        END

        IF(@IDEstatusAutorizacion<>@ID_ESTATUS_AUTORIZACION_AUTORIZADO)
        BEGIN 
                set @Message = FORMATMESSAGE('No se puede capturar un plan de acción en un objetivo que no ha sido autorizado')
	    		raiserror(@Message,16,1)
	    		return;						
        END

    END

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma',1, 'esmx')

    SET @Accion=UPPER(@Accion)



	IF (isnull(@IDPlanAccion, 0) = 0)
	BEGIN
		INSERT App.tblPlanAccion(
			 IDTipoPlanAccion
            ,IDReferencia
			,Fecha
			,Accion
            ,PorcentajeAlcanzado
            ,IDEstatusPlanAccionObjetivo
            ,IDUsuarioResponsable
			
		)
		VALUES (
			 @IDTipoPlanAccion
            ,@IDReferencia
			,@Fecha
			,@Accion
			,isnull(@PorcentajeAlcanzado, 0)
            ,@IDEstatusPlanAccionObjetivo
			,@IDUsuarioResponsable
		)

		SET @IDPlanAccion = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM (
			SELECT
                    PAO.IDPlanAccion
                   ,PAO.IDTipoPlanAccion
                   ,PAO.IDReferencia
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable                   
			FROM App.tblPlanAccion PAO              
			WHERE (PAO.IDPlanAccion = @IDPlanAccion)
		) b
			CROSS APPLY (SELECT JSON=[Utilerias].[fnStrJSON](0,1,(SELECT b.* For XML RAW)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblPlanAccion','App.spIUPlanAccion','INSERT',@NewJSON,''
	END ELSE
	BEGIN
		SELECT @OldJSON = a.JSON 
		FROM (
                SELECT
                    PAO.IDPlanAccion
                   ,PAO.IDTipoPlanAccion
                   ,PAO.IDReferencia
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable                   
			FROM App.tblPlanAccion PAO              
			WHERE (PAO.IDPlanAccion = @IDPlanAccion)
		) b
			CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		UPDATE App.tblPlanAccion
			SET
                     Fecha=@Fecha
                    ,Accion=@Accion
                    ,PorcentajeAlcanzado=@PorcentajeAlcanzado
                    ,IDEstatusPlanAccionObjetivo=@IDEstatusPlanAccionObjetivo
                    ,IDUsuarioResponsable=@IDUsuarioResponsable
		WHERE IDPlanAccion = @IDPlanAccion

		SELECT @NewJSON = a.JSON 
		FROM (
            SELECT
                    PAO.IDPlanAccion
                   ,PAO.IDTipoPlanAccion
                   ,PAO.IDReferencia
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable                   
			FROM App.tblPlanAccion PAO              
			WHERE (PAO.IDPlanAccion = @IDPlanAccion)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblPlanAccion','App.spIUPlanAccion','UPDATE',@NewJSON,@OldJSON
	end

    -- EXEC [Evaluacion360].[spBuscarPlanAccionObjetivo]
	--     @IDPlanAccionObjetivo=@IDPlanAccionObjetivo,
	-- 	@IDUsuario=@IDUsuario
GO
