USE [p_adagioRHIndustrialMefi]
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
CREATE proc [Docs].[spBuscarDocumentosUsuario](      
	@IDDocumento int
	,@IDDetalleFiltrosEmpleadosUsuarios int = null      
	,@Filtro  varchar(255)   = null      
) as   
   
	 SET LANGUAGE 'Spanish';      
      
	 select DFEU.IDDetalleFiltrosDocumentosUsuarios      
		,DFEU.IDDocumento      
		,DFEU.IDUsuario      
		,us.Cuenta      
		,coalesce( us.Nombre,'')+ ' '+coalesce(us.apellido,'') as NombreCompleto     
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Usuarios') as Filtro      
	 from [Docs].[tblDetalleFiltrosDocumentosUsuarios] DFEU   
		  Join [Seguridad].[tblUsuarios] us on DFEU.IDUsuario = US.IDUsuario   
		  join [RH].[tblEmpleadosMaster] em on US.IDEmpleado = em.IDEmpleado      
		  join Docs.[tblDetalleFiltrosDocumentosUsuarios] dfe with (nolock) on dfe.IDUsuario = us.IDUsuario and dfe.IDDocumento = @IDDocumento
		  join [Seguridad].[tblUsuarios] U on DFEU.IDUsuario = U.IDUsuario      
	 where (DFEU.IDDocumento = @IDDocumento or @IDDocumento is null)       
		  and (DFEU.IDDetalleFiltrosDocumentosUsuarios = @IDDetalleFiltrosEmpleadosUsuarios or @IDDetalleFiltrosEmpleadosUsuarios is null)      
		  and ((isnull(DFEU.ValorFiltro,'Usuarios') = @Filtro) OR (isnull(DFEU.Filtro,'Usuarios') = @Filtro) or (@Filtro is null))
		  ORDER BY us.Cuenta ASC, us.Nombre + ' '+us.Apellido ASC
GO
