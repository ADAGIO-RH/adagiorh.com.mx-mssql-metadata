USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Resguardo].[spULockerActivoDisponible](
	@IDLocker int
	,@Valor bit
	,@Campo varchar(10)
	,@IDUsuario int
) as

	if (@Campo = 'Activo')
	begin
		update [Resguardo].[tblCatLockers]
			set Activo = @Valor
		where IDLocker = @IDLocker
	end else
	begin
		update [Resguardo].[tblCatLockers]
			set Disponible = @Valor
		where IDLocker = @IDLocker
	end;
GO
