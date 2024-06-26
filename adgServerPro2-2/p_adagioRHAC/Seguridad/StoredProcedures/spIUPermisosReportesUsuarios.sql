USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Seguridad].[spIUPermisosReportesUsuarios] --'Asistencia',20, 3914, 1, 1
(
	@IDAplicacion nvarchar(200) = null
	,@IDReporteBasico int = 0
	,@IDUsuario int
	,@Acceso bit
	,@IDUsuarioLogin int
) as

	declare @IDCarpeta int = 0;

	declare @temp table (
		IDPermisoReporteUsuario int
		,IDUsuario int
		,IDReporteBasico int
		,Acceso bit
	)


	if (ISNULL(@IDAplicacion, '') = '')
	begin
		if exists (select top 1 1 
					from Seguridad.tblPermisosReportesUsuarios
					where  IDReporteBasico = @IDReporteBasico and IDUsuario = @IDUsuario)
		begin
			update Seguridad.tblPermisosReportesUsuarios
				set Acceso = @Acceso,
					PermisoPersonalizado = 1
			where IDReporteBasico = @IDReporteBasico and IDUsuario = @IDUsuario
		end else 
		begin
			insert Seguridad.tblPermisosReportesUsuarios(IDUsuario,IDReporteBasico,Acceso, PermisoPersonalizado)
			select @IDUsuario,@IDReporteBasico,@Acceso, 1
		end;
	end else
	begin
		insert @temp
		select
			 isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
			,isnull(@IDUsuario,0) as IDUsuario
			,ISNULL(cr.IDReporteBasico,0) as IDReporteBasico
			,ISNULL(prp.Acceso,0) as Acceso
		from Reportes.tblCatReportesBasicos  cr
			left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDReporteBasico = prp.IDReporteBasico and prp.IDUsuario = @IDUsuario
		where cr.IDAplicacion = @IDAplicacion
		and ((cr.IDReporteBasico = @IDReporteBasico) or isnull(@IDReporteBasico,0) = 0 )

		MERGE Seguridad.tblPermisosReportesUsuarios AS TARGET
		USING @temp as SOURCE
		on TARGET.IDPermisoReporteUsuario = SOURCE.IDPermisoReporteUsuario
			and TARGET.IDUsuario = SOURCE.IDUsuario
			and TARGET.IDReporteBasico = SOURCE.IDReporteBasico
		WHEN MATCHED THEN
			update 
				set TARGET.Acceso = @Acceso,
					TARGET.PermisoPersonalizado = 1
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDUsuario,IDReporteBasico,Acceso, PermisoPersonalizado)
			values(SOURCE.IDUsuario,SOURCE.IDReporteBasico, @Acceso, 1)
		;

	end


	--select * from Seguridad.tblPermisosUsuarioControllers
GO
