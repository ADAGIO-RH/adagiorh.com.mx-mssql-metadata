USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spIHistorial](
	 @IDLocker int
	,@IDEmpleado int
	,@IDArticulo int
	,@IDUsuario int
) as

	declare 
		@IDHistorial int
	;

	if exists(select top 1 1 from [Resguardo].[tblCatLockers] where IDLocker = @IDLocker and isnull(Disponible,0) = 0)
	begin
		raiserror('El Locker se encuentra ocupado, favor de seleccionar otro.',16,1)
		return
	end

	insert [Resguardo].[tblHistorial](IDLocker,IDEmpleado,IDArticulo,FechaRecibe,Entregado,IDUsuarioRecibe)
	select @IDLocker,@IDEmpleado,@IDArticulo,getdate(),0,@IDUsuario

	set @IDHistorial = @@IDENTITY

	update [Resguardo].[tblCatLockers]
		set Disponible = 0
	where IDLocker = @IDLocker

	select @IDHistorial as IDHistorial
GO
