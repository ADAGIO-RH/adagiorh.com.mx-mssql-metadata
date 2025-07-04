USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Saludoc.spGenerarProcesoEncuesta 3,1



CREATE   PROCEDURE [Saludoc].[spGenerarProcesoEncuesta](
--DECLARE 
	@IDProcesoEncuesta int = 3,
	@IDUsuario int = 1
)
AS
BEGIN
	DECLARE
		 @IDCliente int
		,@FechaInicio date
		,@FechaFin date
		,@PorcentajeAjuste Decimal(18,4)
		,@dtEmpleados RH.dtEmpleados
		,@dtPeriodos Nomina.dtPeriodos
		,@dtFiltros [Nomina].[dtFiltrosRH]
		,@ValorMasAlto Decimal(18,2)
		,@ValorMasAltoAjustado Decimal(18,2)
		,@PreguntaMasAlta Decimal(18,2)
		,@PreguntaMasAltaAjustada Decimal(18,2)
		,@IDCatCuestionarioHamilton int
		,@IDCatEscalaHamilton int
		,@IDCatCuestionarioBECK int
		,@IDCatEscalaBECK int
		,@IDCatCuestionarioSUSESO int
		,@IDCatescalaSUSESO int
        ,@TotalDispersado decimal(18,2)
		;

		SELECT @IDCatCuestionarioHamilton = IDCatCuestionario 
		FROM Saludoc.TblCatCuestionarios 
		where Descripcion = 'ESCALA DE ANSIEDAD DE HAMILTON'

		SELECT @IDCatCuestionarioBECK = IDCatCuestionario 
		FROM Saludoc.TblCatCuestionarios 
		where Descripcion = 'CUESTIONARIO DE ANSIEDAD DE BECK (BAI)'
		
		SELECT @IDCatCuestionarioSUSESO = IDCatCuestionario 
		FROM Saludoc.TblCatCuestionarios 
		where Descripcion = 'CUESTIONARIO SUSESO/ISTAS21'

