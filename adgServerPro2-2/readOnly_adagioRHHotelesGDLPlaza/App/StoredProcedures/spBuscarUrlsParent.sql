USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarUrlsParent]  
AS  
BEGIN  
 Select  url.IDUrl  
   ,url.IDModulo  
   ,coalesce(a.Descripcion,'')+ '/'+m.Descripcion+'/'+ url.Descripcion as Descripcion  
   ,url.URL  
   ,url.Tipo 
   ,url.IDTipoPermiso
   ,tp.Descripcion as TipoPermiso
   ,tp.Hologacion
   ,url.IDController
   ,c.Nombre AS Controller
 from App.tblCatUrls url  
    join App.tblCatModulos m on url.IDModulo = m.IDModulo  
    join app.tblCatAreas a on m.IDArea = a.IDArea  
	join App.tblCatTipoPermiso TP on TP.IDTipoPermiso = url.IDTipoPermiso
	join app.tblCatControllers c on c.IDController = url.IDController
 Where URL.Tipo = 'V'
   and url.IDUrl in (Select IDUrl From App.tblMenu)  
END
GO
