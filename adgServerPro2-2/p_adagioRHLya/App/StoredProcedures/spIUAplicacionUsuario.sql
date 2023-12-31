USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 create proc [App].[spIUAplicacionUsuario](  
 @IDUsuario int  
 ,@IDAplicacion nvarchar(100)  
 ,@Permiso bit  
 ) as  
 if exists (select top 1 1   
    from [App].[tblAplicacionUsuario]   
    where IDUsuario = @IDUsuario and IDAplicacion = @IDAplicacion)  
 begin  
  if (@Permiso = 1)   
  begin  
   insert into [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion)  
   select @IDUsuario, @IDAplicacion      
  end else  
  begin  
   delete   
   from [App].[tblAplicacionUsuario]   
   where IDUsuario = @IDUsuario and IDAplicacion = @IDAplicacion  
  end;  
 end else  
 begin  
  if (@Permiso = 1)   
  begin  
   insert into [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion)  
   select @IDUsuario, @IDAplicacion      
  end  
 end
GO
