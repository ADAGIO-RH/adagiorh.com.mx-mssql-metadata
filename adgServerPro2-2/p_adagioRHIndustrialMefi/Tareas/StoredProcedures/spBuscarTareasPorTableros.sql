USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [tareas].[spBuscarTareasPorTableros] (
    @IDUsuario int
)
AS Begin
WITH Tableros AS (
    SELECT IDTableroUsuario,
    IDReferencia
    FROM Tareas.tblTableroUsuarios    
    WHERE IDUsuario = @IDUsuario
),
TareasProceso AS (
    SELECT 
        TU.IDTableroUsuario,
        COUNT(CASE WHEN T.IDEstatusTarea = ETC.IDEstatusTarea AND T.IDTipoTablero = 3 AND ETC.IDReferencia = 0 AND ETC.IsEnd = 1 THEN 1 END) AS TareasCompletadas,
        COUNT(CASE WHEN T.IDEstatusTarea != ETC.IDEstatusTarea AND T.IDTipoTablero = 3 AND ETC.IDReferencia = 0 AND ETC.IsEnd = 1 THEN 1 END) AS TareasPendientes,
        PO.NombreProceso,
         T.IDTipoTablero as TipoTablero
    FROM Tareas.tblTableroUsuarios TU
    LEFT JOIN Onboarding.tblProcesosOnboarding PO ON TU.IDReferencia = PO.IDProcesoOnboarding
    LEFT JOIN Tareas.tblTareas T ON PO.IDProcesoOnboarding = T.IDReferencia
    LEFT JOIN Tareas.tblCatEstatusTareas ETC ON ETC.IDTipoTablero = 3 AND ETC.IDReferencia = 0 AND ETC.IsEnd = 1 
    WHERE TU.IDUsuario = @IDUsuario AND TU.IDTipoTablero = 3
    GROUP BY TU.IDTableroUsuario, PO.NombreProceso, T.IDTipoTablero
),
OtrasTareas AS (
    SELECT 
        TU.IDTableroUsuario,
        COUNT(CASE WHEN T.IDEstatusTarea = ETC.IDEstatusTarea AND T.IDTipoTablero = 1 AND ETC.IsEnd = 1 THEN 1 END) AS TareasCompletadas,
        COUNT(CASE WHEN T.IDEstatusTarea != ETC.IDEstatusTarea AND T.IDTipoTablero = 1 AND ETC.IsEnd = 1  THEN 1 END) AS TareasPendientes,
        T.IDTipoTablero as TipoTablero
    FROM Tareas.tblTableroUsuarios TU
    LEFT JOIN Tareas.tblTareas T ON TU.IDReferencia = T.IDTarea
    LEFT JOIN Tareas.tblCatEstatusTareas ETC ON T.IDEstatusTarea = ETC.IDEstatusTarea AND ETC.IsEnd = 1
    WHERE TU.IDUsuario = @IDUsuario AND TU.IDTipoTablero = 1
    GROUP BY TU.IDTableroUsuario, T.IDTipoTablero
)
SELECT top 4
    TU.IDTableroUsuario,
    (COALESCE(TP.TareasCompletadas, 0) + COALESCE(TP.TareasPendientes, 0)) + (COALESCE(OT.TareasCompletadas, 0) + COALESCE(OT.TareasPendientes, 0)) AS TotalTareas,
    --TP.TareasPendientes+TP.TareasCompletadas AS TotalTareas,
    COALESCE(TP.TareasCompletadas, 0) + COALESCE(OT.TareasCompletadas, 0) AS TareasCompletadas,
    COALESCE(TP.TareasPendientes, 0) + COALESCE(OT.TareasPendientes, 0) AS TareasPendientes,
 Avance = CASE 
                WHEN (COALESCE(TP.TareasCompletadas, 0) + COALESCE(TP.TareasPendientes, 0) + COALESCE(OT.TareasCompletadas, 0) + COALESCE(OT.TareasPendientes, 0)) = 0 THEN 0
                ELSE CAST((CAST(COALESCE(TP.TareasCompletadas, 0) + COALESCE(OT.TareasCompletadas, 0) AS DECIMAL(18, 2))) / (COALESCE(TP.TareasCompletadas, 0) + COALESCE(TP.TareasPendientes, 0) + COALESCE(OT.TareasCompletadas, 0) + COALESCE(OT.TareasPendientes, 0)) * 100 AS DECIMAL(18, 2))
            END,
    COALESCE(NULLIF(T.Titulo, ''), NULLIF(TP.NombreProceso, ''), 'Tablero sin título') AS Titulo,
    TU.IDReferencia,
      CASE 
        WHEN TP.IDTableroUsuario IS NOT NULL THEN 3
        WHEN OT.IDTableroUsuario IS NOT NULL THEN 1
        ELSE 0
    END AS TipoTablero

FROM Tableros TU
LEFT JOIN TareasProceso TP ON TU.IDTableroUsuario = TP.IDTableroUsuario
LEFT JOIN OtrasTareas OT ON TU.IDTableroUsuario = OT.IDTableroUsuario
LEFT join Tareas.tblTablero T on TU.IDReferencia = T.IDTablero

END
GO
