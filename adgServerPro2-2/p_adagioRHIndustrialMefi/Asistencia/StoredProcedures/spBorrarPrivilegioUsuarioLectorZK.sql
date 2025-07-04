USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Asistencia.spBorrarPrivilegioUsuarioLectorZK(
	@IDPrivilegioUsuarioLectorZK int,
	@IDUsuario int
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),	
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')	

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

	delete from Asistencia.tblPrivilegiosUsuarioLectoresZK 
	where IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZK

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPrivilegiosUsuarioLectoresZK]','[Asistencia].[spBorrarPrivilegioUsuarioLectorZK]','DELETE', @NewJSON, @OldJSON
GO
