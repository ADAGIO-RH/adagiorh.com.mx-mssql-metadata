USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [Bk].[spAsignarControllerPermisoUrl]  
AS  
--update cu  
--set 
--	cu.IDController = c.IDController   
--	,cu.IDTipoPermiso = case when ca.Attributes ='adgGet' then 'R'  
--							when ca.Attributes ='adgView' then 'RV'  
--							when ca.Attributes ='adgPost' then 'RVW'  
--							when ca.Attributes ='adgDelete' then 'RVWD'  
--							else 'R'  
--						end  
--	,cu.[Tipo] = case when ca.Attributes = 'adgView' then 'V' else 'A' end 
  
--from [App].[tblControllersActions] ca    
--left join app.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')    
-- +'/'+COALESCE(ca.Controller,'')    
-- +'/'+COALESCE(ca.[Action],'')    
-- left Join App.tblCatControllers c  
-- on ca.Controller = c.Nombre  
     
--where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') --and ca.Area <> '' --and ca.Area in ('IMSS')    
----and cu.IDUrl is null    
--AND CA.Attributes not like '%adgIgnore%'    
--and CA.Attributes not like '%AllowAnonymous%'    
----and ca.Area = 'Reclutamiento'    
----and cu.IDTipoPermiso is null  
--and Attributes <> ''  
  
select *,
	 c.IDController   
	, case when ca.Attributes ='adgGet' then 'R'  
							when ca.Attributes ='adgView' then 'RV'  
							when ca.Attributes ='adgPost' then 'RVW'  
							when ca.Attributes ='adgDelete' then 'RVWD'  
							else 'R'  
						end  
	, case when ca.Attributes = 'adgView' then 'V' else 'A' end 
  
from [App].[tblControllersActions] ca    
left join app.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')    
 +'/'+COALESCE(ca.Controller,'')    
 +'/'+COALESCE(ca.[Action],'')    
 left Join App.tblCatControllers c  
 on ca.Controller = c.Nombre  
     
where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') --and ca.Area <> '' --and ca.Area in ('IMSS')    
--and cu.IDUrl is null    
AND CA.Attributes not like '%adgIgnore%'    
and CA.Attributes not like '%AllowAnonymous%'    
--and ca.Area = 'Reclutamiento'    
--and cu.IDTipoPermiso is null  
and Attributes <> ''  
  
  
--select *  
--from [App].[tblControllersActions] ca    
--left join app.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')    
-- +'/'+COALESCE(ca.Controller,'')    
-- +'/'+COALESCE(ca.[Action],'')    
-- left Join App.tblCatControllers c  
-- on ca.Controller = c.Nombre  
     
--where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') --and ca.Area <> '' --and ca.Area in ('IMSS')    
----and cu.IDUrl is null    
--AND CA.Attributes not like '%adgIgnore%'    
--and CA.Attributes not like '%AllowAnonymous%'    
--and ca.Area = 'App'    
--and cu.IDTipoPermiso is null  
--and Attributes <> ''
GO
