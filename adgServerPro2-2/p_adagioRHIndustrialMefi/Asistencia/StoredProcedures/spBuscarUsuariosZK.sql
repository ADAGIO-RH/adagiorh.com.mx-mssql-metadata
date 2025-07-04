USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS USUARIOS ZK
** Autor			: DENZEL OVANDO
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2021-11-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

-- [Asistencia].[spBuscarUsuariosZK] 1279

CREATE PROCEDURE [Asistencia].[spBuscarUsuariosZK](
	 @IDEmpleado int = 0
)
AS
BEGIN

	SELECT [IDUsuarioZK]
		  ,emp.[IDEmpleado]
		  ,[IDLector]
		  ,cast(stuff(emp.ClaveEmpleado, 1, patindex('%[0-9]%', emp.ClaveEmpleado)-1, '') as int) as [EnrollNumber] 
		  --,case when u.NombreUsuario is null
				--then concat(emp.Nombre , ' ', emp.Paterno)
				--end as [NombreUsuario]
		  ,coalesce(emp.Nombre,'')+' '+coalesce(emp.Paterno, '') as  [NombreUsuario]
		  ,isnull(u.[Password], '') as [Password]
		  ,isnull(u.[NumeroTarjeta], '0') as [NumeroTarjeta] 
		  ,isnull(u.[Grupo], '0') as [Grupo] 
		  ,isnull(u.[TimeZone], '0') as [TimeZone] 
		  ,isnull(u.[Privilegio], '0') as [Privilegio] 
	  FROM RH.tblEmpleados emp
		left join [Asistencia].[tblUsuariosZK]  u on u.IDEmpleado = emp.IDEmpleado
	   WHERE emp.[IDEmpleado] = @IDEmpleado or ISNULL(@IDEmpleado,0) = 0



END
GO
