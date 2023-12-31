USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [Evaluacion360].[spIUPlanAccionObjetivo](
	@IDPlanAccionObjetivo INT = 0,
    @IDObjetivoEmpleado INT,
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

    SELECT @IDEmpleado=IDEmpleado
    FROM Evaluacion360.tblObjetivosEmpleados OE
    WHERE OE.IDObjetivoEmpleado=@IDObjetivoEmpleado

    SELECT TOP 1 @IDUsuarioResponsable=US.IDUsuario
    FROM RH.tblJefesEmpleados JE
    INNER JOIN Seguridad.tblUsuarios US
        ON US.IDEmpleado=JE.IDJefe
    WHERE JE.IDEmpleado=@IDEmpleado
    ORDER BY IDJefeEmpleado DESC

	IF (isnull(@IDPlanAccionObjetivo, 0) = 0)
	BEGIN
		INSERT Evaluacion360.tblPlanAccionObjetivos(
			 IDObjetivoEmpleado
			,Fecha
			,Accion
            ,PorcentajeAlcanzado
            ,IDEstatusPlanAccionObjetivo
            ,IDUsuarioResponsable
			
		)
		VALUES (
			 @IDObjetivoEmpleado
			,@Fecha
			,@Accion
			,isnull(@PorcentajeAlcanzado, 0)
            ,@IDEstatusPlanAccionObjetivo
			,@IDUsuarioResponsable
		)

		SET @IDPlanAccionObjetivo = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM (
			SELECT
                    PAO.IDPlanAccionObjetivo
                   ,PAO.IDObjetivoEmpleado
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable
                   ,OE.IDEmpleado
			FROM Evaluacion360.tblPlanAccionObjetivos PAO				
                INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                    ON OE.IDObjetivoEmpleado=PAO.IDObjetivoEmpleado
			WHERE (PAO.IDPlanAccionObjetivo = @IDPlanAccionObjetivo)
		) b
			CROSS APPLY (SELECT JSON=[Utilerias].[fnStrJSON](0,1,(SELECT b.* For XML RAW)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblPlanAccionObjetivos',' Evaluacion360.spIUPlanAccionObjetivo','INSERT',@NewJSON,''
	END ELSE
	BEGIN
		SELECT @OldJSON = a.JSON 
		FROM (
            SELECT
                    PAO.IDPlanAccionObjetivo
                   ,PAO.IDObjetivoEmpleado
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable
                   ,OE.IDEmpleado
			FROM Evaluacion360.tblPlanAccionObjetivos PAO				
                INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                    ON OE.IDObjetivoEmpleado=PAO.IDObjetivoEmpleado
			WHERE (PAO.IDPlanAccionObjetivo = @IDPlanAccionObjetivo)
		) b
			CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		UPDATE Evaluacion360.tblPlanAccionObjetivos
			SET
                     Fecha=@Fecha
                    ,Accion=@Accion
                    ,PorcentajeAlcanzado=@PorcentajeAlcanzado
                    ,IDEstatusPlanAccionObjetivo=@IDEstatusPlanAccionObjetivo
                    ,IDUsuarioResponsable=@IDUsuarioResponsable
		WHERE IDPlanAccionObjetivo = @IDPlanAccionObjetivo

		SELECT @NewJSON = a.JSON 
		FROM (
            SELECT
                    PAO.IDPlanAccionObjetivo
                   ,PAO.IDObjetivoEmpleado
                   ,PAO.Fecha
                   ,PAO.Accion
                   ,PAO.PorcentajeAlcanzado
                   ,PAO.IDEstatusPlanAccionObjetivo
                   ,PAO.IDUsuarioResponsable
                   ,OE.IDEmpleado
			FROM Evaluacion360.tblPlanAccionObjetivos PAO				
            INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                    ON OE.IDObjetivoEmpleado=PAO.IDObjetivoEmpleado
			WHERE (PAO.IDPlanAccionObjetivo = @IDPlanAccionObjetivo)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblPlanAccionObjetivos',' Evaluacion360.spIUPlanAccionObjetivo','UPDATE',@NewJSON,@OldJSON
	end

    EXEC [Evaluacion360].[spBuscarPlanAccionObjetivo]
	    @IDPlanAccionObjetivo=@IDPlanAccionObjetivo,
		@IDUsuario=@IDUsuario
GO
