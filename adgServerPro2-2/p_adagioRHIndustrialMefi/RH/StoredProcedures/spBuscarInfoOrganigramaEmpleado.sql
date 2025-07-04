USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar los Jefes, Subordinados o Colegas de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@gmail.com  
** FechaCreacion : 2018-10-29  
** Paremetros  :                

	Si se modifica el result set de este sp es necesario modificar los siguientes sps:
	[RH].[spActualizarTotalesRelacionesEmpleados]
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-01-21			Aneudy Abreu	Se agrega validación para solo regredar empleados vigentes
2019-05-23			Aneudy Abreu	Se agregó el campo Puesto del empleado y del jefe al resultset

2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios 


exec [RH].[spBuscarInfoOrganigramaEmpleado]  
  @IDEmpleado = 1279    
  ,@IDTipoRelacion =3 
  ,@IDUsuario =1  

***************************************************************************************************/  
CREATE proc [RH].[spBuscarInfoOrganigramaEmpleado](  
	@IDEmpleado int    
	,@IDTipoRelacion int   
	,@IDUsuario int  
)  
as  

	declare @dtInfoOrganigrama RH.dtInfoOrganigrama;

	-- Jefe del Empleado  
	if (@IDTipoRelacion = 1)  
	begin  
		insert @dtInfoOrganigrama
		select  
			je.IDJefeEmpleado  
			,je.IDEmpleado  
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Empleado  
			,e.Puesto as PuestoEmpleado
			,je.IDJefe  
			,ee.ClaveEmpleado as ClaveJefe
			,ee.NOMBRECOMPLETO as Jefe 
			,ee.Puesto as PuestoJefe 
			,@IDTipoRelacion as IDTipoRelacion
		from [RH].[tblJefesEmpleados] je  
			--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = je.IDEmpleado and dfe.IDUsuario = @IDUsuario
			left join [RH].[tblEmpleadosMaster] e on je.IDEmpleado = e.IDEmpleado  
			left join [RH].[tblEmpleadosMaster] ee on je.IDJefe = ee.IDEmpleado  
		where je.IDEmpleado = @IDEmpleado and ee.Vigente = 1
	end;  
  
	-- SUBORDINADO
	if (@IDTipoRelacion = 2)  
	begin  
		insert @dtInfoOrganigrama
		select   
			je.IDJefeEmpleado  
			,je.IDEmpleado  
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Empleado  
			,e.Puesto as PuestoEmpleado
			,je.IDJefe  
			,ee.ClaveEmpleado as ClaveJefe
			,ee.NOMBRECOMPLETO as Jefe 
			,ee.Puesto as PuestoJefe 
			,@IDTipoRelacion as IDTipoRelacion
		from [RH].[tblJefesEmpleados] je  
			--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = je.IDEmpleado and dfe.IDUsuario = @IDUsuario
			left join [RH].[tblEmpleadosMaster] e on je.IDEmpleado = e.IDEmpleado  
			left join [RH].[tblEmpleadosMaster] ee on je.IDJefe = ee.IDEmpleado  
		where je.IDJefe = @IDEmpleado and e.Vigente = 1  
	end; 

	--COLEGA
	if (@IDTipoRelacion = 3)  
	begin  
		insert @dtInfoOrganigrama
		select   
			je.IDJefeEmpleado  
			,je.IDEmpleado  
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Empleado  
			,e.Puesto as PuestoEmpleado
			,je.IDJefe  
			,ee.ClaveEmpleado as ClaveJefe
			,ee.NOMBRECOMPLETO as Jefe 
			,ee.Puesto as PuestoJefe 
			,@IDTipoRelacion as IDTipoRelacion
		from [RH].[tblJefesEmpleados] je  
			--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = je.IDEmpleado and dfe.IDUsuario = @IDUsuario
			left join [RH].[tblEmpleadosMaster] e on je.IDEmpleado = e.IDEmpleado  
			left join [RH].[tblEmpleadosMaster] ee on je.IDJefe = ee.IDEmpleado  
		where je.IDJefe in (select IDJefe 
							from rh.tblJefesEmpleados 
							where IDEmpleado = @IDEmpleado) and je.IDEmpleado <> @IDEmpleado  
			and e.Vigente = 1
			--and je.IDEmpleado not in (select IDEmpleado from @dtInfoOrganigrama)
	end;  
  
	select 
		IDJefeEmpleado  
		,IDEmpleado  
		,ClaveEmpleado
		,Empleado  
		,PuestoEmpleado
		,IDJefe  
		,ClaveJefe
		,Jefe 
		,PuestoJefe 
		,IDTipoRelacion
	from (
		select *
			,ROW_NUMBER()OVER(partition by IDEmpleado order by ClaveEmpleado) as [Row] 
		from @dtInfoOrganigrama  
	) dt where (1 = case when dt.IDTipoRelacion <> 3 then 1
							 when dt.IDTipoRelacion = 3 and dt.[Row] > 1 then 0 else 1 end)
	order by dt.ClaveEmpleado
GO
