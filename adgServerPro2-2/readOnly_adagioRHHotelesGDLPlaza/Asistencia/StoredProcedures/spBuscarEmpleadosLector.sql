USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los lectores de los empleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosLector]  (  
 @IDLector int  
 ,@IDUsuario int
)  
AS  
BEGIN  
	SELECT   
		le.IDLectorEmpleado  
		,em.IDEmpleado  
		,em.ClaveEmpleado  
		,em.NOMBRECOMPLETO  
		,em.Puesto  
		,em.Departamento  
		,em.Sucursal  
		,l.IDLector as IDLector  
		,l.Lector as Lector   
	FROM rh.tblEmpleadosMaster em with (nolock)
		inner join Asistencia.tblLectoresEmpleados le with (nolock) on em.IDEmpleado = le.IDEmpleado  
		inner join Asistencia.tblLectores l with (nolock) on le.IDLector = l.IDLector  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where l.IDLector = @IDLector  
END;
GO
