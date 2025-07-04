USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los pedidos pendientes para engregar de un colaborador por IDEmpleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2024-04-17
** Paremetros		: @IDEmpleado           

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-04-22			ANEUDY ABREU		Corrige bug que permitía buscar pedidos de colaboradores
										que no están vigentes.
***************************************************************************************************/
CREATE   proc [Comedor].[spBuscarPedidosAEntregarByEmpleado](
	@IDEmpleado int
) as
	-- ResultSet 1: Pedidos empleados
	select
		 p.IDPedido
		,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
		,p.IDRestaurante
		,restaurantes.Nombre as Restaurante
		,p.IDEmpleado
		,empleado.ClaveEmpleado
		,empleado.NombreCompleto
		,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
		,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
		,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
		,p.Autorizado
		,isnull(p.GrandTotal,0) as GrandTotal
		,persons.PersonId
		,Menus = ISNULL( STUFF(
				(   SELECT ', '+ dpm.Nombre 
					FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock) 
					WHERE dpm.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene menús')	
		,ArticulosIndividuales = ISNULL( STUFF(
				(   SELECT ', '+ dpa.Nombre 
					FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
					WHERE dpa.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene artículos individuales')	
	from [Comedor].[tblPedidos] p with (nolock)
		join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
		join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
		left join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleado
		left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	where p.IDEmpleado = @IDEmpleado
		and isnull(p.Autorizado,0) = 0
		and isnull(p.ComandaImpresa, 0) = 1
		and isnull(p.Cancelada,0) = 0
		and isnull(empleado.Vigente, 0) = 1
	
	-- ResultSet 2: Pedidos empleados recibe
	select
		 p.IDPedido
		,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
		,p.IDRestaurante
		,restaurantes.Nombre as Restaurante
		,p.IDEmpleado
		,empleado.ClaveEmpleado
		,empleado.NombreCompleto
		,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
		,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
		,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
		,p.Autorizado
		,isnull(p.GrandTotal,0) as GrandTotal
		,persons.PersonId
		,Menus = ISNULL( STUFF(
				(   SELECT ', '+ dpm.Nombre 
					FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock)
					WHERE dpm.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene menús')	
		,ArticulosIndividuales = ISNULL( STUFF(
				(   SELECT ', '+ dpa.Nombre 
					FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
					WHERE dpa.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene artículos individuales')	
	from [Comedor].[tblPedidos] p with (nolock)
		join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
		join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
		left join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleadoRecibe
		left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	where p.IDEmpleadoRecibe = @IDEmpleado
		and isnull(p.Autorizado,0) = 0
		and isnull(p.ComandaImpresa, 0) = 1
		and isnull(p.Cancelada,0) = 0
		and isnull(empleadoRecibe.Vigente, 0) = 1

	-- ResultSet 3: Colaborador
	select e.*, p.PersonId as PersonId
	from RH.tblEmpleadosMaster e with (nolock)
		left join AzureCognitiveServices.tblPersons p with (nolock) on e.IDEmpleado = p.IDEmpleado
	where e.IDEmpleado = @IDEmpleado
		and isnull(e.Vigente, 0) = 1

	-- ResultSet 4: Pedidos del día
	select
		 p.IDPedido
		,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
		,p.IDRestaurante
		,restaurantes.Nombre as Restaurante
		,p.IDEmpleado
		,empleado.ClaveEmpleado
		,empleado.NombreCompleto
		,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
		,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
		,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
		,p.Autorizado
		,p.Cancelada
		,p.ComandaImpresa
		,isnull(p.GrandTotal,0) as GrandTotal
		,persons.PersonId
		,Menus = ISNULL( STUFF(
				(   SELECT ', '+ dpm.Nombre 
					FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock) 
					WHERE dpm.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene menús')	
		,ArticulosIndividuales = ISNULL( STUFF(
				(   SELECT ', '+ dpa.Nombre 
					FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
					WHERE dpa.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene artículos individuales')	
	from [Comedor].[tblPedidos] p with (nolock)
		join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
		join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
		left join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleado
		left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	where p.IDEmpleado = @IDEmpleado
		and p.FechaCreacion = cast(getdate() as date)
		and isnull(empleado.Vigente, 0) = 1
GO
