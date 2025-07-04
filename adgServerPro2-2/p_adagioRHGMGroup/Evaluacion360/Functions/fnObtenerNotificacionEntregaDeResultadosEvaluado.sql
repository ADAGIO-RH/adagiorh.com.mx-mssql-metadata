USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [Evaluacion360].[fnObtenerNotificacionEntregaDeResultadosEvaluado](
    @IDTipoProyecto INT
)
RETURNS @Resultado TABLE (
    IDTipoNotificacionEvaluado		VARCHAR(50)
	, TablaEvaluado					VARCHAR(100)
)
AS
BEGIN
    INSERT INTO @Resultado (IDTipoNotificacionEvaluado, TablaEvaluado)
    VALUES (
        CASE @IDTipoProyecto
            WHEN 1 THEN 'EntregaDeResultadosEvaluado360'
            WHEN 2 THEN 'EntregaDeResultadosEvaluadoDesempeno'
            WHEN 3 THEN 'EntregaDeResultadosEvaluadoClimaLaboral'
            WHEN 4 THEN 'EntregaDeResultadosEvaluadoEncuesta'
            ELSE NULL
        END,
        CASE @IDTipoProyecto
            WHEN 1 THEN '[Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacion360]'
            WHEN 2 THEN '[Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacionDesempeno]'
            WHEN 3 THEN '[Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacionClimaLaboral]'
            WHEN 4 THEN '[Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacionEncuesta]'
            ELSE NULL
        END
    );

    RETURN;
END;
GO
