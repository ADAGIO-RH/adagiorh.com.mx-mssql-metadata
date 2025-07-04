USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[AccionesVsCatUrl] as
 select COALESCE(ca.area,'')
	   +'/'+COALESCE(ca.Controller,'')
	   +'/'+COALESCE(ca.[Action],'') as URL
	   ,*
 from [App].[tblControllersActions] ca
    left join app.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')
	   +'/'+COALESCE(ca.Controller,'')
	   +'/'+COALESCE(ca.[Action],'') 
 where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') and ca.Area <> '' --and ca.Area in ('IMSS')
GO
