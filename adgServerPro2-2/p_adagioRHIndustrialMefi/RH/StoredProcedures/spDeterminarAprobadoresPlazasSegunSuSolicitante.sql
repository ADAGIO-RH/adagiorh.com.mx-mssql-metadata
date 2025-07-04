USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los aprobadores de una plaza según el solicitante de la plaza
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2022-01-30
** Paremetros		:              


ResultSet Structure:
	IDUsuario
	Usuario
	Orden

	RH.spDeterminarAprobadoresPlazasSegunSuSolicitante 39,1
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc RH.spDeterminarAprobadoresPlazasSegunSuSolicitante (
	@IDPlaza int,
	@IDUsuarioSolicitante int
) as

	declare
		@IDCliente int,
		@IDEmpleado int
	;

	select @IDCliente = IDCliente
	from RH.tblCatPlazas
	where IDPlaza = @IDPlaza

	select @IDEmpleado = IDEmpleado
	from Seguridad.tblUsuarios
	where IDUsuario = @IDUsuarioSolicitante

	select * 
	from (
		select top 1
			u.IDUsuario,
			 coalesce(u.Nombre, '')+' '+ coalesce(u.Apellido, '') as Usuario,
			 1 as Orden
		from RH.tblJefesEmpleados je
			join RH.tblEmpleadosMaster e on e.IDEmpleado = je.IDJefe
			join Seguridad.tblUsuarios u on u.IDEmpleado = je.IDJefe
		where je.IDEmpleado = @IDEmpleado
		UNION ALL
		select appp.IDUsuario, coalesce(u.Nombre, '')+' '+ coalesce(u.Apellido, '') as Usuario, ISNULL(appp.Orden, 0) + 1
		from RH.tblAprobadoresPredeterminadosPlazasPosiciones appp
			join Seguridad.tblUsuarios u on u.IDUsuario = appp.IDUsuario
		where appp.IDCliente = @IDCliente
	) info
	order by Orden asc
GO
