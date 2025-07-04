USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCambiarEstatusControlBonosObjetivos]
    @IDControlBonosObjetivos INT,
    @Aplicar BIT = 0,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @EstatusActual BIT,
        @IDPeriodoPagoBono INT = 0,
        @IDPeriodoPagoComplemento INT = 0,
        @IDConceptoPagoComplemento INT = 0,
        @IDConceptoPagoBono INT = 0
        ;


    SELECT @IDPeriodoPagoBono = ISNULL(IDPeriodoBono,0)
          ,@IDPeriodoPagoComplemento = ISNULL(IDPeriodoComplemento,0)
          ,@IDConceptoPagoBono = ISNULL(IDConceptoBono,0)
          ,@IDConceptoPagoComplemento = ISNULL(IDConceptoComplemento,0)
    FROM Nomina.tblControlBonosObjetivos 
     WHERE IDControlBonosObjetivos=@IDControlBonosObjetivos

         
    -- Obtener estatus actual del control
    SELECT 
        @EstatusActual = Aplicado
    FROM Nomina.tblControlBonosObjetivos
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

    -- Validaciones
    IF @Aplicar = 1 AND @Aplicar = @EstatusActual
    BEGIN
        RAISERROR('No se puede aplicar un cálculo que ya fue aplicado', 16, 1);
        RETURN;
    END

    IF @Aplicar = 0 AND @Aplicar = @EstatusActual
    BEGIN
        RAISERROR('No se puede desaplicar un cálculo que no ha sido aplicado', 16, 1);
        RETURN;
    END


    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Aplicar = 1
        BEGIN
            
            IF(@IDConceptoPagoBono <> 0)
            BEGIN
               IF(@IDPeriodoPagoBono = 0)
               BEGIN
                   RAISERROR('No se puede aplicar un cálculo que no tiene un periodo de pago de bono', 16, 1);
                   RETURN;
               END
               IF EXISTS(SELECT TOP 1 1 FROM Nomina.tblCatPeriodos WHERE IDPeriodo = @IDPeriodoPagoBono AND Cerrado = 1)
               BEGIN
                   RAISERROR('El periodo de pago de bono ya está cerrado', 16, 1);
                   RETURN;
               END

               MERGE Nomina.tblDetallePeriodo AS TARGET
               USING (
                   SELECT 
                       D.IDEmpleado,
                       D.IDControlBonosObjetivosDetalle,
                       CASE WHEN D.CalibracionBonoFinal = -1 THEN 0
                            WHEN D.CalibracionBonoFinal > 0 THEN D.CalibracionBonoFinal 
                            ELSE D.BonoFinal
                       END AS Monto
                   FROM Nomina.tblControlBonosObjetivosDetalle D
                   WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos 
                   AND ExcluirColaborador <> -1
                   AND (CASE WHEN D.CalibracionBonoFinal = -1 THEN 0
                            WHEN D.CalibracionBonoFinal > 0 THEN D.CalibracionBonoFinal 
                            ELSE D.BonoFinal
                       END) > 0
               ) AS SOURCE
               ON TARGET.IDPeriodo = @IDPeriodoPagoBono
                   AND TARGET.IDConcepto = @IDConceptoPagoBono
                   AND TARGET.IDEmpleado = SOURCE.IDEmpleado
               WHEN MATCHED THEN
                   UPDATE
                       SET TARGET.CantidadMonto = ISNULL(SOURCE.Monto, 0)
                          ,TARGET.IDReferencia = SOURCE.IDControlBonosObjetivosDetalle
               WHEN NOT MATCHED BY TARGET THEN 
                   INSERT(IDEmpleado, IDPeriodo, IDConcepto, CantidadMonto, IDReferencia)  
                   VALUES(SOURCE.IDEmpleado, @IDPeriodoPagoBono, @IDConceptoPagoBono, ISNULL(SOURCE.Monto, 0), SOURCE.IDControlBonosObjetivosDetalle)
	        	;


            END

            IF(@IDConceptoPagoComplemento <> 0)
            BEGIN
               IF(@IDPeriodoPagoComplemento = 0)
               BEGIN
                   RAISERROR('No se puede aplicar un cálculo que no tiene un periodo de pago de complemento', 16, 1);
                   RETURN;
               END
               IF EXISTS(SELECT TOP 1 1 FROM Nomina.tblCatPeriodos WHERE IDPeriodo = @IDPeriodoPagoComplemento AND Cerrado = 1)
               BEGIN
                   RAISERROR('El periodo de pago de complemento ya está cerrado', 16, 1);
                   RETURN;
               END

               MERGE Nomina.tblDetallePeriodo AS TARGET
               USING (
                   SELECT 
                       D.IDEmpleado,
                       D.IDControlBonosObjetivosDetalle,
                       CASE WHEN D.CalibracionComplemento = -1 THEN 0
                            WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento 
                            ELSE D.Complemento
                       END AS Monto
                   FROM Nomina.tblControlBonosObjetivosDetalle D
                   WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos 
                   AND ExcluirColaborador <> -1
                   AND (CASE WHEN D.CalibracionComplemento = -1 THEN 0
                            WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento 
                            ELSE D.Complemento
                       END) > 0
               ) AS SOURCE
               ON TARGET.IDPeriodo = @IDPeriodoPagoComplemento
                   AND TARGET.IDConcepto = @IDConceptoPagoComplemento
                   AND TARGET.IDEmpleado = SOURCE.IDEmpleado
               WHEN MATCHED THEN
                   UPDATE
                       SET TARGET.CantidadMonto = ISNULL(SOURCE.Monto, 0)
                          ,TARGET.IDReferencia = SOURCE.IDControlBonosObjetivosDetalle
               WHEN NOT MATCHED BY TARGET THEN 
                   INSERT(IDEmpleado, IDPeriodo, IDConcepto, CantidadMonto, IDReferencia)  
                   VALUES(SOURCE.IDEmpleado, @IDPeriodoPagoComplemento, @IDConceptoPagoComplemento, ISNULL(SOURCE.Monto, 0), SOURCE.IDControlBonosObjetivosDetalle)
               ;

            END

            
        END
        ELSE IF @Aplicar = 0
        BEGIN
            
            IF(@IDPeriodoPagoBono <> 0)
            BEGIN
                IF EXISTS (SELECT TOP 1 1 FROM NOMINA.tblCatPeriodos WHERE IDPeriodo=@IDPeriodoPagoBono AND Cerrado=1)
                BEGIN   
                    RAISERROR('No se puede desaplicar un cálculo que tiene un periodo cerrado como pago de bono,primero debe abrir el periodo', 16, 1);
                    RETURN;
                END
            END

            IF(@IDPeriodoPagoComplemento <> 0)
            BEGIN
                IF EXISTS (SELECT TOP 1 1 FROM NOMINA.tblCatPeriodos WHERE IDPeriodo=@IDPeriodoPagoComplemento AND Cerrado=1)
                BEGIN   
                    RAISERROR('No se puede desaplicar un cálculo que tiene un periodo cerrado como pago de complemento, primero debe abrir el periodo', 16, 1);
                    RETURN;
                END
            END

            DELETE DP
            FROM Nomina.tblDetallePeriodo DP            
            WHERE DP.IDPeriodo in (@IDPeriodoPagoBono, @IDPeriodoPagoComplemento)
            
        END


        UPDATE Nomina.tblControlBonosObjetivos
        SET Aplicado = @Aplicar
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

        -- Sincronizar empleados master
        EXEC [RH].[spSincronizarEmpleadosMaster];

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH;
END
GO
