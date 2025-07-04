USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar Ultimo movimientos afiliatorio de un trabajador
** Autor			: Jose R. Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:   @IDEmpleado int = 0,
				    @IDMovAfiliatorio int = 0      
					
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2025-02-06			ANEUDY ABREU		Agrega isnull al campo IDTipoRazonMovimiento
										Agrega isnull al campo FechaUltimoDiaLaborado
										Cambia fecha default para FechaIMSS y FechaIDSE de 0001-01-01 
											a 1900-01-01
***************************************************************************************************/

CREATE PROCEDURE [IMSS].[spBucarUltimoMovimientoAfiliatorioEmpleado] 
(
	@IDEmpleado int
)
AS
BEGIN
	SELECT TOP 1 
		M.IDMovAfiliatorio,
		   M.Fecha,
		   M.IDEmpleado,
		   M.IDTipoMovimiento,
		   TM.Codigo,
		   TM.Descripcion,
		   TM.Prioridad,
		   isnull(M.FechaIMSS,cast('1900-01-01' as date)) as FechaIMSS,
		   isnull(M.FechaIDSE,cast('1900-01-01' as date)) as FechaIDSE,
		   isnull(M.IDRazonMovimiento,0) as IDRazonMovimiento,
           isnull(IDTipoRazonMovimiento, 0) as IDTipoRazonMovimiento,
		   RMA.Codigo as CodigoRazon,
		   RMA.Descripcion as Razon,
		   isnull(M.SalarioDiario,0.00) as SalarioDiario,
		   isnull(M.SalarioIntegrado,0.00) as SalarioIntegrado,
		   isnull(M.SalarioVariable,0.00) as SalarioVariable,
		   isnull(M.SalarioDiarioReal,0.00) as SalarioDiarioReal,
		   isnull(M.IDRegPatronal,0) as IDRegPatronal,
		   coalesce(rp.RegistroPatronal,'0000000000000')+ '-'+coalesce(rp.RazonSocial,'SIN REGISTRO PATRONAL') as RegPatronal,
		   isnull(M.RespetarAntiguedad,0) as RespetarAntiguedad,
		   DATEDIFF(YEAR,(M.FechaAntiguedad), M.Fecha) as AniosAntiguedad,
		   ISNULL(TPD.Factor,0.00000) as Factor,
		   isnull(M.FechaUltimoDiaLaborado,cast('1900-01-01' as date)) as FechaUltimoDiaLaborado,
           Comentario
	FROM IMSS.tblMovAfiliatorios M WITH(NOLOCK)
		INNER JOIN IMSS.tblCatTipoMovimientos TM WITH(NOLOCK) ON TM.IDTipoMovimiento = M.IDTipoMovimiento
		LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios RMA WITH(NOLOCK) ON RMA.IDRazonMovimiento = M.IDRazonMovimiento
		LEFT JOIN [RH].[tblCatRegPatronal] rp WITH(NOLOCK) ON M.IDRegPatronal = rp.IDRegPatronal
		INNER JOIN RH.tblEmpleadosMaster E WITH(NOLOCK) ON M.IDEmpleado = E.IDEmpleado
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK) ON TPD.IDTipoPrestacion = E.IDTipoPrestacion
			AND TPD.Antiguedad =  DATEDIFF(YEAR,(M.FechaAntiguedad), M.Fecha) + 1
	WHERE  (M.IDEmpleado = @IDEmpleado)
	ORDER BY M.Fecha desc
END
GO
