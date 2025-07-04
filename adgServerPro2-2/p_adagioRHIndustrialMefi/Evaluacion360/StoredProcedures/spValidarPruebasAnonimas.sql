USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida el minimo de pruebas realizadas y retorna la configuracion de privacidad.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-09-26
** Paremetros		: @IDProyecto			Identificador del proyecto
					  @IDEmpleadoProyecto	Identificador del empleado proyecto

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spValidarPruebasAnonimas](
    @IDProyecto INT = 0,
    @IDEmpleadoProyecto INT = 0,
	@IDEvaluacionEmpleado INT = 0,
	@EsRptBasico BIT = 0,
    @IDUsuario INT = 0,
    @Resultado VARCHAR(250) OUTPUT,
	@Descripcion VARCHAR(25) OUTPUT,
	@Iniciales VARCHAR(25) = NULL OUTPUT
) AS
BEGIN

    DECLARE
        @TotalEvaluacionesRealizadas INT = 0,
        @IDTipoProyecto INT = 0,
        @Privacidad BIT = 0,
        @MINIMO_EVALUACIONES_REALIZADAS INT = 3,		-- NUMERO MINIMO DE EVALUACIONES REALIZADAS.
        @ACTIVO BIT = 1,
        @ID_TIPO_PROYECTO_CLIMA_LABORAL INT = 3;


    BEGIN TRY
        BEGIN TRAN;

			IF(@EsRptBasico = @ACTIVO)
				BEGIN
					SET @MINIMO_EVALUACIONES_REALIZADAS = 0;		-- NUMERO MINIMO DE EVALUACIONES REALIZADAS.
				END
			

			IF(@IDEmpleadoProyecto <> 0 AND @IDProyecto = 0)
				BEGIN					
					SELECT @IDProyecto = IDProyecto
					FROM [Evaluacion360].[tblEmpleadosProyectos]
					WHERE IDEmpleadoProyecto = @IDEmpleadoProyecto
				END

			IF(@IDEvaluacionEmpleado <> 0 AND @IDProyecto = 0)
				BEGIN
					SELECT @IDProyecto = EP.IDProyecto 
					FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE
						INNER JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
					WHERE EE.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
				END
			

			SELECT @TotalEvaluacionesRealizadas = TotalPruebasRealizadas,
				   @IDTipoProyecto = IDTipoProyecto,
				   @Privacidad = Privacidad
			FROM [Evaluacion360].[tblCatProyectos]
			WHERE IDProyecto = @IDProyecto


			-- VALIDACIONES
			IF (@IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL)
			BEGIN
				SET @Privacidad = @ACTIVO;
			END
			
			IF (@Privacidad = @ACTIVO AND @TotalEvaluacionesRealizadas < @MINIMO_EVALUACIONES_REALIZADAS)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318005';
				COMMIT;
				RETURN;
			END
			-- TERMINAN VALIDACIONES


			-- RESULTADO
			SET @Resultado = CAST(@Privacidad AS VARCHAR(250));
			SET @Descripcion = 'ANÓMINO';
			SET @Iniciales = 'AN'
			COMMIT;
			RETURN;

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SET @Resultado = ERROR_MESSAGE();
    END CATCH;

END;
GO
