USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBorrarMenu](@IDMenu int)
as

    declare @IDUrl int = 0;
    
    --select top 1 @IDUrl=IDUrl from app.tblMenu where IDMenu=@IDMenu

    delete from App.tblMenu where ParentID=@IDMenu
    delete from App.tblMenu where IDMenu=@IDMenu
GO
