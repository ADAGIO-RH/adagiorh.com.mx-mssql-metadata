USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea los nuevos controllers en la tabla App.tblCatControllers
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [App].[spAsignarNuevosControllers] as
	declare @MaxIDController int = 0;

	select @MaxIDController = max(IDController)+1 from [App].[tblCatControllers]

	if object_id('tempdb..#tempControllers') is not null drop table #tempControllers;

	select distinct a.IDArea,ca.Controller--,cc.Nombre 
	INTO #tempControllers
	from [App].[tblControllersActions] ca with (nolock)
		left join App.tblCatAreas a with (nolock) on ca.Area = cast(a.Descripcion  as varchar(max)) collate Latin1_General_CI_AI 
		left join [App].[tblCatControllers] cc with (nolock) on cc.IDArea = a.IDArea and ca.Controller = cc.Nombre
	where Area not in ('System.Web.Mvc','System','Kendo.Mvc.UI') and cc.Nombre is null and a.IDArea is not null
 
	insert into [App].[tblCatControllers](IDController,IDArea,Nombre,Descripcion)
	select 
		cast(@MaxIDController - 1 + row_number() over (order by (select NULL)) as varchar) IDController
		,IDArea
		,Controller
		,Controller
	from #tempControllers
GO
