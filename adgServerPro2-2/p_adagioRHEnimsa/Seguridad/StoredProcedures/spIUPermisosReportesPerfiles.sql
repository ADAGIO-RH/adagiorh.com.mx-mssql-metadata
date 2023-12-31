USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Seguridad.spIUPermisosReportesPerfiles(
	@IDItem int
	,@IDPerfil int
	,@Acceso bit
	,@IDUsuario int
) as

	declare @IDCarpeta int = 0;

	declare @temp table (
		IDPermisoReportePerfil int
		,IDPerfil int
		,IDItem int
		,Acceso bit
	)

	if exists (select top 1 1 
				from Seguridad.tblPermisosReportesPerfiles
				where IDItem = @IDItem and IDPerfil = @IDPerfil)
	begin
		update Seguridad.tblPermisosReportesPerfiles
			set Acceso = @Acceso
		where IDItem = @IDItem and IDPerfil = @IDPerfil
	end else 
	begin
		insert Seguridad.tblPermisosReportesPerfiles(IDPerfil,IDItem,Acceso)
		select @IDPerfil,@IDItem,@Acceso
	end;

	if exists (select top 1 1 
				from Reportes.tblCatReportes
				where IDItem = @IDItem and IDCarpeta = 0)
	begin
		insert @temp
		select
			 isnull(prp.IDPermisoReportePerfil,0) as IDPermisoReportePerfil
			,isnull(@IDPerfil,0) as IDPerfil
			,ISNULL(cr.IDItem,0) as IDItem
			,ISNULL(prp.Acceso,0) as Acceso
		from Reportes.tblCatReportes  cr
			left join Seguridad.tblPermisosReportesPerfiles prp on cr.IDItem = prp.IDItem and prp.IDPerfil = @IDPerfil
		where cr.IDCarpeta = @IDItem

		MERGE Seguridad.tblPermisosReportesPerfiles AS TARGET
		USING @temp as SOURCE
		on TARGET.IDPermisoReportePerfil = SOURCE.IDPermisoReportePerfil
			and TARGET.IDPerfil = SOURCE.IDPerfil
			and TARGET.IDItem = SOURCE.IDItem
		WHEN MATCHED THEN
			update 
				set TARGET.Acceso = @Acceso
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDPerfil,IDItem,Acceso)
			values(SOURCE.IDPerfil,SOURCE.IDItem, @Acceso)
		;

	end else 
	begin
		select @IDCarpeta = IDCarpeta
		from Reportes.tblCatReportes
		where IDItem = @IDItem

		if exists(select top 1 1 
					from Seguridad.tblPermisosReportesPerfiles
					where IDItem = @IDCarpeta and IDPerfil = @IDPerfil)
		begin
			if (@Acceso = 1)
			begin
				update Seguridad.tblPermisosReportesPerfiles
				set Acceso = @Acceso
				where IDItem = @IDCarpeta and IDPerfil = @IDPerfil
			end 
		end else
		begin
			if (@Acceso = 1)
			begin
				insert Seguridad.tblPermisosReportesPerfiles(IDPerfil,IDItem,Acceso)
				select @IDPerfil,@IDCarpeta,@Acceso
			end
		
		end;
	
	end;
GO
