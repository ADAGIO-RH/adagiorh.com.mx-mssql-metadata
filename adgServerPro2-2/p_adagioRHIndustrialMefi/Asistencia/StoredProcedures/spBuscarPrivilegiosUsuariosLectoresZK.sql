USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spBuscarPrivilegiosUsuariosLectoresZK](
	@IDPrivilegioUsuarioLectorZK int = 0,
	@IDLector int = 0,
	@IDEmpleado int = 0,
	@IDUsuario int
) as
begin
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')	
	
	select 
		plul.IDPrivilegioUsuarioLectorZK,
		plul.[IDTipoPrivilegioLectorZK],
		l.IDLector,
		l.CodigoLector,
		l.Lector,
		cpl.Nombre as TipoPrivilegio,
		emp.ClaveEmpleado,
		emp.NOMBRECOMPLETO as Colaborador,
		case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador
	from Asistencia.tblPrivilegiosUsuarioLectoresZk plul
		join Asistencia.tblLectores l on l.IDLector = plul.IDLector
		join Asistencia.fnBuscarCatTiposPrivilegiosLectoresZK(@IDIdioma) cpl on plul.[IDTipoPrivilegioLectorZK] = cpl.[IDTipoPrivilegioLectorZK]
		join RH.tblEmpleadosMaster emp on emp.IDEmpleado = plul.IDEmpleado
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = plul.IDEmpleado
	where 
		(plul.IDPrivilegioUsuarioLectorZK = @IDPrivilegioUsuarioLectorZk or isnull(@IDPrivilegioUsuarioLectorZk, 0) = 0)
		and (plul.IDLector = @IDLector or isnull(@IDLector, 0) = 0)
		and (plul.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado, 0) = 0)
end
GO
