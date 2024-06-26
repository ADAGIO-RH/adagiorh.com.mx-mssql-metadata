USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [Seguridad].[spBuscarUsuarioPermisoController] --1,  'Seguridad/Perfiles/Read'  
(  
 @IDUsuario int,  
 @Url Varchar(max) = null  
)  
AS  
BEGIN 
 
 IF OBJECT_ID('tempdb..#urls') IS NOT NULL
    DROP TABLE #urls

 declare @IDUrl int
		,@IDController int
	    --, @IDUsuario int = 1

 select @IDUrl = IDUrl, @IDController =IDController from App.tblCatUrls where URL = @Url --@Url
	--select @IDUrl, @IDController

select distinct 
 isnull(puc.IDPermisoUsuarioController,0)as IDPermisoUsuarioController  
  ,isnull(puc.IDUsuario,@IDUsuario) as IDUsuario  
  ,isnull(A.IDArea,0) as IDArea  
  ,A.Descripcion as Area   
  ,ISNULL(U.IDUrl,0) as IDUrl  
  ,U.URL as URL  
  ,U.Descripcion as Accion  
  ,U.Tipo  
  ,cast(case when (puc.IDPermisoUsuarioController is null) OR (isnull(PUC.IDTipoPermiso,'') < isnull(tp.IDTipoPermiso,'') ) then 0   
   else 1  
   end  as bit)as TienePermiso  
   ,PUC.IDTipoPermiso as UsuarioPermiso
   ,tp.IDTipoPermiso as PERMISOCONTROLLER
   ,cd.*
   into #urls
	  from app.tblCatUrls u
		inner join app.tblCatControllers c
			on u.IDController = c.IDController
		inner join app.tblCatAreas a
			on c.IDArea = a.IDArea
		left join app.tblCatTipoPermiso tp
			on tp.IDTipoPermiso = u.IDTipoPermiso
		left join app.TblControllerDependencias cd
			on ((c.IDController = cd.IDControllerParent)or(c.IDController = cd.IDControllerChild))
		left join Seguridad.tblPermisosUsuarioControllers puc
			on (((puc.IDController = cd.IDControllerParent)or(puc.IDController = cd.IDControllerChild))
				OR puc.IDController = c.IDController)
			and puc.IDUsuario = @IDUsuario
		left join app.tblCatTipoPermiso tpu
			on tpu.IDTipoPermiso = puc.IDTipoPermiso
			and tpu.Prioridad >= tp.Prioridad
	  where u.IDUrl = @IDUrl

	  if exists(select top 1 1 from #urls where TienePermiso = 1)
	  BEGIN
		Select top 1 * from #urls where TienePermiso = 1
	  END
	  ELSE
	  BEGIN
		Select top 1 * from #urls
	  END
END
GO
