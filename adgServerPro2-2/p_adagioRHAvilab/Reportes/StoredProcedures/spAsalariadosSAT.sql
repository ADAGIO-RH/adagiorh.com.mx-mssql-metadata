USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spAsalariadosSAT] (
   @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
   @IDUsuario INT
)
AS
BEGIN
    DECLARE  
        @IDIdioma VARCHAR(5),        
        @IdiomaSQL VARCHAR(100) = NULL;
    
    SELECT TOP 1 @IDIdioma = dp.Valor
    FROM Seguridad.tblUsuarios u WITH (NOLOCK)       
        INNER JOIN App.tblPreferencias p WITH (NOLOCK) ON u.IDPreferencia = p.IDPreferencia        
        INNER JOIN App.tblDetallePreferencias dp WITH (NOLOCK) ON dp.IDPreferencia = p.IDPreferencia        
        INNER JOIN App.tblCatTiposPreferencias tp WITH (NOLOCK) ON tp.IDTipoPreferencia = dp.IDTipoPreferencia        
    WHERE u.IDUsuario = @IDUsuario AND tp.TipoPreferencia = 'IDIOMA';
        
    SELECT @IdiomaSQL = [SQL] FROM app.tblIdiomas WITH (NOLOCK) WHERE IDIdioma = @IDIdioma;        
        
    IF (@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)        
    BEGIN        
        SET @IdiomaSQL = 'SPANISH';        
    END;        
          
    SET LANGUAGE @IdiomaSQL;   

    DECLARE @dtEmpleados [RH].[dtEmpleados],
            @IDTipoNomina INT,
            @IDTipoVigente INT,
            @Titulo VARCHAR(MAX),
            @FechaIni DATE,
            @FechaFin DATE,
            @ClaveEmpleadoInicial VARCHAR(255),
            @ClaveEmpleadoFinal VARCHAR(255),
            @TipoNomina VARCHAR(MAX),
			@TipoRotacion VARCHAR(MAX);

    SELECT @TipoNomina = CASE WHEN ISNULL(Value, '') = '' THEN '0' ELSE Value END
    FROM @dtFiltros WHERE Catalogo = 'TIPONOMINA';

    SELECT @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value, '') = '' THEN '0' ELSE Value END
    FROM @dtFiltros WHERE Catalogo = 'CLAVEEMPLEADOINICIAL';

    SELECT @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value, '') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE Value END
    FROM @dtFiltros WHERE Catalogo = 'CLAVEEMPLEADOINICIAL';

    SELECT @FechaIni = CAST(CASE WHEN ISNULL(Value, '') = '' THEN '1900-01-01' ELSE Value END AS DATE)
    FROM @dtFiltros WHERE Catalogo = 'FECHAINI';

    SELECT @FechaFin = CAST(CASE WHEN ISNULL(Value, '') = '' THEN '9999-12-31' ELSE Value END AS DATE)
    FROM @dtFiltros WHERE Catalogo = 'FECHAFIN';

    SELECT @TipoRotacion = CASE WHEN ISNULL(Value, '') = '' THEN '0' ELSE Value END
    FROM @dtFiltros WHERE Catalogo = 'TIPOROTACION';

