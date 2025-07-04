USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea las nuevas Áreas en la tabla App.[tblCatAreas]
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2023-08-23
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create proc [App].[spAsignarNuevasAreas] as
	declare @MaxIDArea int = 0;

	select @MaxIDArea = max(IDArea)+1 from [App].[tblCatAreas]

	if object_id('tempdb..#tempAreas') is not null drop table #tempAreas;

	select distinct Area
	INTO #tempAreas
	from [App].[tblControllersActions] ca with (nolock)
		left join App.tblCatAreas a with (nolock) on ca.Area = cast(a.Descripcion  as varchar(max)) collate Latin1_General_CI_AI 
	where Area not in ('System.Web.Mvc','System','Kendo.Mvc.UI') and a.IDArea is null and isnull( ca.Area,'') != ''
 
	insert into [App].[tblCatAreas](IDArea,Descripcion,PrefijoURL)
	select 
		cast(@MaxIDArea - 1 + row_number() over (order by (select NULL)) as varchar) IDArea
		,Area
		,0
	from #tempAreas
GO
