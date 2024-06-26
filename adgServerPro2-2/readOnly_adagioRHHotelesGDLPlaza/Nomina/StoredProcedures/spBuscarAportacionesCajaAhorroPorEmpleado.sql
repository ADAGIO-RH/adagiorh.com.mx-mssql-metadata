USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de aportaciones de caja de ahorro
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-11-27
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarAportacionesCajaAhorroPorEmpleado]
		@IDCajaAhorro	= 1
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAportacionesCajaAhorroPorEmpleado](
		@IDCajaAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
) as
	--declare @IDFondoAhorro	int = 4
	--		,@IDEmpleado	int = 1279
	--		,@IDUsuario		int = 1
	declare  
			@IDPeriodoInicial	   int
			,@IDPeriodoFinal	   int 
			,@CodigoConceptoCajaAhorro varchar(10) = '320'
	 ;
	
	Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			,coalesce(UPPER(p.ClavePeriodo),'')+'-'+coalesce(UPPER(p.Descripcion),'') as Periodo
			,ISNULL(DP.ImporteTotal1,0) as Monto
			,c.Descripcion as Concepto
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo = @CodigoConceptoCajaAhorro
	order by p.FechaInicioPago asc
GO
