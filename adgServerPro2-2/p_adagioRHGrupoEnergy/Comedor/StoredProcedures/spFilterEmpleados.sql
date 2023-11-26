USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-02-21
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
create proc [Comedor].[spFilterEmpleados](  
	@IDUsuario	int = 0  
	,@filter	varchar(1000)   

)as   
	select  e.*
		   ,TP.Descripcion as TiposPrestacion	  
	from [RH].[tblEmpleadosMaster] e with (nolock)
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
			on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatTiposPrestaciones TP
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
	where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = 1)
	order by ClaveEmpleado asc
GO
