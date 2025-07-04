USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spIUEstatusArticulos](
	@IDUsuario int,
	@IDCatEstatusArticulo int,
	@IDEstatusArticulo int,
	@IDDetalleArticulo int,	
	@IDsEmpleados varchar(max)
)
as
begin
	declare @IDIdioma varchar(20) = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2
	--declare @UsoCompartido bit = (select UsoCompartido from ControlEquipos.tblArticulos where IDArticulo = @IDArticulo)
	--declare @IsAssinged bit = (select top 1 IsAsignado from ControlEquipos.tblEstatusArticulos where IDArticulo = @IDArticulo order by IDEstatusArticulo desc)

	BEGIN TRY
		--if(@IsAssinged = 1 and @UsoCompartido = 0 and @IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO)
		--begin
		--	raiserror('No puedes asignar este artículo a más de un colaborador',16,1)
		--end
		--if exists (select top 1 ea.Empleados from ControlEquipos.tblEstatusArticulos ea where @IDEmpleado in (select * from OPENJSON(Empleados, '$') with (IDEmpleado int)) and ea.IsAsignado = 1 and ea.IDArticulo = @IDArticulo order by FechaHora desc)
		--begin
		--	if(@IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO and @IsAsignado = 1)
		--	raiserror('Ya has asignado este artículo a este colaborador',16,1)
		--end

		if not exists(select top 1 1 from ControlEquipos.tblEstatusArticulos where IDEstatusArticulo = @IDEstatusArticulo)
		begin
			begin tran crearRegistro

			insert into ControlEquipos.tblEstatusArticulos(IDCatEstatusArticulo, IDDetalleArticulo, Empleados, FechaHora, IDUsuario)
			values(@IDCatEstatusArticulo, @IDDetalleArticulo, @IDsEmpleados, GETDATE(), @IDUsuario)

			if @@ROWCOUNT = 1
				commit tran crearRegistro
			else
				rollback tran crearRegistro
		end
		else
		begin
			begin tran actualizarRegistro
			
			update ControlEquipos.tblEstatusArticulos
			set
				IDCatEstatusArticulo = @IDCatEstatusArticulo,
				Empleados=@IDsEmpleados,
				FechaHora            = GETDATE(),
				--IsAsignado           = @IsAsignado,
				IDUsuario			 = @IDUsuario
			where IDEstatusArticulo  = @IDEstatusArticulo

			if @@ROWCOUNT = 1
				commit tran actualizarRegistro
			else
				rollback tran actualizarRegistro
		end
	END TRY
	BEGIN CATCH
		--ROLLBACK TRAN
		declare @Error varchar(max) = ERROR_MESSAGE()
		raiserror(@Error, 16,1)
	END CATCH
end
GO
