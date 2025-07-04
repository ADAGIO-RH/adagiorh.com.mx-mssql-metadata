USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCalculoAumentoMasivo](
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @dtIDEmpleados [RH].[dtIDEmpleados]  READONLY,
    @IDAumentoMasivo INT,
    @Aplicar BIT = 0,
    @IDUsuario INT
)
AS

    DECLARE
        @Ejercicio int
       ,@IDTipoAumentoMasivo int
       ,@IDEstatusAumentoMasivo int       
       ,@IDRazonMovimiento int
       ,@FechaAplicacionMov date
       ,@RespetarSalarioVariable bit
       ,@AfectaSalarioDiario  bit
       ,@AfectaSalarioDiarioReal bit
       ,@ValorAumento decimal (18,6);
    
    ---Constantes
    DECLARE
        @ID_TIPO_MOV_AFILIATORIO_MOV_SALARIO INT = 4
       ,@ID_TIPO_MOV_AFILIATORIO_BAJA INT = 2
       ,@ID_TIPO_AUMENTO_MASIVO_AUMENTO_SALARIO_MINIMO INT = 1
       ,@ID_TIPO_AUMENTO_MASIVO_AUMENTO_POR_PORCENTAJE INT = 2
       ,@ID_TIPO_AUMENTO_MASIVO_AUMENTO_POR_MONTO INT = 3

    
    DECLARE 
        @empleadosInformacionActual RH.dtEmpleados
       ,@FechaHoy date = GETDATE() 
       ,@Conjuncion varchar(3) = 'AND'
       ,@i int
       ,@dttempFiltros [Nomina].[dtFiltrosRH]    
       ,@SalarioMinimo decimal(18,2)
       ,@SalarioMinimoFronterizo decimal(18,2)           
       ,@UMA decimal(10,2)
       ,@UMATOPADA decimal(10,2);
       ;
       
    
    if object_id('tempdb..#tempFiltrosIterable') is not null drop table #tempFiltrosIterable;
    if object_id('tempdb..#tempCalculosPreviosAumento') is not null drop table #tempCalculosPreviosAumento;
    if object_id('tempdb..#tempCalculoAumentoSalarialAplicable') is not null drop table #tempCalculoAumentoSalarialAplicable;
    if object_id('tempdb..#tempMovimientosAfiliatoriosGenerados') is not null drop table #tempMovimientosAfiliatoriosGenerados;
    
    CREATE TABLE #tempCalculosPreviosAumento(
        IDEmpleado        INT
       ,SalarioDiario     DECIMAL(18,2)
       ,SalarioVariable   DECIMAL(18,2)
       ,SalarioDiarioReal DECIMAL (18,2)
    )
    CREATE TABLE #tempMovimientosAfiliatoriosGenerados(
        IDEmpleado        INT
       ,IDMovAfiliatorio INT
    )
    


    
     SELECT
        @Ejercicio=Ejercicio
       ,@IDTipoAumentoMasivo= IDTipoAumentoMasivo
       , @IDEstatusAumentoMasivo= IDEstatusAumentoMasivo 
       , @IDRazonMovimiento = IDRazonMovimiento
       , @FechaAplicacionMov = FechaAplicacionMov
       , @RespetarSalarioVariable = ISNULL(RespetarSalarioVariable,1)
       , @AfectaSalarioDiario  = ISNULL(AfectaSalarioDiario,1)
       , @AfectaSalarioDiarioReal = ISNULL(AfectaSalarioDiarioReal,0)
       , @ValorAumento = ValorAumento
    FROM Nomina.tblAumentoMasivo
    WHERE IDAumentoMasivo=@IDAumentoMasivo

    SELECT top 1 @UMA=UMA FROM Nomina.tblSalariosMinimos WHERE DATEPART(YEAR,Fecha)=@Ejercicio ORDER BY Fecha DESC
    set @UMATOPADA=@UMA*25

     IF(@UMA = 0)
     BEGIN
        raiserror('El valor de la UMA en el catálogo de Nómina y Seguridad Social/UMA,Salario Mínimo y Tope debe ser mayor a 0',16,1);  
		return;
     END
	


    IF EXISTS (SELECT 1 FROM @dtIDEmpleados)
    BEGIN
       

        INSERT INTO @empleadosInformacionActual
        SELECT EM.* 
        FROM @dtIDEmpleados E
            INNER JOIN RH.tblEmpleadosMaster EM
                ON E.IDEmpleado=EM.IDEmpleado                
        
    END
    ELSE
    BEGIN
       SELECT @Conjuncion = [Value] FROM @dtFiltros WHERE Catalogo= 'Conjuncion' 
        IF @Conjuncion = 'AND'
        BEGIN             
            INSERT INTO @empleadosInformacionActual
            EXEC [RH].[spBuscarEmpleadosMaster]
                @FechaIni	= @FechaHoy
                ,@Fechafin	= @FechaHoy 
                ,@IDUsuario	= @IDUsuario
                ,@dtFiltros = @dtFiltros   
        END
        ELSE
        BEGIN
            
            SELECT *,ROW_NUMBER()OVER( ORDER BY (SELECT NULL)) AS RN
            INTO #tempFiltrosIterable
            FROM @dtFiltros
            WHERE ((Catalogo <> 'Excluir Empleado' and Catalogo <> 'Conjuncion' ))  and Catalogo <>'search'  

            SELECT @i = MIN(RN) FROM #tempFiltrosIterable
            ---Comienza ciclo para enviar a proc spBuscarEmpleadosMaster filtros por separado
            WHILE EXISTS(SELECT TOP 1 1 FROM #tempFiltrosIterable WHERE RN >= @i)
            BEGIN
                DELETE FROM @dttempFiltros;
                
                INSERT INTO @dttempFiltros (Catalogo,Value)
                SELECT Catalogo, Value
                FROM #tempFiltrosIterable
                WHERE RN = @i

                

                INSERT INTO @dttempFiltros (Catalogo,Value) values ('Conjuncion','AND')


                INSERT INTO @empleadosInformacionActual
                exec [RH].[spBuscarEmpleadosMaster]
                    @FechaIni	= @FechaHoy
                    ,@Fechafin	= @FechaHoy 
                    ,@IDUsuario	= @IDUsuario
                    ,@dtFiltros = @dttempFiltros

                
                SELECT @i = min(RN)
                FROM #tempFiltrosIterable
                WHERE RN > @i
            END
        END
        
    END
    
    IF EXISTS(SELECT TOP 1 1 FROM @dtFiltros WHERE Catalogo = 'Solo Vigentes')
    BEGIN
        DECLARE @SoloVigente bit =0; 

        SELECT @SoloVigente=Value 
        FROM @dtFiltros WHERE Catalogo ='Solo Vigentes'
        
        
        DELETE @empleadosInformacionActual
        WHERE  Vigente<>@SoloVigente

    END

    DECLARE @validacionFiltros INT 
    SELECT @validacionFiltros=count(*) FROM @dtFiltros  WHERE Catalogo <>'search'                
    
    IF EXISTS(SELECT TOP 1 1 FROM @dtFiltros WHERE Catalogo = 'Excluir Empleado'  and @validacionFiltros >1) 
    BEGIN
        DELETE @empleadosInformacionActual
        WHERE  IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Excluir Empleado'),','))                
    END;
    
    WITH TempEmp (IDEmpleado,duplicateRecCount)
    AS
    (
        SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) 
        AS duplicateRecCount
        FROM @empleadosInformacionActual
    )
    --Now Delete Duplicate Records
    DELETE FROM TempEmp
    WHERE duplicateRecCount > 1 ;                  

    
    ---Aumento de Salario Minimo
    IF(@IDTipoAumentoMasivo = @ID_TIPO_AUMENTO_MASIVO_AUMENTO_SALARIO_MINIMO )
    BEGIN
                        
        SELECT @SalarioMinimo=ISNULL(SalarioMinimo,0.00),
            @SalarioMinimoFronterizo=ISNULL(SalarioMinimoFronterizo,0.00)
        FROM Nomina.tblSalariosMinimos with (nolock)
        WHERE IDSalarioMinimo=CAST(@ValorAumento AS int)

        IF (@SalarioMinimo = 0 OR @SalarioMinimoFronterizo=0 )
        BEGIN
            raiserror('El valor del salario mínimo en el catálogo de Nómina y Seguridad Social/UMA,Salario Mínimo y Tope debe ser mayor a 0',16,1);  
            return;
        END

        DELETE FROM #tempCalculosPreviosAumento        

        INSERT  INTO #tempCalculosPreviosAumento
        SELECT  
            E.IDEmpleado
           ,CASE WHEN ISNULL(CATSUC.Fronterizo,0)=0 
                 THEN @SalarioMinimo 
                 ELSE @SalarioMinimoFronterizo END AS SalarioDiario  
           ,CASE WHEN @RespetarSalarioVariable=1 
                 THEN E.SalarioVariable 
                 ELSE 0 END AS SalarioVariable
           ,E.SalarioDiarioReal AS SalarioDiarioReal      
        FROM @empleadosInformacionActual E
             LEFT JOIN RH.tblCatSucursales CATSUC with (nolock)
                ON CATSUC.IDSucursal=E.IDSucursal
        WHERE E.SalarioDiario<CASE WHEN ISNULL(CATSUC.Fronterizo,0)=0 THEN @SalarioMinimo ELSE @SalarioMinimoFronterizo END---Nos quedamos solamente con los empleados que ganan el minimo
                        
    END
    ---Aumento de Salario por Porcentaje
    ELSE IF(@IDTipoAumentoMasivo = @ID_TIPO_AUMENTO_MASIVO_AUMENTO_POR_PORCENTAJE)
    BEGIN    
        
        IF (@ValorAumento<=0)
        BEGIN
            raiserror('El porcentaje configurado en el aumento no es valido, debe ser mayor a 0%',16,1);  
            return;
        END

        SET @ValorAumento = @ValorAumento/100
        

       DELETE #tempCalculosPreviosAumento 
       
       INSERT INTO #tempCalculosPreviosAumento       
       SELECT  
            E.IDEmpleado
           ,CASE WHEN @AfectaSalarioDiario=1 
                      THEN E.SalarioDiario * (1+@ValorAumento) 
                      ELSE E.SalarioDiario END AS SalarioDiario           
           ,CASE WHEN @RespetarSalarioVariable=1 
                      THEN E.SalarioVariable 
                      ELSE 0 END AS SalarioVariable  
           ,CASE WHEN @AfectaSalarioDiarioReal=1
                      THEN E.SalarioDiarioReal * (1+@ValorAumento) 
                      else E.SalarioDiarioReal END AS SalarioDiarioReal
        FROM @empleadosInformacionActual E
        
                         
    END
    ----Aumento de Salario por Monto
    ELSE IF(@IDTipoAumentoMasivo = @ID_TIPO_AUMENTO_MASIVO_AUMENTO_POR_MONTO)
    BEGIN    
        
        IF (@ValorAumento<=0)
        BEGIN
            raiserror('El monto configurado en el aumento no es valido, debe ser mayor a $0.00',16,1);  
            return;
        END
        

       DELETE #tempCalculosPreviosAumento 
       
       INSERT INTO #tempCalculosPreviosAumento       
       SELECT  
            E.IDEmpleado
           ,CASE WHEN @AfectaSalarioDiario=1 
                      THEN E.SalarioDiario + @ValorAumento 
                      ELSE E.SalarioDiario END AS SalarioDiario           
           ,CASE WHEN @RespetarSalarioVariable=1 
                      THEN E.SalarioVariable 
                      ELSE 0 END AS SalarioVariable  
           ,CASE WHEN @AfectaSalarioDiarioReal=1
                      THEN E.SalarioDiarioReal + @ValorAumento
                      else E.SalarioDiarioReal END AS SalarioDiarioReal
        FROM @empleadosInformacionActual E
        
        
    END

     
    SELECT     
    e.IDEmpleado
    ,e.ClaveEmpleado
    ,e.NOMBRECOMPLETO
    ,TPD.IDTipoPrestacion
    ,e.FechaAntiguedad
    ,CalculoPrevio.SalarioDiario
    ,CalculoPrevio.SalarioVariable
    ,ISNULL(
            CASE WHEN ((CalculoPrevio.SalarioDiario * tpd.Factor) + CalculoPrevio.SalarioVariable)>=@UMATOPADA 
                       THEN @UMATOPADA        
                       ELSE (CalculoPrevio.SalarioDiario * tpd.Factor) + CalculoPrevio.SalarioVariable END
            ,0) AS SalarioIntegrado    
    ,CalculoPrevio.SalarioDiarioReal
    ,E.SalarioDiario as SalarioDiarioAnterior
    ,E.SalarioVariable as SalarioVariableAnterior
    ,E.SalarioIntegrado as SalarioIntegradoAnterior
    ,E.SalarioDiarioReal as SalarioDiarioRealAnterior
    ,ISNULL(TPD.FACTOR,0) as FactorIntegracion
    ,E.IDRegPatronal
    ,RP.RegistroPatronal 
    ,ISNULL(FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaAplicacionMov)/365.0)+1,0) AS Antiguedad
    ,CASE WHEN AME.IDAumentoMasivo IS NOT NULL THEN 'ºEl colaborador ya fue afectado anteriormente en este mismo Aumento Masivo. \n' ELSE '' END
    +CASE WHEN MOV.IDMovAfiliatorio IS NOT NULL THEN 'ºEl colaborador cuenta con un movimiento afiliatorio la fecha de la aplicación. \n' ELSE '' END
    +CASE WHEN UltimoMov.IDMovAfiliatorio IS NOT NULL THEN 'ºEl ultimo movimiento afiliatorio del colaborador es una baja. \n' ELSE '' END     
    +CASE WHEN TPD.IDTipoPrestacion IS NULL THEN 'ºEl colaborador no cuenta con una prestación o esta no cuenta con detalles para su atiguedad.\n' ELSE '' END  
    +CASE WHEN RP.IDRegPatronal IS NULL THEN 'ºEl colaborador no pertenece a ningun registro patronal. \n' ELSE '' END  
    AS MensajesDeError
    ,CASE WHEN (   AME.IDAumentoMasivo IS NOT NULL 
                OR MOV.IDMovAfiliatorio IS NOT NULL
                OR UltimoMov.IDMovAfiliatorio IS NOT NULL
                OR TPD.IDTipoPrestacion IS NULL
                OR RP.IDRegPatronal IS NULL
               ) THEN 1 ELSE 0 END AS Error
    INTO #tempCalculoAumentoSalarialAplicable
    FROM @empleadosInformacionActual E 
        INNER JOIN #tempCalculosPreviosAumento CalculoPrevio
            ON CalculoPrevio.IDEmpleado = E.IDEmpleado
        LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
            ON  TPD.IDTipoPrestacion = E.IDTipoPrestacion
            -- and (tpd.Antiguedad = FLOOR(DATEDIFF(day,E.FechaAntiguedad,GETDATE())/365.0)+1)
            AND (tpd.Antiguedad = FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaAplicacionMov)/365.0)+1)                
        LEFT JOIN RH.tblCatRegPatronal RP 
            ON RP.IDRegPatronal=E.IDRegPatronal
        LEFT JOIN RH.tblCatSucursales CATSUC
            ON CATSUC.IDSucursal=E.IDSucursal
        LEFT JOIN Nomina.tblAumentoMasivoEmpleado AME
            ON AME.IDAumentoMasivo=@IDAumentoMasivo
            AND AME.IDEmpleado=E.IDEmpleado
        LEFT JOIN IMSS.tblMovAfiliatorios MOV
            ON E.IDEmpleado=MOV.IDEmpleado
            AND MOV.Fecha=@FechaAplicacionMov
        LEFT JOIN (
            SELECT INFO.* 
            FROM (    
                SELECT 
                ROW_NUMBER() OVER(PARTITION BY IDEmpleado ORDER BY Fecha DESC, IDMovAfiliatorio) AS DIV
                ,*
                FROM IMSS.tblMovAfiliatorios WITH (nolock)
            ) AS INFO
            WHERE DIV=1 
        ) AS UltimoMov 
            ON UltimoMov.IDEmpleado=E.IDEmpleado 
            AND UltimoMov.IDTipoMovimiento=@ID_TIPO_MOV_AFILIATORIO_BAJA

    BEGIN TRANSACTION;

    IF (ISNULL(@Aplicar, 0) = 1)
    BEGIN
        BEGIN
            INSERT INTO IMSS.tblMovAfiliatorios (
                Fecha,
                IDEmpleado,
                IDTipoMovimiento,
                IDRazonMovimiento,
                SalarioDiario,
                SalarioIntegrado,
                SalarioVariable,
                SalarioDiarioReal,
                IDRegPatronal,
                IDTipoPrestacion,
                FechaAntiguedad

            )
            OUTPUT INSERTED.IDEmpleado, INSERTED.IDMovAfiliatorio INTO #tempMovimientosAfiliatoriosGenerados (IDEmpleado, IDMovAfiliatorio)
            SELECT 
                @FechaAplicacionMov,
                IDEmpleado,
                @ID_TIPO_MOV_AFILIATORIO_MOV_SALARIO,
                @IDRazonMovimiento,
                CAST(SalarioDiario AS DECIMAL(18,2)) SalarioDiario,
                CAST(SalarioIntegrado AS DECIMAL(18,2)) SalarioIntegrado,
                CAST(SalarioVariable AS DECIMAL(18,2)) SalarioVariable,
                CAST(SalarioDiarioReal AS DECIMAL(18,2)) SalarioDiarioReal,
                IDRegPatronal,
                IDTipoPrestacion,
                FechaAntiguedad
            FROM #tempCalculoAumentoSalarialAplicable SOURCE 
            WHERE
                NOT EXISTS (
                    SELECT 1
                    FROM IMSS.tblMovAfiliatorios TARGET
                    WHERE @FechaAplicacionMov = TARGET.Fecha
                        AND SOURCE.IDEmpleado = TARGET.IDEmpleado
                        AND (CAST(SOURCE.SalarioDiario AS DECIMAL(18,2)) = CAST(TARGET.SalarioDiario AS DECIMAL(18,2)))
                        AND (CAST(SOURCE.SalarioIntegrado AS DECIMAL(18,2)) = CAST(TARGET.SalarioIntegrado AS DECIMAL(18,2)))
                        AND (CAST(SOURCE.SalarioVariable AS DECIMAL(18,2)) = CAST(TARGET.SalarioVariable AS DECIMAL(18,2)))
                        AND (CAST(SOURCE.SalarioDiarioReal AS DECIMAL(18,2)) = CAST(TARGET.SalarioDiarioReal AS DECIMAL(18,2)))
                        AND SOURCE.IDRegPatronal = TARGET.IDRegPatronal
                ) 
                AND SOURCE.Error = 0;

            IF EXISTS (SELECT TOP 1 1 FROM #tempMovimientosAfiliatoriosGenerados)
            BEGIN
                INSERT INTO NOMINA.tblAumentoMasivoEmpleado
                SELECT 
                    @IDAumentoMasivo AS IDAumentoMasivo,
                    MovAfiliatorios.IDEmpleado,
                    MovAfiliatorios.SalarioDiario,
                    MovAfiliatorios.SalarioIntegrado,
                    MovAfiliatorios.SalarioVariable,
                    MovAfiliatorios.SalarioDiarioReal,
                    MovAfiliatorios.IDRegPatronal,
                    MovAfiliatorios.IDMovAfiliatorio                                 
                FROM IMSS.tblMovAfiliatorios MovAfiliatorios
                INNER JOIN #tempMovimientosAfiliatoriosGenerados movAfiliatoriosGenerados
                    ON movAfiliatoriosGenerados.IDEmpleado = MovAfiliatorios.IDEmpleado
                    AND movAfiliatoriosGenerados.IDMovAfiliatorio = MovAfiliatorios.IDMovAfiliatorio
                LEFT JOIN Nomina.tblAumentoMasivoEmpleado AumentoMasivoEmpleado
                    ON AumentoMasivoEmpleado.IDAumentoMasivo = @IDAumentoMasivo
                    AND AumentoMasivoEmpleado.IDEmpleado = MovAfiliatorios.IDEmpleado
                WHERE AumentoMasivoEmpleado.IDAumentoMasivo IS NULL;

                EXEC [RH].[spSincronizarEmpleadosMaster]
            END
        END
    END
    
    IF @@ERROR <> 0
        ROLLBACK;
    ELSE
        COMMIT;


    SELECT * 
    FROM #tempCalculoAumentoSalarialAplicable
    ORDER BY Error desc
GO
