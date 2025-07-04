USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ControlEquipos].[spIArticuloPorPuesto](
	@IDArticulosPorPuesto int = 0
	,@IDPuesto int 
	,@IDArticulo int
    ,@CantidadArticulo int =0
	,@IDUsuario int
) as

	if exists(select top 1 1
			from ControlEquipos.tblArticulosPorPuesto
			where IDPuesto = @IDPuesto and IDArticulo = @IDArticulo)
	begin
		raiserror('El artículo ya está asignado al este puesto', 16, 1)
		return
	end

	insert ControlEquipos.tblArticulosPorPuesto(IDPuesto, IDArticulo, Cantidad)
	values(@IDPuesto, @IDArticulo,@CantidadArticulo)
GO
