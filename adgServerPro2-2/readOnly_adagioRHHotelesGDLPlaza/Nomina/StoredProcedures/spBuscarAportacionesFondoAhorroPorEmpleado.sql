USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de aportaciones por Tipo (Empleado o Trabajador)
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-08-29
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarAportacionesFondoAhorroPorEmpleado]
		@IDFondoAhorro	= 4
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAportacionesFondoAhorroPorEmpleado](
		@IDFondoAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
) as
--declare @IDFondoAhorro	int = 4
--		,@IDEmpleado	int = 1279
--		,@IDUsuario		int = 1
declare  
		@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
		,@CodigosConceptosFondoAhorroEmpresa varchar(100) = '308' -- FONDO DE AHORRO EMPRESA 
		,@CodigosConceptosFondoAhorroTrabajador varchar(100) = '309' -- FONDO DE AHORRO TRABAJADOR
		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31'
 ;
	
	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni=FechaInicioPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal

	Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
			,ImporteAbono = case when c.Codigo in ('308','309') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,ImporteCargo = case when c.Codigo in ('162','163') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,c.Descripcion
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('162','163','308','309')--= case when @Tipo = 1 then @CodigosConceptosFondoAhorroEmpresa else @CodigosConceptosFondoAhorroTrabajador end
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
	order by p.FechaInicioPago asc


 -- exec nomina.spBuscarCatConceptos
GO
