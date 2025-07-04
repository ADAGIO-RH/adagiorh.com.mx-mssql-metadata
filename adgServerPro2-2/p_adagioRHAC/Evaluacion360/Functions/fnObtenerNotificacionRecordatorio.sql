USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [Evaluacion360].[fnObtenerNotificacionRecordatorio](
    @IDTipoProyecto INT
)
RETURNS @Resultado TABLE (
    IDTipoNotificacion	VARCHAR(50),
    Tabla				VARCHAR(100)
)
AS
BEGIN
    INSERT INTO @Resultado (IDTipoNotificacion, Tabla)
    VALUES (
        CASE @IDTipoProyecto
            WHEN 1 THEN 'RecordatorioEvaluacionPendiente360'
            WHEN 2 THEN 'RecordatorioEvaluacionPendienteDesempeno'
            WHEN 3 THEN 'RecordatorioEvaluacionPendienteClimaLaboral'
            WHEN 4 THEN 'RecordatorioEvaluacionPendienteEncuesta'
            ELSE NULL
        END,
        CASE @IDTipoProyecto
            WHEN 1 THEN '[Evaluacion360].[tblRecordatoriosEvaluacion360]'
            WHEN 2 THEN '[Evaluacion360].[tblRecordatoriosEvaluacionDesempeno]'
            WHEN 3 THEN '[Evaluacion360].[tblRecordatoriosEvaluacionClimaLaboral]'
            WHEN 4 THEN '[Evaluacion360].[tblRecordatoriosEvaluacionEncuesta]'
            ELSE NULL
        END
    );

    RETURN;
END;
GO
