USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spIUPermisosReportesPerfiles](
	@IDAplicacion nvarchar(200) = null
	,@IDReporteBasico int = 0
	,@IDPerfil int
	,@Acceso bit
	,@IDUsuario int
) as

	declare @IDCarpeta int = 0;

	declare @temp table (
		IDPermisoReportePerfil int
		,IDPerfil int
		,IDReporteBasico int
		,Acceso bit
	)
    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
    
	if (ISNULL(@IDAplicacion, '') = '')
	begin
		if exists (select top 1 1 
					from Seguridad.tblPermisosReportesPerfiles
					where IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil)
		begin

             Select @OldJSON = (SELECT * FROM Seguridad.tblPermisosReportesPerfiles WHERE IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
			
            update Seguridad.tblPermisosReportesPerfiles
				set Acceso = @Acceso
			where IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil

                 Select @NewJSON = (SELECT * FROM Seguridad.tblPermisosReportesPerfiles WHERE IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosReportesPerfiles]','[Seguridad].[spIUPermisosReportesPerfiles]','UPDATE',@NewJSON,@OldJSON


		end else 
		begin
			insert Seguridad.tblPermisosReportesPerfiles(IDPerfil,IDReporteBasico,Acceso)
			select @IDPerfil,@IDReporteBasico,@Acceso

             Select @NewJSON = (SELECT * FROM Seguridad.tblPermisosReportesPerfiles WHERE IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosReportesPerfiles]','[Seguridad].[spIUPermisosReportesPerfiles]','INSERT',@NewJSON,''

		end;
	end else
	begin

      SELECT @OldJSON = (SELECT * FROM Seguridad.tblPermisosReportesPerfiles WHERE IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
		insert @temp
		select
			 isnull(prp.IDPermisoReportePerfil,0) as IDPermisoReportePerfil
			,isnull(@IDPerfil,0) as IDPerfil
			,ISNULL(cr.IDReporteBasico,0) as IDReporteBasico
			,ISNULL(prp.Acceso,0) as Acceso
		from Reportes.tblCatReportesBasicos  cr
			left join Seguridad.tblPermisosReportesPerfiles prp on cr.IDReporteBasico = prp.IDReporteBasico and prp.IDPerfil = @IDPerfil
		where cr.IDAplicacion = @IDAplicacion
		and ((cr.IDReporteBasico = @IDReporteBasico) or isnull(@IDReporteBasico,0) = 0 )

		MERGE Seguridad.tblPermisosReportesPerfiles AS TARGET
		USING @temp as SOURCE
		on TARGET.IDPermisoReportePerfil = SOURCE.IDPermisoReportePerfil
			and TARGET.IDPerfil = SOURCE.IDPerfil
			and TARGET.IDReporteBasico = SOURCE.IDReporteBasico
		WHEN MATCHED THEN
			update 
				set TARGET.Acceso = @Acceso
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDPerfil,IDReporteBasico,Acceso)
			values(SOURCE.IDPerfil,SOURCE.IDReporteBasico, @Acceso)
		;

            SELECT @NewJSON = (SELECT * FROM Seguridad.tblPermisosReportesPerfiles WHERE IDReporteBasico = @IDReporteBasico and IDPerfil = @IDPerfil FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);


            EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Seguridad].[tblPermisosReportesUsuarios]', '[Seguridad].[spIUPermisosReportesPerfiles]', 'MERGE', @NewJSON, @OldJSON;
	
	end
GO
