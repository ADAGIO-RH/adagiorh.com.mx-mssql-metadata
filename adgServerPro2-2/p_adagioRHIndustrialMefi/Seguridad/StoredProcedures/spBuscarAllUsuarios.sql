USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarAllUsuarios] 
as
	select 
		IDUsuario, 
		e.IDEmpleado,
		Cuenta,
		[Password],
		FORMAT(e.FechaNacimiento, 'ddMMyyyy') as FechaNacimiento, 
		isnull(Activo, 0) as Activo,
		(
			Select 
				ee.IDEmpleado,
				ee.ClaveEmpleado,
				ee.FechaNacimiento,
				ee.RFC
			from RH.tblEmpleados ee
			where ee.IDEmpleado = e.IDEmpleado
			for json auto, without_array_wrapper
		) as Empleado
	--INTO bk.tblTempUsuarios_20230511
	from RH.tblEmpleadosMaster e  
		left join Seguridad.tblUsuarios u on e.IDEmpleado = u.IDEmpleado   
	--where IDPerfil = 2
	order by Cuenta
GO
