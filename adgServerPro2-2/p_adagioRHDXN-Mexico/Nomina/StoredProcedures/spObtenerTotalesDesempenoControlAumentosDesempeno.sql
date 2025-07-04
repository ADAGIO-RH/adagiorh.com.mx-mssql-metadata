USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spObtenerTotalesDesempenoControlAumentosDesempeno]
    @IDControlAumentosDesempeno INT,
    @IDUsuario INT
AS
BEGIN

    if object_id('tempdb..#TempResultadosAgrupacion') is not null drop table #TempResultadosAgrupacion;
    if object_id('tempdb..#TempResultadosFinales') is not null drop table #TempResultadosFinales;

    CREATE TABLE #TempResultadosFinales(
        Nivel VARCHAR(10),
        Descripcion VARCHAR(300),
        Total  INT
    )


    SELECT ISNULL(T.Nivel,'-') AS Nivel,ISNULL(T.Descripcion,'OTROS') as Descripcion,COUNT(*) as Total
    INTO #TempResultadosAgrupacion
        FROM(
            SELECT D.*,C.IDTabuladorResultadoDesempeno, 
                    CASE 
                        WHEN D.TotalEvaluacionCalibrado = -1 THEN 0
                        WHEN D.TotalEvaluacionCalibrado > 0 THEN D.TotalEvaluacionCalibrado
                        ELSE D.TotalEvaluacionPeso                     
                    END +
                    -- Total Objetivos: usar calibrado solo si es -1 o > 0
                    CASE 
                        WHEN D.TotalObjetivosCalibrado = -1 THEN 0
                        WHEN D.TotalObjetivosCalibrado > 0 THEN D.TotalObjetivosCalibrado
                        ELSE D.TotalObjetivosPeso 
                    END AS TotalDesempeno
            FROM Nomina.tblControlAumentosDesempeno C
                INNER JOIN NOMINA.TblControlAumentosDesempenoDetalle D
                    ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno                            
            WHERE C.IDControlAumentosDesempeno= @IDControlAumentosDesempeno
        ) as Source
        LEFT JOIN Nomina.tblTabuladorResultadoDesempenoDetalle T
                    ON T.IDTabuladorResultadoDesempeno= Source.IDTabuladorResultadoDesempeno and TotalDesempeno between (MinimoEvaluaciones/100) and (MaximoEvaluaciones/100)    
        GROUP BY T.Nivel, T.Descripcion
        ORDER BY T.Nivel

    INSERT INTO #TempResultadosFinales 
    SELECT * 
    FROM #TempResultadosAgrupacion R    
    UNION
    SELECT T.Nivel,T.Descripcion,0 as Total    
    FROM Nomina.tblcontrolaumentosdesempeno ca        
    INNER JOIN Nomina.tblTabuladorResultadoDesempenoDetalle T
                    ON T.IDTabuladorResultadoDesempeno= ca.IDTabuladorResultadoDesempeno
    LEFT JOIN  #TempResultadosAgrupacion R    
        ON R.Nivel = T.Nivel
    WHERE R.Nivel IS NULL AND CA.IDControlAumentosDesempeno=@IDControlAumentosDesempeno


    SELECT * FROM #TempResultadosFinales ORDER BY Nivel 

END
GO
