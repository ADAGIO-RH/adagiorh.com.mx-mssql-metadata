USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](
    @IDEmpleado int,
    @IDTipoRelacionStr varchar(max), -- Cambiado a string para múltiples tipos
    @ProyectosStr varchar(max)
)
RETURNS decimal(18, 4)
AS
BEGIN
    DECLARE @Porcentaje decimal(18, 4) = null;
    
    -- Convertir el string de proyectos en una tabla temporal
    DECLARE @Proyectos TABLE (IDProyecto int);
    INSERT INTO @Proyectos
    SELECT value FROM STRING_SPLIT(@ProyectosStr, ',');

    -- Convertir el string de tipos de relación en una tabla temporal
    DECLARE @TiposRelacion TABLE (IDTipoRelacion int);
    INSERT INTO @TiposRelacion
    SELECT value FROM STRING_SPLIT(@IDTipoRelacionStr, ',');
    
    SELECT 
        @Porcentaje = AVG(EM.Porcentaje)
    FROM Evaluacion360.tblEvaluacionesEmpleados EM    
    INNER JOIN Evaluacion360.TBLempleadosProyectos EP
        ON EM.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
    INNER JOIN Evaluacion360.tblCatProyectos CP
        ON EP.IDProyecto = CP.IDProyecto
    INNER JOIN @Proyectos P
        ON CP.IDProyecto = P.IDProyecto
    INNER JOIN @TiposRelacion TR
        ON EM.IDTipoRelacion = TR.IDTipoRelacion
    WHERE EP.IDEmpleado = @IDEmpleado;

    RETURN @Porcentaje/100;
END
GO
