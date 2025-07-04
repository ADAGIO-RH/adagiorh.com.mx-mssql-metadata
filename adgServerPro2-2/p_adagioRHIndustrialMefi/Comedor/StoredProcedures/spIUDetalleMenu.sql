USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spIUDetalleMenu](@IDDetalleMenu int   = 0
									   ,@IDMenu        int
									   ,@IDArticulo    int
									   ,@Cantidad      int
									   ,@PrecioExtra   money
									   ,@IDUsuario     int
									   )
as
	 if(isnull(@IDDetalleMenu,0) = 0)
		 begin
			 insert into [Comedor].[tblDetalleMenu](
					[IDMenu]
				   ,[IDArticulo]
				   ,[Cantidad]
				   ,[PrecioExtra])
			 select 
					@IDMenu
				   ,@IDArticulo
				   ,@Cantidad
				   ,@PrecioExtra;
		 end;
		 else
		 begin
			 update [Comedor].[tblDetalleMenu]
			   set 
				   [Cantidad] = @Cantidad,
				   [PrecioExtra] = @PrecioExtra
			 where 
				   [IDDetalleMenu] = @IDDetalleMenu;
		 end;
GO
