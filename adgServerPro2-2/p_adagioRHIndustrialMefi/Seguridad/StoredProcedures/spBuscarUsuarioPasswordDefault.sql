USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las password default en base al IDUsuario, con este ID obtendra el IDEmpleado donde se toman los datos para las password default.                                            
** Autor			: José Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-07-29
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
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
