USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spIUCatRestaurante](@IDRestaurante int          = 0
										  ,@Nombre        varchar(255)
										  ,@Disponible    bit
										  ,@IDUsuario     int
										  )
as
	 if(isnull(@IDRestaurante,0) = 0)
		 begin
			 insert into [Comedor].[tblCatRestaurantes](
					[Nombre]
				   ,[Disponible])
			 values
				(
					upper(@Nombre)
				   ,@Disponible
				);
		 end;
		 else
		 begin
			 update [Comedor].[tblCatRestaurantes]
			   set 
				   [Nombre] = upper(@Nombre),
				   [Disponible] = @Disponible
			 where 
				   [IDRestaurante] = @IDRestaurante;
		 end;
GO
