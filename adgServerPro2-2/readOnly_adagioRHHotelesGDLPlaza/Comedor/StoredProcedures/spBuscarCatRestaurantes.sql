USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBuscarCatRestaurantes](@IDRestaurante   int = 0
											   ,@SoloDisponibles bit = 0
											   ,@IDUsuario       int
											   )
as
	 select 
			[R].[IDRestaurante]
		   ,[R].[Nombre]
		   ,isnull([R].[Disponible],0) as [Disponible]
	  from [Comedor].[tblCatRestaurantes] [R] with(nolock)
	  where([R].[IDRestaurante] = @IDRestaurante
			or isnull(@IDRestaurante,0) = 0)
		   and (isnull([R].[Disponible],0) = case
												 when @SoloDisponibles = 1
												 then 1
												 else isnull([R].[Disponible],0)
											 end);
GO
