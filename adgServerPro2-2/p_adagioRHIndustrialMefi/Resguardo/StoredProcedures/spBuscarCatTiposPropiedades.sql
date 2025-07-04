USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spBuscarCatTiposPropiedades](
	@IDTipoPropiedad int = 0
	,@IDUsuario int
) as
begin
	select 
		ctp.IDTipoPropiedad
		,ctp.Nombre
	from [Resguardo].[tblCatTiposPropiedades] ctp with (nolock)
	where ctp.IDTipoPropiedad = @IDTipoPropiedad or @IDTipoPropiedad = 0
end
GO
