USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH]
--GO
--/****** Object:  StoredProcedure [Bk].[spGenerarUrls]    Script Date: 13/07/2020 11:01:23 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--(Poner el próximo IDUrl correctamente y el IDModulo, en el Where colocar el área correcta, estas url ponerlas en el postdeploy y ejecutarlos para que las guarde en la tabla app.tbCatUrls)

CREATE proc [Bk].[spGenerarUrls] as
select 
	N'insert into #TempCatUrls(IDUrl,IDModulo,Descripcion,URL,Tipo) values (
	'+cast(3511 - 1 + row_number() over (order by (select NULL)) as varchar) +' /* Siguiente IDUrl */
	,29   																	  /* IDModulo */								
	,'''+case when ca.Area is not null and ca.Area <> '' then COALESCE(ca.area,'') +'/' else '' end +COALESCE(ca.Controller,'') +'/'+COALESCE(ca.[Action],'')+'''
	,'''+case when ca.Area is not null and ca.Area <> '' then COALESCE(ca.area,'') +'/' else '' end +COALESCE(ca.Controller,'') +'/'+COALESCE(ca.[Action],'')+'''
	,'+case when ca.Attributes = 'adgView' then '''V''' else '''A''' end +'
	)'
	,case when ca.Area is not null and ca.Area <> '' then COALESCE(ca.area,'') +'/' else '' end + COALESCE(ca.Controller,'') +'/'+COALESCE(ca.[Action],'') as URL
	,*
from [App].[tblControllersActions] ca
left join app.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')
	+'/'+COALESCE(ca.Controller,'')
	+'/'+COALESCE(ca.[Action],'') 
where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') --and ca.Area <> '' --and ca.Area in ('IMSS')
and cu.IDUrl is null
AND CA.Attributes not like '%adgIgnore%'
and CA.Attributes not like '%AllowAnonymous%'
and ca.Area = 'Reclutamiento'
GO
