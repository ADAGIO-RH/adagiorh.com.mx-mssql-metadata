USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spIUArticulo](
	@IDArticulo int = 0
	,@IDEmpleado int
	,@IDTipoArticulo int
	,@IDUsuario int
)as
begin

	if (@IDArticulo = 0)
	begin
		insert [Resguardo].[tblArticulos](IDEmpleado,IDTipoArticulo)
		values(@IDEmpleado,@IDTipoArticulo)

		set @IDArticulo = @@IDENTITY

		insert into [Resguardo].[tblCatPropiedadesArticulos](TipoReferencia,IDReferencia,IDTipoPropiedad,Nombre,CopiadaDelIDPropiedad)
		select 1 as TipoReferencia,@IDArticulo as IDReferencia,IDTipoPropiedad,Nombre,IDPropiedad
		from [Resguardo].[tblCatPropiedadesArticulos]
		where TipoReferencia = 0 and IDReferencia = @IDTipoArticulo

	end else
	begin
		update [Resguardo].[tblArticulos]
			set IDTipoArticulo = @IDTipoArticulo
		where IDArticulo = @IDArticulo
	end

	exec [Resguardo].[spBuscarArticulos] 
		 @IDArticulo = @IDArticulo
		,@IDUsuario	 = @IDUsuario
end
GO
