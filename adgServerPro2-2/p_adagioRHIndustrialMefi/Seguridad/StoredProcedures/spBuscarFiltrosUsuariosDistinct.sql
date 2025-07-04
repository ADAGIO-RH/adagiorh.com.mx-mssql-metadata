USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarFiltrosUsuariosDistinct](  
 @IDFiltrosUsuarios int = 0  
 ,@IDUsuario int = 0   
) as  
 select    
  distinct   
   IDFiltrosUsuarios = case when Filtro = 'Empleados' then 0  
       else IDFiltrosUsuarios  
       end  
   ,IDUsuario  
   ,Filtro = case when Filtro = 'Empleados' then Filtro  
       else coalesce(Filtro,'')+ ' | '+coalesce(Descripcion,'')  
       end  
 from [Seguridad].[tblFiltrosUsuarios]  
 where (IDFiltrosUsuarios = @IDFiltrosUsuarios or @IDFiltrosUsuarios = 0) and (IDUsuario = @IDUsuario or @IDUsuario = 0)
GO
