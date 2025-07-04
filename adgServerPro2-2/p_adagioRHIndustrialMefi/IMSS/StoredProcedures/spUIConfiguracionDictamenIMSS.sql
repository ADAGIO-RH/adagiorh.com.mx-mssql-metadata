USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : Procedimiento para actualización e inserción de datos en [IMSS].[tblConfiguracionDictamenIMSS]
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-01-24
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [IMSS].[spUIConfiguracionDictamenIMSS]
(
    @SueldosSalarios NVARCHAR(MAX),
    @GratificacionAnual NVARCHAR(MAX),
    @ParticipacionUtilidades NVARCHAR(MAX),
    @ReembolsoGastosMedicos NVARCHAR(MAX),
    @FondoAhorroPatron NVARCHAR(MAX),
    @FondoAhorroTrabajador NVARCHAR(MAX),
    @CajaAhorro NVARCHAR(MAX),
    @ContribucionesTrabajador NVARCHAR(MAX),
    @PremiosPuntualidad NVARCHAR(MAX),
    @PrimaSeguroVida NVARCHAR(MAX),
    @SeguroGastosMedicosMayores NVARCHAR(MAX),
    @CuotasSindicales NVARCHAR(MAX),
    @SubsidiosIncapacidad NVARCHAR(MAX),
    @BecasTrabajadoresHijos NVARCHAR(MAX),
    @HoraExtra NVARCHAR(MAX),
    @PrimaDominical NVARCHAR(MAX),
    @PrimaVacacional NVARCHAR(MAX),
    @PrimaAntiguedad NVARCHAR(MAX),
    @PagosSeparacion NVARCHAR(MAX),
    @SeguroRetiro NVARCHAR(MAX),
    @Indemnizaciones NVARCHAR(MAX),
    @ReembolsoFuneral NVARCHAR(MAX),
    @CuotasSeguridadSocial NVARCHAR(MAX),
    @Comisiones NVARCHAR(MAX),
    @ValesDespensa NVARCHAR(MAX),
    @ValesRestaurante NVARCHAR(MAX),
    @ValesGasolina NVARCHAR(MAX),
    @ValesRopa NVARCHAR(MAX),
    @AyudaRenta NVARCHAR(MAX),
    @AyudaArticulosEscolares NVARCHAR(MAX),
    @AyudaAnteojos NVARCHAR(MAX),
    @AyudaTransporte NVARCHAR(MAX),
    @AyudaGastosFuneral NVARCHAR(MAX),
    @OtrosIngresosSalarios NVARCHAR(MAX),
    @JubilacionesPensionesRetiro NVARCHAR(MAX),
    @JubilacionesPensionesRetiroParcialidades NVARCHAR(MAX),
    @IngresosAccionesTitulos NVARCHAR(MAX),
    @Alimentacion NVARCHAR(MAX),
    @Habitacion NVARCHAR(MAX),
    @PremiosAsistencia NVARCHAR(MAX),
    @Viaticos NVARCHAR(MAX),
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @ProcedureName VARCHAR(MAX) = '[IMSS].[spUIConfiguracionDictamenIMSS]',
        @TableName VARCHAR(MAX) = '[IMSS].[tblConfiguracionDictamenIMSS]',
        @Action VARCHAR(20) = '';

    IF ((SELECT COUNT(*) FROM [IMSS].[tblConfiguracionDictamenIMSS]) > 0)
    BEGIN
        SELECT @OldJSON = a.JSON, @Action = 'UPDATE'
        FROM [IMSS].[tblConfiguracionDictamenIMSS] b
        CROSS APPLY (
            SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))
        ) a;

        UPDATE [IMSS].[tblConfiguracionDictamenIMSS]
        SET
            SueldosSalarios = @SueldosSalarios,
            GratificacionAnual = @GratificacionAnual,
            ParticipacionUtilidades = @ParticipacionUtilidades,
            ReembolsoGastosMedicos = @ReembolsoGastosMedicos,
            FondoAhorroPatron = @FondoAhorroPatron,
            FondoAhorroTrabajador = @FondoAhorroTrabajador,
            CajaAhorro = @CajaAhorro,
            ContribucionesTrabajador = @ContribucionesTrabajador,
            PremiosPuntualidad = @PremiosPuntualidad,
            PrimaSeguroVida = @PrimaSeguroVida,
            SeguroGastosMedicosMayores = @SeguroGastosMedicosMayores,
            CuotasSindicales = @CuotasSindicales,
            SubsidiosIncapacidad = @SubsidiosIncapacidad,
            BecasTrabajadoresHijos = @BecasTrabajadoresHijos,
            HoraExtra = @HoraExtra,
            PrimaDominical = @PrimaDominical,
            PrimaVacacional = @PrimaVacacional,
            PrimaAntiguedad = @PrimaAntiguedad,
            PagosSeparacion = @PagosSeparacion,
            SeguroRetiro = @SeguroRetiro,
            Indemnizaciones = @Indemnizaciones,
            ReembolsoFuneral = @ReembolsoFuneral,
            CuotasSeguridadSocial = @CuotasSeguridadSocial,
            Comisiones = @Comisiones,
            ValesDespensa = @ValesDespensa,
            ValesRestaurante = @ValesRestaurante,
            ValesGasolina = @ValesGasolina,
            ValesRopa = @ValesRopa,
            AyudaRenta = @AyudaRenta,
            AyudaArticulosEscolares = @AyudaArticulosEscolares,
            AyudaAnteojos = @AyudaAnteojos,
            AyudaTransporte = @AyudaTransporte,
            AyudaGastosFuneral = @AyudaGastosFuneral,
            OtrosIngresosSalarios = @OtrosIngresosSalarios,
            JubilacionesPensionesRetiro = @JubilacionesPensionesRetiro,
            JubilacionesPensionesRetiroParcialidades = @JubilacionesPensionesRetiroParcialidades,
            IngresosAccionesTitulos = @IngresosAccionesTitulos,
            Alimentacion = @Alimentacion,
            Habitacion = @Habitacion,
            PremiosAsistencia = @PremiosAsistencia,
            Viaticos = @Viaticos
        

        SELECT @NewJSON = a.JSON
        FROM [IMSS].[tblConfiguracionDictamenIMSS] b
        CROSS APPLY (
            SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))
        ) a;
    END
    ELSE
    BEGIN
        INSERT INTO [IMSS].[tblConfiguracionDictamenIMSS] (
            IDConfiguracionDictamenIMSS,
            SueldosSalarios,
            GratificacionAnual,
            ParticipacionUtilidades,
            ReembolsoGastosMedicos,
            FondoAhorroPatron,
            FondoAhorroTrabajador,
            CajaAhorro,
            ContribucionesTrabajador,
            PremiosPuntualidad,
            PrimaSeguroVida,
            SeguroGastosMedicosMayores,
            CuotasSindicales,
            SubsidiosIncapacidad,
            BecasTrabajadoresHijos,
            HoraExtra,
            PrimaDominical,
            PrimaVacacional,
            PrimaAntiguedad,
            PagosSeparacion,
            SeguroRetiro,
            Indemnizaciones,
            ReembolsoFuneral,
            CuotasSeguridadSocial,
            Comisiones,
            ValesDespensa,
            ValesRestaurante,
            ValesGasolina,
            ValesRopa,
            AyudaRenta,
            AyudaArticulosEscolares,
            AyudaAnteojos,
            AyudaTransporte,
            AyudaGastosFuneral,
            OtrosIngresosSalarios,
            JubilacionesPensionesRetiro,
            JubilacionesPensionesRetiroParcialidades,
            IngresosAccionesTitulos,
            Alimentacion,
            Habitacion,
            PremiosAsistencia,
            Viaticos    
        )
        VALUES (
            1,
            @SueldosSalarios,
            @GratificacionAnual,
            @ParticipacionUtilidades,
            @ReembolsoGastosMedicos,
            @FondoAhorroPatron,
            @FondoAhorroTrabajador,
            @CajaAhorro,
            @ContribucionesTrabajador,
            @PremiosPuntualidad,
            @PrimaSeguroVida,
            @SeguroGastosMedicosMayores,
            @CuotasSindicales,
            @SubsidiosIncapacidad,
            @BecasTrabajadoresHijos,
            @HoraExtra,
            @PrimaDominical,
            @PrimaVacacional,
            @PrimaAntiguedad,
            @PagosSeparacion,
            @SeguroRetiro,
            @Indemnizaciones,
            @ReembolsoFuneral,
            @CuotasSeguridadSocial,
            @Comisiones,
            @ValesDespensa,
            @ValesRestaurante,
            @ValesGasolina,
            @ValesRopa,
            @AyudaRenta,
            @AyudaArticulosEscolares,
            @AyudaAnteojos,
            @AyudaTransporte,
            @AyudaGastosFuneral,
            @OtrosIngresosSalarios,
            @JubilacionesPensionesRetiro,
            @JubilacionesPensionesRetiroParcialidades,
            @IngresosAccionesTitulos,
            @Alimentacion,
            @Habitacion,
            @PremiosAsistencia,
            @Viaticos           
        );

        SELECT @NewJSON = a.JSON, @Action = 'INSERT'
        FROM [IMSS].[tblConfiguracionDictamenIMSS] b
        CROSS APPLY (
            SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))
        ) a;
    END

    
    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario = @IDUsuario,
        @Tabla = @TableName,
        @Procedimiento = @ProcedureName,
        @Accion = @Action,
        @NewData = @NewJSON,
        @OldData = @OldJSON;
    
    EXEC [IMSS].[spBuscarConfiguracionDictamenIMSS] @IDUsuario=@IDUsuario;
END
GO
