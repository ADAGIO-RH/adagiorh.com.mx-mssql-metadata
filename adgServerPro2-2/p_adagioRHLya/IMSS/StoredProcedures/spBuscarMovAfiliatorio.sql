USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar historial de movimientos afiliatorio de por trabajador o por IDMovAfiliatorio
** Autor			: Jose R. Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:   @IDEmpleado int = 0,
				    @IDMovAfiliatorio int = 0           
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-05-30		Aneudy Abreu		Cuando el parámetro IDEmpleado = 0 retormaba todos los
								movimientos, se cambió la condición para que si ambos parámetros
								son = 0 no retorme ningún movimiento.

								Si ambos parámetros son diferente de 0 se retornan todos los 
								movimientos de ese empleado.

								Si @IDEmpleado = 0 y @IDMovAfiliatorio <> 0 se retorna solo 
								el movimiento que sea igual al @IDMovAfiliatorio.

								Si @IDEmpleado <> 0 y @IDMovAfiliatorio = 0 se retorna todos 
								los movimiento del empleado.
 ***************************************************************************************************/
CREATE PROCEDURE [IMSS].[spBuscarMovAfiliatorio](
	@IDEmpleado int = 0,
	@IDMovAfiliatorio int = 0
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
		   RMA.Codigo as CodigoRazon,
		   RMA.Descripcion as Razon,
		   isnull(M.SalarioDiario,0.00) as SalarioDiario,
		   isnull(M.SalarioIntegrado,0.00) as SalarioIntegrado,
		   isnull(M.SalarioVariable,0.00) as SalarioVariable,
		   isnull(M.SalarioDiarioReal,0.00) as SalarioDiarioReal,
		   isnull(M.IDRegPatronal,0) as IDRegPatronal,
		   coalesce(rp.RegistroPatronal,'0000000000000')+ '-'+coalesce(rp.RazonSocial,'SIN REGISTRO PATRONAL') as RegPatronal,
		   isnull(M.RespetarAntiguedad,0) as RespetarAntiguedad
	FROM IMSS.tblMovAfiliatorios M
		INNER JOIN IMSS.tblCatTipoMovimientos TM
			ON TM.IDTipoMovimiento = M.IDTipoMovimiento
		LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios RMA
			ON RMA.IDRazonMovimiento = M.IDRazonMovimiento
	     LEFT JOIN [RH].[tblCatRegPatronal] rp on M.IDRegPatronal = rp.IDRegPatronal
	WHERE  (M.IDEmpleado = @IDEmpleado)
		  or (M.IDMovAfiliatorio = @IDMovAfiliatorio)
	ORDER BY M.Fecha desc
END
GO
