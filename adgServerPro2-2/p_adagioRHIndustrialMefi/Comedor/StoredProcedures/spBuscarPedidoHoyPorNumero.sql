USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar un pedido del día de hoy por Número
** Autor			: ANEUDY ABREU
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-05-19			ANEUDY ABREU		Agrega el campo GranTotal al resultset
***************************************************************************************************/
CREATE proc [Comedor].[spBuscarPedidoHoyPorNumero](
	@IDRestaurante	int  = 0
	,@IDEmpleado    int  = 0
	,@Numero		varchar(50)
)
as
	declare 
		@FechaHoy date = getdate()
	;

	 select 
		[P].[IDPedido]
		,[P].[Numero]
		,Comedor.fnFormatoNumeroPedido([P].[Numero])			as [NumeroStr]
		,[P].[IDRestaurante]
		,[R].[Nombre] as                                           [Restaurante]
		,[P].[IDEmpleado]
		,[E].[ClaveEmpleado]
		,[E].[NOMBRECOMPLETO] as                                   [Colaborador]
		,isnull([P].[IDEmpleadoRecibe],0) as                       [IDEmpleadoRecibe]
		,[Emprecibe].[ClaveEmpleado] as                            [ClaveEmpleadoRecibe]
		,[Emprecibe].[NOMBRECOMPLETO] as                           [ColaboradorRecibe]
		,[P].[Autorizado]
		,isnull([P].[IDEmpleadoAutorizo],0) as                     [IDEmpleadoAutorizo]
		,isnull([P].[IDUsuarioAutorizo],0) as                      [IDUsuarioAutorizo]
		,isnull([P].[FechaHoraAutorizacion],'1990-01-01 00:00') as [FechaHoraAutorizacion]
		,[P].[ComandaImpresa]
		,isnull([P].[FechaHoraImpresion],'1990-01-01') as          [FechaHoraImpresion]
		,[P].[DescontadaDeNomina]
		,isnull([P].[FechaHoraDescuento],'1990-01-01') as          [FechaHoraDescuento]
		,isnull([P].[IDPeriodo],0) as                              [IDPeriodo]
		,[P].[Cancelada]
		,[P].[NotaCancelacion]
		,isnull([P].[FechaCancelacion],'1990-01-01 00:00') as      [FechaCancelacion]
		,[P].[FechaCreacion]
		,[P].[HoraCreacion]
		,isnull([P].[GrandTotal], 0.00) as [GrandTotal]
	  from [Comedor].[tblPedidos] [P] with(nolock)
		   join [Comedor].[tblCatRestaurantes] [R] with(nolock) on [R].[IDRestaurante] = [P].[IDRestaurante]
		   join [RH].[tblEmpleadosMaster] [E] with(nolock) on [E].[IDEmpleado] = [P].[IDEmpleado]
		   left join [RH].[tblEmpleadosMaster] [empRecibe] with(nolock) on [empRecibe].[IDEmpleado] = [P].[IDEmpleadoRecibe]
	  where [P].[Numero] = @Numero
			and [P].[IDRestaurante] = isnull(@IDRestaurante,0)
			and [P].[IDEmpleado] = isnull(@IDEmpleado,0)
			and [P].[FechaCreacion] = @FechaHoy
GO
