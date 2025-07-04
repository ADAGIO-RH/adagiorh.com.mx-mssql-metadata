USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [Evaluacion360].[fnObtenerNotificacionInvitacion](
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
            WHEN 1 THEN 'InvitacionRealizar360'
            WHEN 2 THEN 'InvitacionRealizarDesempeno'
            WHEN 3 THEN 'InvitacionRealizarClimaLaboral'
            WHEN 4 THEN 'InvitacionRealizarEncuesta'
            ELSE NULL
        END,
        CASE @IDTipoProyecto
            WHEN 1 THEN '[Evaluacion360].[tblInvitacionesEvaluacion360]'
            WHEN 2 THEN '[Evaluacion360].[tblInvitacionesEvaluacionDesempeno]'
            WHEN 3 THEN '[Evaluacion360].[tblInvitacionesEvaluacionClimaLaboral]'
            WHEN 4 THEN '[Evaluacion360].[tblInvitacionesEvaluacionEncuesta]'
            ELSE NULL
        END
    );

    RETURN;
END;
GO
