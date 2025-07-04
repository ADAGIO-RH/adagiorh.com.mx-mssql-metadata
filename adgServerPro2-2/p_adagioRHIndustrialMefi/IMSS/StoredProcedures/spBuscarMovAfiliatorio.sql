USE [p_adagioRHIndustrialMefi]
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
2023-01-03		Aneudy Abreu		Se agregó la tabla [RH].[TblPrestacionesEmpleado] para buscar
									el factor según el historial de prestaciones

2024-06-12      Andrea Zainos     Se cambia el orden por el tipo de movimiento afiliatorio, la fecha
                                  y la prioridad ascendente para que muestre el ALTA primero siempre
 ***************************************************************************************************/
CREATE PROCEDURE [IMSS].[spBuscarMovAfiliatorio] (
	@IDEmpleado int = 0,
	@IDMovAfiliatorio int = 0
)
AS
BEGIN
    set @IDEmpleado=isnull(@IDEmpleado,0);
    set @IDMovAfiliatorio=isnull(@IDMovAfiliatorio,0);
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
		INNER JOIN IMSS.tblCatTipoMovimientos TM WITH(NOLOCK) ON TM.IDTipoMovimiento = M.IDTipoMovimiento
		LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios RMA WITH(NOLOCK) ON RMA.IDRazonMovimiento = M.IDRazonMovimiento
	    LEFT JOIN [RH].[tblCatRegPatronal] rp WITH(NOLOCK) ON M.IDRegPatronal = rp.IDRegPatronal
		INNER JOIN RH.tblEmpleadosMaster E WITH(NOLOCK) on M.IDEmpleado = E.IDEmpleado
		-- LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) ON Prestaciones.IDEmpleado = E.IDEmpleado 
		-- 	AND Prestaciones.FechaIni<= M.Fecha 
		-- 	AND Prestaciones.FechaFin >= M.Fecha        
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK) on TPD.IDTipoPrestacion = M.IDTipoPrestacion
			AND (tpd.Antiguedad = ISNULL(FLOOR(DATEDIFF(day,m.FechaAntiguedad, M.Fecha)/365.0),0)+1)  
	WHERE M.IDEmpleado = @IDEmpleado
		  or M.IDMovAfiliatorio = @IDMovAfiliatorio
	ORDER BY M.Fecha desc
END
GO
