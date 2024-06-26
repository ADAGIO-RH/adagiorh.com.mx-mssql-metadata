USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarAllUsuarios] 
as
select IDUsuario, cuenta, FORMAT(e.FechaNacimiento, 'ddMMyyyy') as FechaNacimiento, Activo
from RH.tblEmpleadosMaster e  
 left join Seguridad.tblUsuarios u on e.IDEmpleado = u.IDEmpleado   
--where Cuenta ='1537'
where isnull(u.Activo,0) = 0
order by Cuenta
GO
