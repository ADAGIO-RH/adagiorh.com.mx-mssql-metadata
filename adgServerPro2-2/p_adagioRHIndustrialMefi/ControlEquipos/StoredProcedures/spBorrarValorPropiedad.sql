USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spBorrarValorPropiedad](
	@IDValorPropiedad int
)
as
begin
	if exists(select top 1 1 from [ControlEquipos].[tblValoresPropiedades] where IDValorPropiedad = @IDValorPropiedad)
	begin
		delete from [ControlEquipos].[tblValoresPropiedades] where IDValorPropiedad = @IDValorPropiedad
	end
end
GO
