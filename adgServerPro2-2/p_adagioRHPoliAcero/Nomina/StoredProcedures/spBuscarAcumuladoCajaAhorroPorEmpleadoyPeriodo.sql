USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar el acumulado de Caja de ahorro de un colaborador
** Autor			: Yesenia Leonel
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-06
** Paremetros		:              

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2022-05-09		Yesenia Leonel		Se copio el SP [Nomina].[spBuscarAcumuladoCajaAhorroPorEmpleado] pasando el ID Periodo
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAcumuladoCajaAhorroPorEmpleadoyPeriodo](
		@IDCajaAhorro			int	--= 2
		,@IDEmpleado			int	--= 1279
		,@IDPeriodo int
		,@IDUsuario int
) as
	declare 
		--@IDEmpleado int = 1279
		--,@IDCajaAhorro int =  1
		 @CodigoConceptoCajaAhorro varchar(10) = '320'
		,@CodigoConceptoDevolucionCajaAhorro varchar(10) = '529'
		,@CodigoConceptoPrestamosCajaAhorro varchar(10) = '146'
		,@TotalAcumuladoCajaAhorro decimal(18,2)
		,@TotalDevolucionesCajaAhorro decimal(18,2)
		,@TotalPrestamosPendientes decimal(18,2) = 0
		,@TotalDevolucionesPendientes decimal(18,2) = 0
		,@FechaIni date = '2025-01-01' -- FECHAS A MODIFICAR
		,@FechaFin date = '2025-12-31' -- FECHAS A MODIFICAR
	;

set @FechaIni = Cast(Cast((Select Ejercicio from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo ) as Varchar(4)) +'-01-01' as date)
set @FechaFin	= (select FechaFinPago from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodo)


	--select @TotalPrestamosPendientes=isnull(sum(dca.Monto),0)
	--from [Nomina].[tblDevolucionesCajaAhorro] dca
	--	join [Nomina].[tblCajaAhorro] ca on dca.IDCajaAhorro = ca.IDCajaAhorro
	--	join [Nomina].[tblCatPeriodos] p on dca.IDPeriodo = p.IDPeriodo and isnull(p.Cerrado,0) = 0
	--where dca.IDCajaAhorro = @IDCajaAhorro and ca.IDEmpleado = @IDEmpleado

	select @TotalDevolucionesPendientes=isnull(sum(dca.Monto),0)
	from [Nomina].[tblDevolucionesCajaAhorro] dca
		join [Nomina].[tblCajaAhorro] ca on dca.IDCajaAhorro = ca.IDCajaAhorro
		join [Nomina].[tblCatPeriodos] p on dca.IDPeriodo = p.IDPeriodo and isnull(p.Cerrado,0) = 0
	where dca.IDCajaAhorro = @IDCajaAhorro and ca.IDEmpleado = @IDEmpleado

	--select @TotalDevolucionesPendientes
	--return

	select @TotalAcumuladoCajaAhorro=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoFecha] (@IDEmpleado 
												,@CodigoConceptoCajaAhorro
												,@FechaIni
												,@FechaFin 
												)
	--select @TotalAcumuladoCajaAhorro
	--return

	select @TotalDevolucionesCajaAhorro=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoFecha] (@IDEmpleado,
								@CodigoConceptoDevolucionCajaAhorro,
								@FechaIni,
								@FechaFin )


	select @TotalAcumuladoCajaAhorro								as TotalAcumuladoCajaAhorro
		,@TotalDevolucionesCajaAhorro								as TotalPrestamosDevolucionesCajaAhorro		
		,@TotalAcumuladoCajaAhorro - @TotalDevolucionesCajaAhorro	as NetoDisponible	
		,@TotalDevolucionesPendientes+@TotalPrestamosPendientes									as TotalPrestamosPendientes

--	select @TotalPrestamosPendientes,@TotalAcumuladoCajaAhorro,@TotalDevolucionesCajaAhorro
	--select * from Nomina.tblCajaAhorro
GO
