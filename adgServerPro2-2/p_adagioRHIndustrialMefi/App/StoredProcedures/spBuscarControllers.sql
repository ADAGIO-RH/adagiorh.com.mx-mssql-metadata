USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarControllers]  
AS  
BEGIN  
 select c.IDController  
    ,c.Nombre Controller  
    ,c.Descripcion ControllerDescripcion  
    ,isnull(C.IDArea,0) as IDArea  
    ,isnull(A.Descripcion,'') as Area
	,aa.IDAplicacion   
 From app.tblCatControllers c  
  left join App.tblCatAreas A  
   on c.IDArea = A.IDArea   
  left join App.tblAplicacionAreas AA
	on A.IDArea = AA.IDArea

	order by Controller asc
END
GO
