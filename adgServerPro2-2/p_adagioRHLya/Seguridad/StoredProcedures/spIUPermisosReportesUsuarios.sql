USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Seguridad.spIUPermisosReportesUsuarios(
	@IDItem int
	,@IDUsuario int
	,@Acceso bit
	,@IDUsuarioLogin int
) as

	declare @IDCarpeta int = 0;

	declare @temp table (
		IDPermisoReporteUsuario int
		,IDUsuario int
		,IDItem int
		,Acceso bit
	)

	if exists (select top 1 1 
				from Seguridad.tblPermisosReportesUsuarios
				where IDItem = @IDItem and IDUsuario = @IDUsuario)
	begin
		update Seguridad.tblPermisosReportesUsuarios
			set Acceso = @Acceso
		where IDItem = @IDItem and IDUsuario = @IDUsuario
	end else 
	begin
		insert Seguridad.tblPermisosReportesUsuarios(IDUsuario,IDItem,Acceso)
		select @IDUsuario,@IDItem,@Acceso
	end;

	if exists (select top 1 1 
				from Reportes.tblCatReportes
				where IDItem = @IDItem and IDCarpeta = 0)
	begin
		insert @temp
		select
			 isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
			,isnull(@IDUsuario,0) as IDUsuario
			,ISNULL(cr.IDItem,0) as IDItem
			,ISNULL(prp.Acceso,0) as Acceso
		from Reportes.tblCatReportes  cr
			left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDItem = prp.IDItem and prp.IDUsuario = @IDUsuario
		where cr.IDCarpeta = @IDItem

		MERGE Seguridad.tblPermisosReportesUsuarios AS TARGET
		USING @temp as SOURCE
		on TARGET.IDPermisoReporteUsuario = SOURCE.IDPermisoReporteUsuario
			and TARGET.IDUsuario = SOURCE.IDUsuario
			and TARGET.IDItem = SOURCE.IDItem
		WHEN MATCHED THEN
			update 
				set TARGET.Acceso = @Acceso
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDUsuario,IDItem,Acceso)
			values(SOURCE.IDUsuario,SOURCE.IDItem, @Acceso)
		;

	end else 
	begin
		select @IDCarpeta = IDCarpeta
		from Reportes.tblCatReportes
		where IDItem = @IDItem

		if exists(select top 1 1 
					from Seguridad.tblPermisosReportesUsuarios
					where IDItem = @IDCarpeta and IDUsuario = @IDUsuario)
		begin
			if (@Acceso = 1)
			begin
				update Seguridad.tblPermisosReportesPerfiles
				set Acceso = @Acceso
				where IDItem = @IDCarpeta and IDPerfil = @IDUsuario
			end 
		end else
		begin
			if (@Acceso = 1)
			begin
				insert Seguridad.tblPermisosReportesUsuarios(IDUsuario,IDItem,Acceso)
				select @IDUsuario,@IDCarpeta,@Acceso
			end
		end;
	end;
GO
