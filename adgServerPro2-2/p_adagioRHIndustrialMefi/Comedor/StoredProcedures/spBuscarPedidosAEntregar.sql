USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los pedidos pendientes para engregar de un colaborador
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-01-01
** Paremetros		: @personsIds           

** DataTypes Relacionados: 


[Comedor].[spBuscarPedidosAEntregar] '079d9169-4e6a-4a7a-9e19-2a344944fbd9'
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Comedor].[spBuscarPedidosAEntregar](
	@personsIds varchar(max)
) as
	declare 
		@personId varchar(max),
		@IDEmpleado int
	;

	select top 1 @personId = item from App.Split(@personsIds, ',')
	
	select @IDEmpleado = p.IDEmpleado
	from AzureCognitiveServices.tblPersons p
	where p.PersonId = @personId

	exec [Comedor].[spBuscarPedidosAEntregarByEmpleado] @IDEmpleado=@IDEmpleado
	

	---- ResultSet 1: Pedidos empleados
	--select
	--	 p.IDPedido
	--	,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
	--	,p.IDRestaurante
	--	,restaurantes.Nombre as Restaurante
	--	,p.IDEmpleado
	--	,empleado.ClaveEmpleado
	--	,empleado.NombreCompleto
	--	,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
	--	,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
	--	,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
	--	,p.Autorizado
	--	,isnull(p.GrandTotal,0) as GrandTotal
	--	,persons.PersonId
	--	,Menus = ISNULL( STUFF(
	--			(   SELECT ', '+ dpm.Nombre 
	--				FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock) 
	--				WHERE dpm.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene menús')	
	--	,ArticulosIndividuales = ISNULL( STUFF(
	--			(   SELECT ', '+ dpa.Nombre 
	--				FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
	--				WHERE dpa.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene artículos individuales')	
	--from [Comedor].[tblPedidos] p with (nolock)
	--	join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
	--	join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleado
	--	join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
	--	left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	--where persons.PersonId = @personId
	--	and isnull(p.Autorizado,0) = 0
	--	and isnull(p.ComandaImpresa, 0) = 1
	--	and isnull(p.Cancelada,0) = 0
	
	---- ResultSet 2: Pedidos empleados recibe
	--select
	--	 p.IDPedido
	--	,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
	--	,p.IDRestaurante
	--	,restaurantes.Nombre as Restaurante
	--	,p.IDEmpleado
	--	,empleado.ClaveEmpleado
	--	,empleado.NombreCompleto
	--	,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
	--	,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
	--	,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
	--	,p.Autorizado
	--	,isnull(p.GrandTotal,0) as GrandTotal
	--	,persons.PersonId
	--	,Menus = ISNULL( STUFF(
	--			(   SELECT ', '+ dpm.Nombre 
	--				FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock)
	--				WHERE dpm.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene menús')	
	--	,ArticulosIndividuales = ISNULL( STUFF(
	--			(   SELECT ', '+ dpa.Nombre 
	--				FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
	--				WHERE dpa.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene artículos individuales')	
	--from [Comedor].[tblPedidos] p with (nolock)
	--	join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
	--	join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleadoRecibe
	--	join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
	--	left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	--where persons.PersonId = @personId
	--	and isnull(p.Autorizado,0) = 0
	--	and isnull(p.ComandaImpresa, 0) = 1
	--	and isnull(p.Cancelada,0) = 0

	---- ResultSet 3: Colaborador
	--select e.*, @personId as PersonId
	--from AzureCognitiveServices.tblPersons p with (nolock)
	--	join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = p.IDEmpleado
	--where p.PersonId = @personId

	---- ResultSet 4: Pedidos del día
	--select
	--	 p.IDPedido
	--	,Comedor.fnFormatoNumeroPedido([P].[Numero]) as [Numero]
	--	,p.IDRestaurante
	--	,restaurantes.Nombre as Restaurante
	--	,p.IDEmpleado
	--	,empleado.ClaveEmpleado
	--	,empleado.NombreCompleto
	--	,isnull(p.IDEmpleadoRecibe,0) as IDEmpleadoRecibe
	--	,isnull(empleadoRecibe.ClaveEmpleado ,'[00000]') as ClaveEmpleadoRecibe
	--	,isnull(empleadoRecibe.NombreCompleto,'[Ninguno]') as NombreCompletoEmpleadoRecibe
	--	,p.Autorizado
	--	,p.Cancelada
	--	,p.ComandaImpresa
	--	,isnull(p.GrandTotal,0) as GrandTotal
	--	,persons.PersonId
	--	,Menus = ISNULL( STUFF(
	--			(   SELECT ', '+ dpm.Nombre 
	--				FROM [Comedor].[tblDetallePedidoMenus] dpm with (nolock) 
	--				WHERE dpm.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene menús')	
	--	,ArticulosIndividuales = ISNULL( STUFF(
	--			(   SELECT ', '+ dpa.Nombre 
	--				FROM [Comedor].[tblDetallePedidoArticulos] dpa with (nolock) 
	--				WHERE dpa.IDPedido = p.IDPedido
	--				FOR xml path('')
	--			)
	--			, 1
	--			, 1
	--			, ''), 'El pedido no tiene artículos individuales')	
	--from [Comedor].[tblPedidos] p with (nolock)
	--	join [Comedor].[tblCatRestaurantes] restaurantes with (nolock) on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
	--	join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleado
	--	join [RH].[tblEmpleadosMaster] empleado with (nolock) on empleado.IDEmpleado = p.IDEmpleado
	--	left join [RH].[tblEmpleadosMaster] empleadoRecibe with (nolock) on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	--where persons.PersonId = @personId
	--	and p.FechaCreacion = cast(getdate() as date)
GO
