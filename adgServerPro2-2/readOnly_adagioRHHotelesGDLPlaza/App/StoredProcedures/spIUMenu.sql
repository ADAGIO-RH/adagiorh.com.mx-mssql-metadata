USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spIUMenu]  
(  
    @IDMenu int = 0,  
    @IDUrl int,  
    @ParentID int =null,  
    @CssClass varchar(100),  
	@Orden int = null,
	@IDAplicacion nvarchar(100)
)  
as  
Begin  
    if (@IDMenu = 0)  
    begin  
   
    insert into App.tblMenu(IDUrl,ParentID,CssClass,Orden,IDAplicacion)  
    values(@IDUrl,@ParentID,@CssClass,@Orden,@IDAplicacion)  
    set @IDMenu = @@IDENTITY  
      
    end else  
 begin  
  update app.tblMenu  
   set IDUrl = @IDUrl,  
    ParentID = @ParentID,  
    CssClass = @CssClass,  
    Orden = @Orden  
  where IDMenu = @IDMenu    
 end;  
  
  
 select IDMenu  
  ,u.IDUrl  
  ,m.ParentID  
  ,m.CssClass  
  ,m.Orden  
  ,u.Descripcion  
  ,u.URL   
  ,m.IDAplicacion
 from App.tblMenu m   
  inner join app.tblCatUrls u   
   on m.IDUrl = u.IDUrl   
 where m.IDMenu = @IDMenu  
end
GO
