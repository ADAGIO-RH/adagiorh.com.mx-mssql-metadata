USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarJefesEmpleados](
	@IDJefeEmpleado int = 0
	,@IDJefe int = 0
	,@IDEmpleado int = 0
	,@IDUsuario int
) as

	select je.IDJefeEmpleado
		,je.IDEmpleado
		,emp.ClaveEmpleado
		,substring(UPPER(COALESCE(emp.Paterno,'')+' '+COALESCE(emp.Materno,'')+', '+COALESCE(emp.Nombre,'')+' '+COALESCE(emp.SegundoNombre,'')),1,49 ) AS NombreEmpleado	
		,emp.Puesto as PuestoEmpleado
		,je.IDJefe
		,empJefe.ClaveEmpleado as ClaveJefe
		,substring(UPPER(COALESCE(empjefe.Paterno,'')+' '+COALESCE(empjefe.Materno,'')+', '+COALESCE(empjefe.Nombre,'')+' '+COALESCE(empjefe.SegundoNombre,'')),1,49 ) AS NombreJefe
		,emp.Puesto as PuestoJefe
	from [RH].[tblJefesEmpleados] je with (nolock) 
		join [RH].[tblEmpleadosMaster] empjefe with (nolock) on je.IDJefe = empjefe.IDEmpleado	
		join [RH].[tblEmpleadosMaster] emp with (nolock) on je.IDEmpleado = emp.IDEmpleado
	where (je.IDJefeEmpleado = @IDJefeEmpleado or @IDJefeEmpleado = 0)
		and (je.IDJefe = @IDJefe or @IDJefe = 0)	
		and (je.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
		and ((@IDJefeEmpleado + @IDJefe + @IDEmpleado) > 0)
GO
