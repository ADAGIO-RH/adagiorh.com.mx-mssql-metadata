USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : Procedimiento de busqueda de configuraciones para Dictamen IMSS
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-01-24
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [IMSS].[spBuscarConfiguracionDictamenIMSS](    	
    @IDUsuario int    
)
AS
BEGIN
    
    SELECT
    TOP 1
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
    FROM
    [IMSS].[tblConfiguracionDictamenIMSS];



END
GO
