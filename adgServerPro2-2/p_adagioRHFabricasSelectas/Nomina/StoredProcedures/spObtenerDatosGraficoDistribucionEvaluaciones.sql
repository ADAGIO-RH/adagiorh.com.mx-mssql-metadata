USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spObtenerDatosGraficoDistribucionEvaluaciones]
    @IDControlAumentosDesempeno INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tabla temporal para almacenar las evaluaciones
    DECLARE @Evaluaciones TABLE (
        IDControlAumentosDesempenoDetalle INT,
        TotalEvaluacion DECIMAL(18, 4)
    );
    
    -- Obtener los datos de evaluación
    INSERT INTO @Evaluaciones (IDControlAumentosDesempenoDetalle, TotalEvaluacion)
    SELECT 
        D.IDControlAumentosDesempenoDetalle,
        (
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
                    END 
        )
        * 100 AS TotalEvaluacion
    FROM Nomina.TblControlAumentosDesempenoDetalle D
    WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        AND (D.ExcluirColaborador IS NULL OR D.ExcluirColaborador = 0);
    
    -- Calcular estadísticas
    DECLARE @Media DECIMAL(18, 4);
    DECLARE @DesvEstandar DECIMAL(18, 4);
    DECLARE @Min DECIMAL(18, 4);
    DECLARE @Max DECIMAL(18, 4);
    DECLARE @MaxIntervalo DECIMAL(18, 4);
    
    SELECT 
        @Media = AVG(TotalEvaluacion),
        @DesvEstandar = STDEV(TotalEvaluacion),
        @Min = MIN(TotalEvaluacion),
        @Max = MAX(TotalEvaluacion)
    FROM @Evaluaciones
    WHERE TotalEvaluacion > 0;
    
    -- Tabla para almacenar los resultados de la distribución
    DECLARE @Resultados TABLE (
        Intervalo DECIMAL(18, 1),
        Distribucion DECIMAL(18, 10),
        Frecuencia INT
    );
    
    -- Generar los intervalos desde 5.0 hasta 130.0 con incrementos de 5
    DECLARE @ValorIntervalo DECIMAL(18, 1) = 5.0;
    
    -- Variables para normalizar la distribución
    DECLARE @MaxDistribucion DECIMAL(18, 10) = 0;
    DECLARE @TempResultados TABLE (
        Intervalo DECIMAL(18, 1),
        Distribucion DECIMAL(18, 10),
        Frecuencia INT
    );
    SET @MaxIntervalo=@Max + (@Max*0.20)
    -- Primer paso: calcular todos los valores y encontrar el máximo    
    WHILE @ValorIntervalo <= @MaxIntervalo
    BEGIN
        DECLARE @Distribucion DECIMAL(18, 10) = 0;
        DECLARE @Frecuencia INT;
        
        -- Calcular la distribución normal (PDF)
        IF @DesvEstandar <> 0
        BEGIN
            SET @Distribucion = 
                (1 / (@DesvEstandar * SQRT(2 * PI()))) * 
                EXP(-0.5 * POWER((@ValorIntervalo - @Media) / @DesvEstandar, 2));
                
            -- Actualizar el valor máximo de distribución
            IF @Distribucion > @MaxDistribucion
                SET @MaxDistribucion = @Distribucion;
        END
        
        -- Calcular la frecuencia
        SELECT @Frecuencia = COUNT(*)
        FROM @Evaluaciones
        WHERE TotalEvaluacion >= @ValorIntervalo AND TotalEvaluacion < @ValorIntervalo + 5;
        
        -- Insertar en la tabla temporal
        INSERT INTO @TempResultados (Intervalo, Distribucion, Frecuencia)
        VALUES (@ValorIntervalo, @Distribucion, @Frecuencia);
        
        SET @ValorIntervalo = @ValorIntervalo + 5;
    END;
    
    -- Segundo paso: normalizar los valores de distribución para que el máximo sea 1.0
    -- Esto permite que la distribución se vea correctamente en el gráfico
    INSERT INTO @Resultados (Intervalo, Distribucion, Frecuencia)
    SELECT 
        Intervalo,
        CASE 
            WHEN @MaxDistribucion > 0 THEN Distribucion / @MaxDistribucion
            ELSE 0
        END AS Distribucion,
        Frecuencia
    FROM @TempResultados;
    
    -- Devolver los datos para el gráfico
    SELECT 
        Intervalo,
        Distribucion,
        Frecuencia
    FROM @Resultados
    ORDER BY Intervalo ASC;
END;
GO
