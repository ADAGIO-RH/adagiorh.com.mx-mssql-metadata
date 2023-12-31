USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [Comedor].[spBuscarPedidosAEntregar] '08910d87-a780-4cd5-81db-fe7c585d0f92'

--GO

CREATE proc [Comedor].[spBuscarPedidosAEntregar](
	@personsIds varchar(max)
) as
	declare 
		@personId varchar(max)-- = '08910d87-a780-4cd5-81db-fe7c585d0f92',
		--,@personsIds varchar(max)  = '08910d87-a780-4cd5-81db-fe7c585d0f92'
		--@IDRestaurante int = 2
	;

	select top 1 @personId = item from App.Split(@personsIds, ',')

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
					FROM [Comedor].[tblDetallePedidoMenus] dpm 
					WHERE dpm.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene menús')	
	from [Comedor].[tblPedidos] p with (nolock)
		join [Comedor].[tblCatRestaurantes] restaurantes on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
		join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleado
		join [RH].[tblEmpleadosMaster] empleado on empleado.IDEmpleado = p.IDEmpleado
		left join [RH].[tblEmpleadosMaster] empleadoRecibe on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	where persons.PersonId = @personId
		and isnull(p.Autorizado,0) = 0
		and isnull(p.ComandaImpresa, 0) = 1
		and isnull(p.Cancelada,0) = 0
	
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
					FROM [Comedor].[tblDetallePedidoMenus] dpm 
					WHERE dpm.IDPedido = p.IDPedido
					FOR xml path('')
				)
				, 1
				, 1
				, ''), 'El pedido no tiene menús')	
	from [Comedor].[tblPedidos] p with (nolock)
		join [Comedor].[tblCatRestaurantes] restaurantes on restaurantes.IDRestaurante = p.IDRestaurante and isnull(restaurantes.Disponible,0) = 1
		join AzureCognitiveServices.tblPersons persons with (nolock) on persons.IDEmpleado = p.IDEmpleadoRecibe
		join [RH].[tblEmpleadosMaster] empleado on empleado.IDEmpleado = p.IDEmpleado
		left join [RH].[tblEmpleadosMaster] empleadoRecibe on empleadoRecibe.IDEmpleado = p.IDEmpleadoRecibe
	where persons.PersonId = @personId
		and isnull(p.Autorizado,0) = 0
		and isnull(p.ComandaImpresa, 0) = 1
		and isnull(p.Cancelada,0) = 0

	select e.*, @personId as PersonId
	from AzureCognitiveServices.tblPersons p with (nolock)
		join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = p.IDEmpleado
	where p.PersonId = @personId

		--update Comedor.tblPedidos
		--set ComandaImpresa = 1
		--where IDPedido in (5,6)
GO
