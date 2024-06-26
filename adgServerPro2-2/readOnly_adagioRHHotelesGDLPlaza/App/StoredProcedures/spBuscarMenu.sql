USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarMenu] (
	@IDAplicacion nvarchar(100)
)
AS  
BEGIN  
	select  M.IDMenu  
		,M.IDUrl  
		,ISnull(M.ParentID,0)as ParentID  
		,M.CssClass   
		,u.Descripcion  
		,U.URL  
		,isnull(M.Orden,0) as Orden  
	from App.tblMenu M  
		Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl  
	Where U.Tipo = 'v' and m.IDAplicacion = @IDAplicacion 
	Order by M.Orden  
END
GO
