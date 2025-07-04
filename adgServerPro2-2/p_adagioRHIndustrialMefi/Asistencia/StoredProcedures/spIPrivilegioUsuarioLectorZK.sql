USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIPrivilegioUsuarioLectorZK](
	@IDPrivilegioUsuarioLectorZK int = 0,	
	@IDLector int,
	@IDTipoPrivilegioLectorZK int,	
	@IDEmpleado int,
	@IDUsuario int
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),	
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')	

	if (isnull(@IDPrivilegioUsuarioLectorZK, 0) = 0)
	begin
		if exists(
			select top 1 1
			from  Asistencia.tblPrivilegiosUsuarioLectoresZK
			where IDEmpleado = @IDEmpleado and IDLector = @IDLector)
		begin
			raiserror('El colaborador ya está asignado a este lector', 16, 1)
			return 
		end

		insert Asistencia.tblPrivilegiosUsuarioLectoresZK([IDTipoPrivilegioLectorZK], IDLector, IDEmpleado)
		values(@IDTipoPrivilegioLectorZK, @IDLector, @IDEmpleado)

		set @IDPrivilegioUsuarioLectorZK = @@IDENTITY

		select @NewJSON = (
			select *
			from(
				select 
					plul.IDPrivilegioUsuarioLectorZK,
					plul.[IDTipoPrivilegioLectorZK],
					l.CodigoLector,
					l.Lector,
					cpl.Nombre as TipoPrivilegio,
					emp.ClaveEmpleado,
					emp.NOMBRECOMPLETO as Colaborador
				from Asistencia.tblPrivilegiosUsuarioLectoresZK plul
					join Asistencia.tblLectores l on l.IDLector = plul.IDLector
					join Asistencia.fnBuscarCatTiposPrivilegiosLectoresZK(@IDIdioma) cpl on plul.[IDTipoPrivilegioLectorZK] = cpl.[IDTipoPrivilegioLectorZK]
					join RH.tblEmpleadosMaster emp on emp.IDEmpleado = plul.IDEmpleado
				where plul.IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZK
			) as info
			for json auto, WITHOUT_ARRAY_WRAPPER
		)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPrivilegiosUsuarioLectoresZK]','[Asistencia].[spIPrivilegioUsuarioLectorZK]','INSERT',@NewJSON,''
	end else
	begin
		select @OldJSON = (
			select *
			from(
				select 
					plul.IDPrivilegioUsuarioLectorZK,
					plul.[IDTipoPrivilegioLectorZK],
					l.CodigoLector,
					l.Lector,
					cpl.Nombre as TipoPrivilegio,
					emp.ClaveEmpleado,
					emp.NOMBRECOMPLETO as Colaborador
				from Asistencia.tblPrivilegiosUsuarioLectoresZK plul
					join Asistencia.tblLectores l on l.IDLector = plul.IDLector
					join Asistencia.fnBuscarCatTiposPrivilegiosLectoresZK(@IDIdioma) cpl on plul.[IDTipoPrivilegioLectorZK] = cpl.[IDTipoPrivilegioLectorZK]
					join RH.tblEmpleadosMaster emp on emp.IDEmpleado = plul.IDEmpleado
				where plul.IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZK
			) as info
			for json auto, WITHOUT_ARRAY_WRAPPER
		)

		update Asistencia.tblPrivilegiosUsuarioLectoresZK
			set 
				[IDTipoPrivilegioLectorZK] = @IDTipoPrivilegioLectorZK
		where IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZK

		select @NewJSON = (
			select *
			from(
				select 
					plul.IDPrivilegioUsuarioLectorZK,
					plul.[IDTipoPrivilegioLectorZK],
					l.CodigoLector,
					l.Lector,
					cpl.Nombre as TipoPrivilegio,
					emp.ClaveEmpleado,
					emp.NOMBRECOMPLETO as Colaborador
				from Asistencia.tblPrivilegiosUsuarioLectoresZK plul
					join Asistencia.tblLectores l on l.IDLector = plul.IDLector
					join Asistencia.fnBuscarCatTiposPrivilegiosLectoresZK(@IDIdioma) cpl on plul.[IDTipoPrivilegioLectorZK] = cpl.[IDTipoPrivilegioLectorZK]
					join RH.tblEmpleadosMaster emp on emp.IDEmpleado = plul.IDEmpleado
				where plul.IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZK
			) as info
			for json auto, WITHOUT_ARRAY_WRAPPER
		)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPrivilegiosUsuarioLectoresZK]','[Asistencia].[spIPrivilegioUsuarioLectorZK]','UPDATE', @NewJSON, @OldJSON
	end

	exec [zkteco].[spActualizarEmpleadoEnLector] @IDLector = @IDLector, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
GO
