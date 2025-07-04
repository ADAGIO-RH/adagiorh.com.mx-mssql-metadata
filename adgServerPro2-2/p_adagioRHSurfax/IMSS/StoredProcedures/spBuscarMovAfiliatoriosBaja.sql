USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción   : Buscar historial de movimientos afiliatorios de baja por trabajador
** Autor         : Andrea Zainos
** Email         : andrea.zainos@adagio.com.mx
** FechaCreacion : 2024-03-19
** Paremetros    : @IDEmpleado int = 0
****************************************************************************************************/
CREATE   PROCEDURE [IMSS].[spBuscarMovAfiliatoriosBaja]  (
    @IDEmpleado int = 0
)
AS
BEGIN
    SELECT M.IDMovAfiliatorio,
           M.Fecha,
           M.IDEmpleado,
           M.IDTipoMovimiento,
           TM.Codigo,
           TM.Descripcion,
           TM.Prioridad,
           isnull(M.FechaIMSS,cast('0001-01-01' as date)) as FechaIMSS,
           isnull(M.FechaIDSE,cast('0001-01-01' as date)) as FechaIDSE,
           isnull(M.IDRazonMovimiento,0) as IDRazonMovimiento,
           isnull(M.IDTipoRazonMovimiento,0) as IDTipoRazonMovimiento,
           RMA.Codigo as CodigoRazon,
           RMA.Descripcion as Razon,
           isnull(M.SalarioDiario,0.00) as SalarioDiario,
           isnull(M.SalarioIntegrado,0.00) as SalarioIntegrado,
           isnull(M.SalarioVariable,0.00) as SalarioVariable,
           isnull(M.SalarioDiarioReal,0.00) as SalarioDiarioReal,
           isnull(M.IDRegPatronal,0) as IDRegPatronal,
           coalesce(rp.RegistroPatronal,'0000000000000')+ '-'+coalesce(rp.RazonSocial,'SIN REGISTRO PATRONAL') as RegPatronal,
           isnull(M.RespetarAntiguedad,0) as RespetarAntiguedad,
           ISNULL(FLOOR(DATEDIFF(day,m.FechaAntiguedad, M.Fecha)/365.0),0) AS AniosAntiguedad,
           ISNULL(TPD.Factor,0.00000) as Factor,
           isnull(M.FechaAntiguedad,'9999-12-31') FechaAntiguedad,
           isnull(M.FechaUltimoDiaLaborado,'9999-12-31') FechaUltimoDiaLaborado,
           M.Comentario
    FROM IMSS.tblMovAfiliatorios M WITH(NOLOCK)
        INNER JOIN IMSS.tblCatTipoMovimientos TM WITH(NOLOCK) ON TM.IDTipoMovimiento = M.IDTipoMovimiento AND TM.Codigo = 'B' 
        LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios RMA WITH(NOLOCK) ON RMA.IDRazonMovimiento = M.IDRazonMovimiento
        LEFT JOIN [RH].[tblCatRegPatronal] rp WITH(NOLOCK) ON M.IDRegPatronal = rp.IDRegPatronal
        INNER JOIN RH.tblEmpleadosMaster E WITH(NOLOCK) on M.IDEmpleado = E.IDEmpleado
        LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK) on TPD.IDTipoPrestacion = M.IDTipoPrestacion
            AND (tpd.Antiguedad = ISNULL(FLOOR(DATEDIFF(day,m.FechaAntiguedad, M.Fecha)/365.0),0)+1)  
    WHERE M.IDEmpleado = @IDEmpleado
        
    ORDER BY M.Fecha desc
END
GO
