USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarUsuarioPasswordDefault](  
	@IDUsuario int
) AS              
BEGIN              
	
    Select 
        U.IDEmpleado,
        U.IDUsuario,
        m.RFC,
        m.FechaNacimiento,
        m.ClaveEmpleado
        from Seguridad.tblUsuarios  u
    left join RH.tblEmpleadosMaster m on u.IDEmpleado=m.IDEmpleado
    where u.IDUsuario=@IDUsuario
END
GO
