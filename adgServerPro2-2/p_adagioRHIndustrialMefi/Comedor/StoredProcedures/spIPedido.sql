USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spIPedido](@IDRestaurante    int
								 ,@IDEmpleado       int
								 ,@IDEmpleadoRecibe int
								 ,@GrandTotal		decimal = 0
								 ,@dtDetallePedido  [Comedor].[dtDetallePedido] readonly
								 ,@dtOpcionesSeleccionadas [Comedor].[dtOpcionesArticulos] readonly
								 ,@dtOpcionesSeleccionadasArticulos [Comedor].[dtOpcionesArticulos] readonly
								 ,@NotaAutorizacion varchar(max) = null
								 ,@IDUsuario        int
								 )
as
	declare 
		@mensaje varchar(max)
		,@spCustomValidacionesPedidos Varchar(500)
		,@dtDetallePedidoParam  [Comedor].[dtDetallePedido] 
	;

	if exists(select top 1 1 
		from RH.tblEmpleadosMaster
		where IDEmpleado = @IDEmpleado and isnull(Vigente, 0 ) = 0)
	begin
		raiserror('El colaborador no está vigente.', 16, 1)
		return
	end

	select
		 @spCustomValidacionesPedidos	= isnull(config.Valor,'')
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN RH.[TblConfiguracionesCliente] config with (nolock) on config.IDCliente = e.IDCliente
			and config.IDTipoConfiguracionCliente = 'spCustomValidacionesPedidos'
	where e.IDEmpleado = @IDEmpleado 

	begin try
		begin tran [TransPedidos];
			declare 
				   @IDPedido        int
				  ,@SiguienteNumero int  = 0
				  ,@Fecha           date = getdate()
				  ,@Hora            time = getdate()
				  ,@ID int
				  ,@IDMenu int
				  ,@IDArticulo int
				  ,@IDMenuNuevo int
				  ,@IDArticuloNuevo int
				  ,@PrecioExtra money
				  ,@Cantidad int = 1
				  ,@IDDetallePedidoMenu int
				  ,@Nota varchar(500)
			;

			IF(@spCustomValidacionesPedidos <> '')
			BEGIN
				exec sp_executesql N'exec @miSP @IDRestaurante=@IDRestaurante
											,@IDEmpleado=@IDEmpleado
											, @IDEmpleadoRecibe=@IDEmpleadoRecibe
											, @GrandTotal=@GrandTotal
											, @dtDetallePedido=@dtDetallePedido
											, @IDUsuario=@IDUsuario'                   
					,N' 
						@IDRestaurante		int                   
						,@IDEmpleado		int   
						,@IDEmpleadoRecibe	int
						,@GrandTotal		money
						,@dtDetallePedido	[Comedor].[dtDetallePedido] readonly
						,@IDUsuario			int
						,@miSP				varchar(255)',                          
						@IDRestaurante		= @IDRestaurante
						,@IDEmpleado		= @IDEmpleado   
						,@IDEmpleadoRecibe	= @IDEmpleadoRecibe
						,@GrandTotal		= @GrandTotal
						,@dtDetallePedido	= @dtDetallePedido
						,@IDUsuario			= @IDUsuario
						,@miSP				= @spCustomValidacionesPedidos ;  
			END

			select 
				@SiguienteNumero =
				isnull(max([Numero]),0) + 1
			from [Comedor].[tblPedidos]
			where [FechaCreacion] = @Fecha and IDRestaurante = @IDRestaurante

			insert into [Comedor].[tblPedidos](
				   [Numero]
				  ,[IDRestaurante]
				  ,[IDEmpleado]
				  ,[IDEmpleadoRecibe]
				  ,[GrandTotal]
				  ,[NotaAutorizacion]
				  ,[FechaCreacion]
				  ,[HoraCreacion])
			select 
				   @SiguienteNumero
				  ,@IDRestaurante
				  ,@IDEmpleado
				  ,case when isnull(@IDEmpleadoRecibe,0) = 0 then null else @IDEmpleadorecibe end
				  ,@GrandTotal
				  ,@NotaAutorizacion
				  ,@Fecha
				  ,@Hora;

			set @IDPedido = @@Identity;

			if object_id('tempdb..#tempDetallePedido') is not null drop table #tempDetallePedido;
			create table #tempDetallePedido(
				ID int identity(1,1),
				IDDetallePedido int,
				IDPedido int,
				IDMenu int,
				IDArticulo int,
				Cantidad int not null,
				PrecioUnidad money not null,
				PrecioExtra money not null,
				Nota varchar(max)
			);

			insert [#tempDetallePedido]
			(
			    --ID - column value is auto-generated
			    [IDDetallePedido],
			    [IDPedido],
			    [IDMenu],
			    [IDArticulo],
				Cantidad,
				PrecioUnidad,
				PrecioExtra,
				Nota
			)
			select
				tdp.[IDDetallePedido], tdp.[IDPedido], tdp.[IDMenu], tdp.[IDArticulo],Cantidad,PrecioUnidad,PrecioExtra,Nota
			from @dtDetallePedido tdp

			select @ID = min(ID) from #tempDetallePedido

			while exists(select top 1 1 from #tempDetallePedido where ID >= @ID)
			begin
				select
					@IDMenu			= IDMenu,
					@IDArticulo		= IDArticulo,
					@Cantidad		= Cantidad,
					@PrecioExtra	= PrecioExtra,
					@Nota			= Nota
				from #tempDetallePedido
				where ID = @ID

				if (isnull(@IDMenu,0) > 0)
				begin
					insert into [Comedor].[tblDetallePedidoMenus](IDPedido,IDMenu,Nombre,Descripcion,Cantidad,PrecioUnidad,PrecioExtra,Notas)
					select @IDPedido,cm.IDMenu,cm.Nombre, cm.Descripcion,@Cantidad, cm.PrecioEmpleado,@PrecioExtra,@Nota
					from Comedor.tblCatMenus cm
					where cm.IDMenu = @IDMenu

					set @IDDetallePedidoMenu = @@Identity

					insert into [Comedor].[tblDetallePedidoMenusArticulos](IDDetallePedidoMenu,IDMenu,IDArticulo,Nombre,Descripcion,Cantidad,PrecioUnidad,PrecioExtra,IDOpcionArticulo,OpcionSeleccionada)
					select @IDDetallePedidoMenu,@IDMenu, dm.IDArticulo,ca.Nombre, ca.Descripcion,@Cantidad,ca.PrecioEmpleado,isnull(op.PrecioExtra,0),op.IDOpcionArticulo,op.Nombre
					from Comedor.tblDetalleMenu dm
						join Comedor.tblCatArticulos ca on ca.IDArticulo = dm.IDArticulo
						left join @dtOpcionesSeleccionadas op on op.IDMenu = dm.IDMenu and op.IDArticulo = ca.IDArticulo
					where dm.IDMenu = @IDMenu
				end else 
				if (isnull(@IDArticulo,0) > 0)
				begin
					insert [Comedor].[tblDetallePedidoArticulos](IDPedido,IDArticulo, Nombre, Descripcion, Cantidad,PrecioUnidad, PrecioExtra,IDOpcionArticulo, OpcionSeleccionada, Notas)
					select @IDPedido, a.IDArticulo, a.Nombre, a.Descripcion, 1, a.PrecioEmpleado, isnull(@PrecioExtra,0), osa.IDOpcionArticulo, osa.Nombre,@Nota
					from [Comedor].[tblCatArticulos] a
						left join  @dtOpcionesSeleccionadasArticulos osa on osa.IDArticulo = a.IDArticulo
					where a.IDArticulo = @IDArticulo
				end	

				select @ID = min(ID) from #tempDetallePedido where ID > @ID
			end
		commit tran [TransPedidos];

		select @IDPedido as IDPedido, @SiguienteNumero as Numero
	end try
	begin catch
		rollback tran [TransPedidos];
		select @mensaje = error_message()

		raiserror(@mensaje, 16, 1)
	end catch;
GO
