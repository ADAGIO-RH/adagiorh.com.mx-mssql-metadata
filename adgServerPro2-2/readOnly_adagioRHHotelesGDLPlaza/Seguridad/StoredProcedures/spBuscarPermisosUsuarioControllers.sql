USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosUsuarioControllers](    
 @IDAplicacion nvarchar(100)    
 ,@IDUsuarioUsuario int    
 ,@IDUsuario int    
) as  

IF OBJECT_ID('tempdb..#TempSeguridad') IS NOT NULL
		DROP TABLE #TempSeguridad
 
 create table #TempSeguridad
 (
	IDPermisoUsuarioController int,
	IDUsuario int,
	IDAplicacion varchar(100) collate DATABASE_DEFAULT,
	IDArea int,
	Area varchar(100) collate DATABASE_DEFAULT,
	IDController int,
	Controller varchar(100) collate DATABASE_DEFAULT,
	DescripcionController varchar(255) collate DATABASE_DEFAULT,
	IDTipoPermiso varchar(10) collate DATABASE_DEFAULT,
	PermisosEspeciales bit,
	Orden int

 )

insert into  #TempSeguridad  
select isnull(ppc.IDPermisoUsuarioController,0) as IDPermisoUsuarioController    
   ,@IDUsuarioUsuario as IDUsuario    
   ,a.IDAplicacion    
   ,areas.IDArea    
   ,areas.Descripcion as Area    
   ,c.IDController    
   ,c.Nombre as Controller    
   ,u.Descripcion as DescripcionController    
   ,isnull(ppc.IDTipoPermiso,'0') IDTipoPermiso    
   ,PermisosEspeciales =  case when exists (select top 1 1    
           from app.tblCatControllers cc    
            join app.tblCatUrls ur on cc.IDController = ur.IDController and ur.Tipo = 'V'    
			and cc.IDController= c.IDController
            join app.tblCatPermisosEspeciales pe on ur.IDUrl = pe.IDUrlParent    
            ) then cast(1 as bit) else cast(0 as bit) end
	,m.Orden	       
from app.tblCatAplicaciones a 
	inner join App.tblMenu m on a.IDAplicacion = m.IDAplicacion
	inner join App.tblCatUrls u on u.IDUrl = m.IDUrl   
    
   join app.tblCatControllers c on c.IDController = u.IDController  
   left join app.tblCatAreas areas on c.IDArea = areas.IDArea 
    
 left join Seguridad.tblPermisosUsuarioControllers ppc on ppc.IDController = c.IDController and ppc.IDUsuario = @IDUsuarioUsuario    
where a.IDAplicacion = @IDAplicacion
--and u.URL <> N'#'

select * from #TempSeguridad
order by  Orden asc
GO
