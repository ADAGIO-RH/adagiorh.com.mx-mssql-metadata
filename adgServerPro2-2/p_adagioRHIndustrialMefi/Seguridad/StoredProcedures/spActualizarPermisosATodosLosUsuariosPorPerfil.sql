USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from Seguridad.tblCatPerfiles

create proc [Seguridad].[spActualizarPermisosATodosLosUsuariosPorPerfil](
	@IDPerfil int
) as
--declare @IDPerfil int = 1 ;

	declare @i int = 0;

	if object_id('tempdb..#tempUsuarios') is not null
		drop table #tempUsuarios;

	select IDUsuario
	INTO #tempUsuarios
	from [Seguridad].[tblUsuarios]
	where IDPerfil = @IDPerfil

	select @i = min(IDUsuario) from #tempUsuarios
	while exists(select top 1 1 
				from #tempUsuarios where IDUsuario >= @i)
	begin
		exec [Seguridad].[spTransferirPermisosPerfilUsuario] @IDUsuario = @i,@IDPerfil = @IDPerfil

		select @i = min(IDUsuario) from #tempUsuarios where IDUsuario > @i
	end;
GO