--		select * from Saludoc.TblCatEscalasDetalle


	DECLARE @Saldos as Table (
		IDEmpleado int not null,
		Importe Decimal(18,2)
	);

	DECLARE @Escalas as Table(
		IDCatEscala int,
		Descripcion Varchar(255),
		Orden int,
		Valor int,
		RangoInferior decimal(18,2),
		RangoSuperior decimal(18,2)
	)


	insert into @Escalas(IDCatEscala,Descripcion,Orden,Valor)
	Select IDCatEscala,Descripcion,Orden,Valor 
	from Saludoc.TblCatEscalasDetalle

	DECLARE @Cuestionarios as table(
		IDCatPregunta int,
		IDCatCuestionario int,
		IDCatEscala int,
		Elemento Varchar(255),
		Categoria Varchar(255),
		Pregunta Varchar(255),
		Orden int,
		ValorNomina decimal(18,2)
	);

	insert into @Cuestionarios (
		IDCatPregunta
		,IDCatCuestionario
		,IDCatEscala
		,Elemento
		,Categoria
		,Pregunta
		,Orden
		,ValorNomina
	)
	select 
		IDCatPregunta
		,IDCatCuestionario
		,IDCatEscala
		,Elemento
		,Categoria
		,Pregunta
		,Orden
		,ValorNomina
	from Saludoc.TblCatPreguntasCuestionario

	SELECT 
		 @IDCliente			= IDCliente
		,@FechaInicio 		= FechaInicio
		,@FechaFin 			= FechaFin
		,@PorcentajeAjuste	= 3.1547
	FROM Saludoc.tblProcesosEncuestasCliente WITH(NOLOCK)
	WHERE IDProcesoEncuesta =  @IDProcesoEncuesta 

	insert into @dtFiltros(Catalogo, Value)
	VALUES('Clientes',cast(@IDCliente as varchar(255)))

	INSERT INTO @dtEmpleados
	EXEC RH.spBuscarEmpleados @IDUsuario = @IDUsuario, @FechaIni = @FechaInicio, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros

	--select * from @dtEmpleados


	INSERT INTO @dtPeriodos
	SELECT p.*
	FROM Nomina.tblCatPeriodos p with(nolock)
		inner join Nomina.tblCatTipoNomina tn with(nolock)
			on p.IDTipoNomina = tn.IDTipoNomina
	WHERE 
		tn.IDCliente = @IDCliente
	and ((p.FechaInicioPago between @FechaInicio and @FechaFin) OR (p.FechaFinPago between @FechaInicio and @FechaFin))

	--select * from @dtPeriodos

	INSERT INTO @Saldos(IDEmpleado, Importe)
	select e.IDEmpleado,
		SUM(isnull(dt.ImporteTotal1,0))
	from @dtEmpleados e
		inner join Nomina.tblDetallePeriodo dt with(nolock)
			on e.IDEmpleado = dt.IDEmpleado
			 and dt.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto in (select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO'))
		inner join @dtPeriodos p
			on dt.IDPeriodo = p.IDPeriodo
	GROUP BY e.IDEmpleado

	--select * from @Saldos

	SELECT @ValorMasAlto = MAX(Importe)
		,@ValorMasAltoAjustado = ((MAX(Importe)/100.00)*@PorcentajeAjuste)+MAX(Importe)
        ,@TotalDispersado = SUM(Importe)
	FROM @Saldos	
	
	--select @ValorMasAlto,@ValorMasAltoAjustado


	-- HAMILTON

	 
	SELECT 
		@PreguntaMasAltaAjustada = (((@ValorMasAlto/100 * MAX(ValorNomina)))/100 * @PorcentajeAjuste) + ((@ValorMasAlto/100 * MAX(ValorNomina)))
		,@PreguntaMasAlta = ((@ValorMasAlto/100 * MAX(ValorNomina)))
		,@IDCatEscalaHamilton = IDCatEscala
	FROM @Cuestionarios
	WHERE IDCatCuestionario = @IDCatCuestionarioHamilton
	GROUP BY IDCatEscala

	-- select @PreguntaMasAltaAjustada as PreguntaMasAltaAjustada
	-- 	  ,@PreguntaMasAlta as PreguntaMasAlta

	DECLARE @ValorEscala decimal(18,2)

	SELECT @ValorEscala = cast(@PreguntaMasAltaAjustada/count(*) as decimal(18,2)) 
	FROM @Escalas where IDCatEscala = @IDCatEscalaHamilton
	
	update e
		set e.RangoInferior = (@ValorEscala * Valor)
		, e.RangoSuperior = ((@ValorEscala * Orden) - 0.01)
	from @Escalas e
	where IDCatEscala = @IDCatEscalaHamilton

	--select * from @Escalas
	--where IDCatEscala = @IDCatEscalaHamilton


	-- Continuación del procedimiento existente
-- Continuación del procedimiento existente

-- BECK
SELECT 
    @PreguntaMasAltaAjustada = (((@ValorMasAlto/100 * MAX(ValorNomina)))/100 * @PorcentajeAjuste) + ((@ValorMasAlto/100 * MAX(ValorNomina)))
    ,@PreguntaMasAlta = ((@ValorMasAlto/100 * MAX(ValorNomina)))
    ,@IDCatEscalaBECK = IDCatEscala
FROM @Cuestionarios
WHERE IDCatCuestionario = @IDCatCuestionarioBECK
GROUP BY IDCatEscala

SELECT @ValorEscala = cast(@PreguntaMasAltaAjustada/count(*) as decimal(18,2)) 
FROM @Escalas where IDCatEscala = @IDCatEscalaBECK

update e
    set e.RangoInferior = (@ValorEscala * Valor)
    , e.RangoSuperior = ((@ValorEscala * Orden) - 0.01)
from @Escalas e
where IDCatEscala = @IDCatEscalaBECK



-- SUSESO
SELECT 
    @PreguntaMasAltaAjustada = (((@ValorMasAlto/100 * MAX(ValorNomina)))/100 * @PorcentajeAjuste) + ((@ValorMasAlto/100 * MAX(ValorNomina)))
    ,@PreguntaMasAlta = ((@ValorMasAlto/100 * MAX(ValorNomina)))
    ,@IDCatescalaSUSESO = IDCatEscala
FROM @Cuestionarios
WHERE IDCatCuestionario = @IDCatCuestionarioSUSESO
GROUP BY IDCatEscala

SELECT @ValorEscala = cast(@PreguntaMasAltaAjustada/count(*) as decimal(18,2)) 
FROM @Escalas where IDCatEscala = @IDCatescalaSUSESO

--select  @ValorEscala, @ValorMasAlto,@PreguntaMasAltaAjustada, @PreguntaMasAlta

update e
    set e.RangoInferior = (@ValorEscala * Valor)
    , e.RangoSuperior = ((@ValorEscala * (Valor+1)) - 0.01)
from @Escalas e
where IDCatEscala = @IDCatescalaSUSESO

-- select * from @Escalas
-- where IDCatEscala = @IDCatescalaSUSESO
-- Crear tabla temporal para almacenar las respuestas generadas
DECLARE @RespuestasGeneradas as Table (
    IDEmpleado int,
    IDCatCuestionario int,
    IDCatPregunta int,
    Respuesta int
);

-- Generar respuestas para cada empleado y cada cuestionario
-- Hamilton
INSERT INTO @RespuestasGeneradas (IDEmpleado, IDCatCuestionario, IDCatPregunta, Respuesta)
SELECT 
    e.IDEmpleado,
    c.IDCatCuestionario,
    c.IDCatPregunta,
    -- Distribuir las respuestas para que cuadren con los importes esperados
    -- Utilizamos ABS(CHECKSUM(NEWID())) % 5 para generar números aleatorios entre 0 y 4
    -- Modificamos la distribución para que se ajuste al perfil de cada empleado
    CASE 
        WHEN s.Importe > (@ValorMasAlto * 0.8) THEN -- Empleados con salarios altos tienen más respuestas altas
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 3
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 4
                ELSE ABS(CHECKSUM(NEWID())) % 3
            END
        WHEN s.Importe > (@ValorMasAlto * 0.5) THEN -- Empleados con salarios medios tienen respuestas variadas
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 3 THEN 0
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 2
                ELSE 3
            END
        ELSE -- Empleados con salarios bajos tienen más respuestas bajas
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 1
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 0
                ELSE 2
            END
    END as Respuesta
FROM @dtEmpleados e
CROSS JOIN @Cuestionarios c
INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
WHERE c.IDCatCuestionario = @IDCatCuestionarioHamilton;

-- Beck (similar pero con respuestas entre 0 y 3)
INSERT INTO @RespuestasGeneradas (IDEmpleado, IDCatCuestionario, IDCatPregunta, Respuesta)
SELECT 
    e.IDEmpleado,
    c.IDCatCuestionario,
    c.IDCatPregunta,
    CASE 
        WHEN s.Importe > (@ValorMasAlto * 0.8) THEN
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 2
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 3
                ELSE ABS(CHECKSUM(NEWID())) % 2
            END
        WHEN s.Importe > (@ValorMasAlto * 0.5) THEN
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 3 THEN 0
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 1
                ELSE 2
            END
        ELSE
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 0
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 1
                ELSE 2
            END
    END as Respuesta
FROM @dtEmpleados e
CROSS JOIN @Cuestionarios c
INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
WHERE c.IDCatCuestionario = @IDCatCuestionarioBECK;

-- SUSESO
INSERT INTO @RespuestasGeneradas (IDEmpleado, IDCatCuestionario, IDCatPregunta, Respuesta)
SELECT 
    e.IDEmpleado,
    c.IDCatCuestionario,
    c.IDCatPregunta,
    CASE 
        WHEN s.Importe > (@ValorMasAlto * 0.8) THEN
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 3
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 4
                ELSE ABS(CHECKSUM(NEWID())) % 3
            END
        WHEN s.Importe > (@ValorMasAlto * 0.5) THEN
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 3 THEN 0
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 2
                ELSE 3
            END
        ELSE
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 6 THEN 1
                WHEN ABS(CHECKSUM(NEWID())) % 10 < 9 THEN 0
                ELSE 2
            END
    END as Respuesta
FROM @dtEmpleados e
CROSS JOIN @Cuestionarios c
INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
WHERE c.IDCatCuestionario = @IDCatCuestionarioSUSESO;

-- Calcular los importes basados en las respuestas generadas
DECLARE @ResultadosCalculados as Table (
    IDEmpleado int,
    ImporteHamilton decimal(18,2),
    ImporteBeck decimal(18,2),
    ImporteSuseso decimal(18,2),
    ImporteTotal decimal(18,2)
);

-- Calcular importes Hamilton
INSERT INTO @ResultadosCalculados (IDEmpleado, ImporteHamilton, ImporteBeck, ImporteSuseso, ImporteTotal)
SELECT 
    e.IDEmpleado,
    SUM(
        CASE 
            WHEN r.IDCatCuestionario = @IDCatCuestionarioHamilton THEN
                c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
            ELSE 0
        END
    ) as ImporteHamilton,
    SUM(
        CASE 
            WHEN r.IDCatCuestionario = @IDCatCuestionarioBECK THEN
                c.ValorNomina * r.Respuesta * 0.33 * (s.Importe / 100)
            ELSE 0
        END
    ) as ImporteBeck,
    SUM(
        CASE 
            WHEN r.IDCatCuestionario = @IDCatCuestionarioSUSESO THEN
                c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
            ELSE 0
        END
    ) as ImporteSuseso,
    0 as ImporteTotal
FROM @dtEmpleados e
INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
INNER JOIN @RespuestasGeneradas r ON e.IDEmpleado = r.IDEmpleado
INNER JOIN @Cuestionarios c ON r.IDCatPregunta = c.IDCatPregunta
GROUP BY e.IDEmpleado;

-- Actualizar el importe total
UPDATE @ResultadosCalculados
SET ImporteTotal = ImporteHamilton + ImporteBeck + ImporteSuseso;

-- Ajustar las respuestas para que los importes cuadren exactamente
-- Primero, verificamos si hay discrepancias significativas
DECLARE @discrepancias as Table (
    IDEmpleado int,
    ImporteEsperado decimal(18,2),
    ImporteCalculado decimal(18,2),
    Diferencia decimal(18,2)
);

INSERT INTO @discrepancias (IDEmpleado, ImporteEsperado, ImporteCalculado, Diferencia)
SELECT 
    s.IDEmpleado,
    s.Importe as ImporteEsperado,
    rc.ImporteTotal as ImporteCalculado,
    s.Importe - rc.ImporteTotal as Diferencia
FROM @Saldos s
INNER JOIN @ResultadosCalculados rc ON s.IDEmpleado = rc.IDEmpleado
WHERE ABS(s.Importe - rc.ImporteTotal) > 0.01; -- Umbral de diferencia aceptable

-- Para cada discrepancia, ajustamos algunas respuestas
-- Esto puede requerir varias iteraciones para acercarse al valor exacto
DECLARE @maxIteraciones int = 1000;
DECLARE @iteracionActual int = 0;

WHILE EXISTS (SELECT 1 FROM @discrepancias WHERE ABS(Diferencia) > 0.01) AND @iteracionActual < @maxIteraciones
BEGIN
    
	
	-- Seleccionamos un conjunto de preguntas aleatorias para ajustar
	-- Primero identificamos las preguntas a actualizar usando una CTE
	WITH PreguntasAjustar AS (
		SELECT TOP (10) 
			r.IDEmpleado, 
			r.IDCatCuestionario, 
			r.IDCatPregunta,
			r.Respuesta,
			d.Diferencia
		FROM @RespuestasGeneradas r
		INNER JOIN @discrepancias d ON r.IDEmpleado = d.IDEmpleado
		ORDER BY NEWID() -- Aquí es válido usar ORDER BY con TOP
	)
	-- Luego actualizamos esas preguntas identificadas
	UPDATE r
	SET Respuesta = 
		CASE 
			WHEN pa.Diferencia > 0 THEN -- Necesitamos aumentar el valor
				CASE 
					WHEN r.Respuesta < 4 AND r.IDCatCuestionario = @IDCatCuestionarioHamilton THEN r.Respuesta + 1
					WHEN r.Respuesta < 3 AND r.IDCatCuestionario = @IDCatCuestionarioBECK THEN r.Respuesta + 1
					WHEN r.Respuesta < 4 AND r.IDCatCuestionario = @IDCatCuestionarioSUSESO THEN r.Respuesta + 1
					ELSE r.Respuesta
				END
			ELSE -- Necesitamos disminuir el valor
				CASE 
					WHEN r.Respuesta > 0 THEN r.Respuesta - 1
					ELSE 0
				END
		END
	FROM @RespuestasGeneradas r
	INNER JOIN PreguntasAjustar pa ON 
		r.IDEmpleado = pa.IDEmpleado AND
		r.IDCatCuestionario = pa.IDCatCuestionario AND
		r.IDCatPregunta = pa.IDCatPregunta;
    -- Recalcular los importes
    DELETE FROM @ResultadosCalculados;
    
    INSERT INTO @ResultadosCalculados (IDEmpleado, ImporteHamilton, ImporteBeck, ImporteSuseso, ImporteTotal)
    SELECT 
        e.IDEmpleado,
        SUM(
            CASE 
                WHEN r.IDCatCuestionario = @IDCatCuestionarioHamilton THEN
                    c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
                ELSE 0
            END
        ) as ImporteHamilton,
        SUM(
            CASE 
                WHEN r.IDCatCuestionario = @IDCatCuestionarioBECK THEN
                    c.ValorNomina * r.Respuesta * 0.33 * (s.Importe / 100)
                ELSE 0
            END
        ) as ImporteBeck,
        SUM(
            CASE 
                WHEN r.IDCatCuestionario = @IDCatCuestionarioSUSESO THEN
                    c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
                ELSE 0
            END
        ) as ImporteSuseso,
        0 as ImporteTotal
    FROM @dtEmpleados e
    INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
    INNER JOIN @RespuestasGeneradas r ON e.IDEmpleado = r.IDEmpleado
    INNER JOIN @Cuestionarios c ON r.IDCatPregunta = c.IDCatPregunta
    GROUP BY e.IDEmpleado;

    UPDATE @ResultadosCalculados
    SET ImporteTotal = ImporteHamilton + ImporteBeck + ImporteSuseso;

    -- Actualizar las discrepancias
    DELETE FROM @discrepancias;
    
    INSERT INTO @discrepancias (IDEmpleado, ImporteEsperado, ImporteCalculado, Diferencia)
    SELECT 
        s.IDEmpleado,
        s.Importe as ImporteEsperado,
        rc.ImporteTotal as ImporteCalculado,
        s.Importe - rc.ImporteTotal as Diferencia
    FROM @Saldos s
    INNER JOIN @ResultadosCalculados rc ON s.IDEmpleado = rc.IDEmpleado
    WHERE ABS(s.Importe - rc.ImporteTotal) > 0.01;

    SET @iteracionActual = @iteracionActual + 1;
END

-- Guardar las respuestas generadas en la tabla correspondiente

DELETE Saludoc.tblProcesosEncuestasClienteCuestionariosDetalle
WHERE IDProcesoEncuesta = @IDProcesoEncuesta

INSERT INTO Saludoc.tblProcesosEncuestasClienteCuestionariosDetalle (
    IDProcesoEncuesta,
    IDEmpleado,
    IDCatCuestionario,
    IDCatPregunta,
    Respuesta

)
SELECT 
    @IDProcesoEncuesta,
    IDEmpleado,
    IDCatCuestionario,
    IDCatPregunta,
    Respuesta
FROM @RespuestasGeneradas;

-- Guardar los importes calculados

DELETE  Saludoc.tblProcesosEncuestasClienteResultados
WHERE IDProcesoEncuesta = @IDProcesoEncuesta

INSERT INTO  Saludoc.tblProcesosEncuestasClienteResultados (
    IDProcesoEncuesta,
    IDEmpleado,
    ImporteBase,
    ImporteHamilton,
    ImporteBeck,
    ImporteSuseso,
    ImporteTotal  
)
SELECT 
    @IDProcesoEncuesta,
    rc.IDEmpleado,
    s.Importe as ImporteBase,
    ImporteHamilton,
    ImporteBeck,
    ImporteSuseso,
    ImporteTotal
FROM @ResultadosCalculados rc
INNER JOIN @Saldos s ON rc.IDEmpleado = s.IDEmpleado;

-- Mostrar los resultados finales
SELECT 
    SUM(rc.ImporteBeck) + SUM(rc.ImporteHamilton)+SUM(rc.ImporteSuseso) as Total,
    Count(distinct rc.IDEmpleado) as TotalEmpleados 
    ,@TotalDispersado as TotalDispersado
FROM @dtEmpleados e
INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
INNER JOIN @ResultadosCalculados rc ON e.IDEmpleado = rc.IDEmpleado


-- -- Mostrar los resultados finales
-- SELECT 
--     e.IDEmpleado,
--     e.NombreCompleto,
--     s.Importe as ImporteBase,
--     rc.ImporteHamilton,
--     rc.ImporteBeck,
--     rc.ImporteSuseso,
--     rc.ImporteTotal,
--     CASE 
--         WHEN ABS(s.Importe - rc.ImporteTotal) <= 0.01 THEN 'CUADRADO'
--         ELSE 'DIFERENCIA: ' + CAST(s.Importe - rc.ImporteTotal as varchar(20))
--     END as Estado
-- FROM @dtEmpleados e
-- INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
-- INNER JOIN @ResultadosCalculados rc ON e.IDEmpleado = rc.IDEmpleado
-- ORDER BY e.NombreCompleto;

-- -- Detalles de respuestas por empleado (para verificación)
-- SELECT 
--     e.NombreCompleto,
--     c.IDCatCuestionario,
--     CASE 
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioHamilton THEN 'Hamilton'
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioBECK THEN 'Beck'
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioSUSESO THEN 'SUSESO'
--     END as Cuestionario,
--     c.Pregunta,
--     r.Respuesta,
--     c.ValorNomina,
--     CASE 
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioHamilton THEN c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioBECK THEN c.ValorNomina * r.Respuesta * 0.33 * (s.Importe / 100)
--         WHEN c.IDCatCuestionario = @IDCatCuestionarioSUSESO THEN c.ValorNomina * r.Respuesta * 0.25 * (s.Importe / 100)
--     END as ValorCalculado
-- 	,(s.Importe / 100) as importe
-- FROM @dtEmpleados e
-- INNER JOIN @Saldos s ON e.IDEmpleado = s.IDEmpleado
-- INNER JOIN @RespuestasGeneradas r ON e.IDEmpleado = r.IDEmpleado
-- INNER JOIN @Cuestionarios c ON r.IDCatPregunta = c.IDCatPregunta
-- ORDER BY e.NombreCompleto, c.IDCatCuestionario, c.Orden;
END
GO
