USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [IMSS].[fnObtenerUltimoMovimientoEmpleado]
(
	@IDEmpleado int
)
RETURNS @tblUltimoMovimientoEmpleado TABLE 
(
    -- Columns returned by the function
     IDMovAfiliatorio int
	,Fecha date
	,IDEmpleado int
	,IDTipoMovimiento int
	,FechaIMSS date null
	,FechaIDSE date null
	,IDRazonMovimiento int null
	,SalarioDiario decimal(18,2)
	,SalarioIntegrado decimal(18,2)
	,SalarioVariable decimal(18,2)
	,SalarioDiarioReal decimal(18,2)
	,IDRegPatronal int
	,RespetarAntiguedad bit
)
AS 
BEGIN
	
	insert into @tblUltimoMovimientoEmpleado(
		IDMovAfiliatorio
		,Fecha
		,IDEmpleado
		,IDTipoMovimiento
		,FechaIMSS
		,FechaIDSE
		,IDRazonMovimiento
		,SalarioDiario
		,SalarioIntegrado
		,SalarioVariable
		,SalarioDiarioReal
		,IDRegPatronal
		,RespetarAntiguedad
	)
	Select top 1 IDMovAfiliatorio
			,Fecha
			,IDEmpleado
			,IDTipoMovimiento
			,FechaIMSS
			,FechaIDSE
			,IDRazonMovimiento
			,SalarioDiario
			,SalarioIntegrado
			,SalarioVariable
			,SalarioDiarioReal
			,IDRegPatronal
			,RespetarAntiguedad
	from IMSS.tblMovAfiliatorios with(nolock)
		WHERE IDEmpleado = @IDEmpleado
	ORDER BY Fecha desc
	
	RETURN;
END
GO
