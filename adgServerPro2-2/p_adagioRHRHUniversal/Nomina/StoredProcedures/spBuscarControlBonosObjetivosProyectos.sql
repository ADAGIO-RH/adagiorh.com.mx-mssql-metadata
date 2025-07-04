USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca proyectos asociados a un bono por objetivos
** Autor			: Javier Peña Fuentes
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2025-02-18
** Paremetros		:              
*****************************************************************************************************/

CREATE PROCEDURE [Nomina].[spBuscarControlBonosObjetivosProyectos](
    @IDControlBonosObjetivos INT,
    @IDUsuario INT
) AS
BEGIN
    SET FMTONLY OFF
    
    BEGIN -- Set Idioma 
        DECLARE  
            @IDIdioma VARCHAR(5),
            @IdiomaSQL VARCHAR(100) = NULL;

        SET DATEFIRST 7;

        SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

        SELECT @IdiomaSQL = [SQL]
        FROM app.tblIdiomas
        WHERE IDIdioma = @IDIdioma;

        IF (@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)
        BEGIN
            SET @IdiomaSQL = 'Spanish';
        END;
  
        SET LANGUAGE @IdiomaSQL;
    END;

    DECLARE @VER_TODAS_LAS_PRUEBAS BIT = 1;
    
    IF OBJECT_ID('tempdb..#tempProyectos') IS NOT NULL DROP TABLE #tempProyectos;
    DECLARE @tempHistorialEstatusProyectos AS TABLE(
        IDEstatusProyecto INT,
        IDProyecto INT,
        IDEstatus INT,
        Estatus VARCHAR(255),
        IDUsuario INT, 
        FechaCreacion DATETIME,
        [ROW] INT
    );

    INSERT @tempHistorialEstatusProyectos
    SELECT 
        tep.IDEstatusProyecto,
        tep.IDProyecto,
        ISNULL(tep.IDEstatus,0) AS IDEstatus,
        ISNULL(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus,
        tep.IDUsuario,
        tep.FechaCreacion,
        ROW_NUMBER() OVER(PARTITION BY tep.IDProyecto ORDER BY tep.IDProyecto, tep.FechaCreacion DESC) AS [ROW]
    FROM [Evaluacion360].[tblCatProyectos] tcp WITH (NOLOCK)
        LEFT JOIN [Evaluacion360].[tblEstatusProyectos] tep WITH (NOLOCK) ON tep.IDProyecto = tcp.IDProyecto
        LEFT JOIN (SELECT * FROM Evaluacion360.tblCatEstatus WITH (NOLOCK) WHERE IDTipoEstatus = 1) estatus ON tep.IDEstatus = estatus.IDEstatus;

    SELECT 
        cbop.IDControlBonosObjetivosProyecto,
        cbop.IDControlBonosObjetivos,
        p.IDProyecto,
        p.Nombre,
        p.Descripcion,
        ISNULL(thep.IDEstatus,0) AS IDEstatus,
        ISNULL(thep.Estatus,'Sin estatus') AS Estatus,
        ISNULL(p.FechaCreacion,GETDATE()) AS FechaCreacion,
        p.IDUsuario,
        Usuario = CASE WHEN emp.IDEmpleado IS NOT NULL 
                      THEN COALESCE(emp.Nombre,'')+' '+COALESCE(emp.Paterno,'')+' '+COALESCE(emp.Materno,'')
                      ELSE COALESCE(u.Nombre,'')+' '+COALESCE(u.Apellido,'') END,
        AutoEvaluacion = CASE WHEN EXISTS (SELECT TOP 1 1 
                                         FROM [Evaluacion360].[tblEvaluadoresRequeridos] 
                                         WHERE IDProyecto = p.IDProyecto AND IDTipoRelacion = 4) 
                             THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
        ISNULL(p.TotalPruebasARealizar,0) AS TotalPruebasARealizar,
        ISNULL(p.TotalPruebasRealizadas,0) AS TotalPruebasRealizadas,
        ISNULL(p.Progreso,0) AS Progreso,
        ISNULL(p.FechaInicio,'1990-01-01') AS FechaInicio,
        ISNULL(p.FechaFin,'1990-01-01') AS FechaFin,
        ISNULL(Calendarizado,CAST(0 AS BIT)) AS Calendarizado,
        ISNULL(IDTask,0) AS IDTask,
        ISNULL(IDSchedule,0) AS IDSchedule,
        ISNULL(wu.IDWizardUsuario,0) AS IDWizardUsuario,
        p.Introduccion,
        p.Indicacion,
        ctp.IDTipoProyecto,
        JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Nombre')) AS TipoProyecto
    FROM [Evaluacion360].[tblCatProyectos] p WITH (NOLOCK)
        INNER JOIN [Evaluacion360].[tblCatTiposProyectos] ctp ON ctp.IDTipoProyecto = ISNULL(p.IDTipoProyecto, 1)
        INNER JOIN [Seguridad].[TblUsuarios] u WITH (NOLOCK) ON p.IDUsuario = u.IDUsuario
        INNER JOIN [Evaluacion360].[tblWizardsUsuarios] wu WITH (NOLOCK) ON wu.IDProyecto = p.IDProyecto
        LEFT JOIN [RH].[tblEmpleados] emp WITH (NOLOCK) ON u.IDEmpleado = emp.IDEmpleado
        LEFT JOIN @tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto AND thep.[ROW] = 1
        INNER JOIN [Nomina].[tblControlBonosObjetivosProyectos] cbop ON cbop.IDProyecto = p.IDProyecto 
            AND cbop.IDControlBonosObjetivos = @IDControlBonosObjetivos
    ORDER BY p.Nombre ASC;
END;
GO