--	SELECT @TipoRotacion = TRY_CAST(NULLIF(Value, '') AS INT) 
--FROM @dtFiltros 
--WHERE Catalogo = 'TIPOROTACION';

    SET @IDTipoNomina = (SELECT TOP 1 CAST(ITEM AS INT) FROM App.Split(ISNULL((SELECT Value FROM @dtFiltros WHERE Catalogo = 'TIPONOMINA'), '0'), ','));
    SET @IDTipoVigente = (SELECT TOP 1 CAST(ITEM AS INT) FROM App.Split(ISNULL((SELECT Value FROM @dtFiltros WHERE Catalogo = 'TIPOVIGENTE'), '1'), ','));

    INSERT INTO @dtEmpleados
    EXEC [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,
                                  @EmpleadoIni = @ClaveEmpleadoInicial,
                                  @EmpleadoFin = @ClaveEmpleadoFinal,
                                  @FechaIni = @FechaIni, 
                                  @FechaFin = @FechaFin, 
                                  @dtFiltros = @dtFiltros,
                                  @IDUsuario = @IDUsuario;

    WITH MovimientosUnicos AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY IDEmpleado ORDER BY Fecha DESC) AS rn
    FROM imss.tblMovAfiliatorios
	)
	SELECT 
    UPPER(CONCAT(
        --RIGHT('0000000000000' + EMP.RFC, 13), '|',
        RIGHT('000000000000000000' + M.CURP, 18), '|',
        M.PATERNO, '|',
        ISNULL(M.MATERNO, ''), '|',
        CASE 
            WHEN M.SEGUNDONOMBRE IS NOT NULL THEN CONCAT(M.NOMBRE, ' ', M.SEGUNDONOMBRE)
            ELSE M.NOMBRE
        END, '|',
        FORMAT(M.FECHAANTIGUEDAD, 'dd/MM/yyyy'), '|',
        CASE 
            WHEN tm.IDTipoMovimiento = 2 THEN 1  
            WHEN tm.IDTipoMovimiento IN (1,3) THEN 2  
            ELSE 1  
        END, '|',
        RIGHT('0000000000000' + EMP.RFC, 13), '|',
		
		CEM1.Value, '|', 
         COALESCE(CEM4.Value, CRG.Telefono), '|',
		  --STUFF((
    --        SELECT '-' + SUBSTRING(COALESCE(CEM4.Value, CRG.Telefono), Number, 2)
    --        FROM master..spt_values 
    --        WHERE Type = 'P' 
    --        AND Number BETWEEN 1 AND LEN(COALESCE(CEM4.Value, CRG.Telefono))
    --        AND Number % 2 = 1
    --        FOR XML PATH(''), TYPE
    --    ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '|',


		--	cem.Value, '|',
		--CASE
		--	WHEN cem.IDTipoContactoEmpleado = 4 THEN Value
		--	ELSE 4
		--	END, '|',

		/*|DESCOMENTAR EN DADO CASO DE QUE ALGUN COLABORADOR SI APLIQUE A ALGUNA DE LAS CONDICIONES | POR EL MOMENTO SE DEJARA FIJO CON EL 2|*/

        --CASE 
 --   WHEN M.SalarioDiario > 400000 AND RF.idregimenfiscal = 605 THEN 1  
 --   -- Asalariados con ingresos mayores a $400,000.00

 --   WHEN M.SalarioDiario <= 400000 AND RF.idregimenfiscal = 605  THEN 2  
 --   -- Asalariados con ingresos menores o iguales a $400,000.00

 --   WHEN M.SalarioDiario > 400000 AND M.SalarioDiario <= 75000000 AND RF.idregimenfiscal IN (621, 607, 615)   THEN 3  
 --   -- Asimilables a salarios con ingresos entre $400,000.00 y $75,000,000.00

 --   WHEN M.SalarioDiario <= 400000 AND RF.idregimenfiscal IN (621, 607, 615)  THEN 4  
 --   -- Asimilables a salarios con ingresos menores o iguales a $400,000.00

 --   WHEN M.SalarioDiario > 400000 AND RF.idregimenfiscal IN (612, 622, 626)  THEN 5  
 --   -- Ingresos por actividades empresariales asimilables a salarios con ingresos mayores a $400,000.00

 --   WHEN M.SalarioDiario <= 400000 AND RF.idregimenfiscal IN (612, 622, 626) THEN 6  
 --   -- Ingresos por actividades empresariales asimilables a salarios con ingresos menores o iguales a $400,000.00
	--else 

	2 -- Marca del indicador de los Ingresos del asalariado deacuerdo a los valores siguientes (únicamente pueden ser los valores 1, 2, 3,4, 5 o 6)
    --END


    )) AS REGISTRO
	FROM @dtEmpleados M
		INNER JOIN RH.tblEmpleadosMaster MAST WITH (NOLOCK) ON M.IDEmpleado = MAST.IDEmpleado
		LEFT JOIN RH.tblEmpresa EMP ON EMP.IdEmpresa = M.IDEmpresa
		LEFT JOIN MovimientosUnicos movi ON m.IDEmpleado = movi.IDEmpleado AND movi.rn = 1
	LEFT JOIN imss.tblCatTipoMovimientos tm ON tm.IDTipoMovimiento = movi.IDTipoMovimiento
	left join rh.tblempleados em on em.idempleado = mast.IDEmpleado
	LEFT JOIN sat.tblCatRegimenesFiscales rf on em.idregimenfiscal = rf.IDRegimenFiscal
	LEFT JOIN (
    SELECT IDEmpleado, Value
    FROM (
        SELECT IDEmpleado, Value, 
               ROW_NUMBER() OVER (PARTITION BY IDEmpleado ORDER BY IDTipoContactoEmpleado) AS rn
        FROM RH.tblContactoEmpleado 
        WHERE IDTipoContactoEmpleado IN (4, 13, 14)
    ) AS Sub
    WHERE rn = 1
) AS CEM4 ON CEM4.IDEmpleado = MAST.IDEmpleado

	LEFT JOIN RH.tblContactoEmpleado CEM1 
    ON CEM1.IDEmpleado = MAST.IDEmpleado 
    AND CEM1.IDTipoContactoEmpleado = 1

		LEFT JOIN RH.tblCatRegPatronal CRG
		ON CRG.IDRegPatronal = MAST.IDRegPatronal
--WHERE   
--(@TipoRotacion IS NULL OR tm.IDTipoMovimiento = @TipoRotacion)
--AND
--(@TipoRotacion IS NULL OR 
-- @TipoRotacion = 3 OR
-- tm.IDTipoMovimiento = CASE 
--                         WHEN @TipoRotacion = 1 THEN 1
--                         WHEN @TipoRotacion = 2 THEN 2
--                         ELSE tm.IDTipoMovimiento
--                       END)
ORDER BY M.NOMBRECOMPLETO ASC
END
GO
