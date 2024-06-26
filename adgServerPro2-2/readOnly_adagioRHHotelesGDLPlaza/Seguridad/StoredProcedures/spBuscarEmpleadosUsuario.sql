USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Empleados Usuarios
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
CREATE proc [Seguridad].[spBuscarEmpleadosUsuario](      
	@IDUsuario int
	,@IDDetalleFiltrosEmpleadosUsuarios int = null      
	,@Filtro  varchar(255)   = null      
) as      
	 SET LANGUAGE 'Spanish';      
      
	 select DFEU.IDDetalleFiltrosEmpleadosUsuarios      
		,DFEU.IDUsuario      
		,DFEU.IDEmpleado      
		,em.ClaveEmpleado      
		,em.NOMBRECOMPLETO      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Empleados') as Filtro      
	 from [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] DFEU      
		  join [RH].[tblEmpleadosMaster] em on DFEU.IDEmpleado = em.IDEmpleado      
		  join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		  join [Seguridad].[tblUsuarios] U on DFEU.IDUsuario = U.IDUsuario      
	 where (DFEU.IDUsuario = @IDUsuario or @IDUsuario is null)       
		  and (DFEU.IDDetalleFiltrosEmpleadosUsuarios = @IDDetalleFiltrosEmpleadosUsuarios or @IDDetalleFiltrosEmpleadosUsuarios is null)      
		  and ((isnull(DFEU.ValorFiltro,'Empleados') = @Filtro) OR (isnull(DFEU.Filtro,'Empleados') = @Filtro) or (@Filtro is null))
		  ORDER BY EM.ClaveEmpleado ASC, EM.NOMBRECOMPLETO ASC
GO
