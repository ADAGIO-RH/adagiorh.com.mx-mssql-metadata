USE [p_adagioRHAfosa]
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
		@NewJSON varchar(Max),
		@IDIdioma varchar(20),
        @IDEmpleado INT
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma',1, 'esmx')

    SET @Accion=UPPER(@Accion)

    -- SELECT @IDEmpleado=IDEmpleado
    -- FROM Evaluacion360.tblObjetivosEmpleados OE
    -- WHERE OE.IDObjetivoEmpleado=@IDObjetivoEmpleado

    -- SELECT TOP 1 @IDUsuarioResponsable=US.IDUsuario
    -- FROM RH.tblJefesEmpleados JE
    -- INNER JOIN Seguridad.tblUsuarios US
    --     ON US.IDEmpleado=JE.IDJefe
    -- WHERE JE.IDEmpleado=@IDEmpleado
    -- ORDER BY IDJefeEmpleado DESC

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
