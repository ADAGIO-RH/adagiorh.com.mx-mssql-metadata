USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Seguridad].[spBuscarPermisosUsuariosControllerTreeViewPorMenu] --'Catalogos',1,1
(  
  @ParentID  VARCHAR(100)
 ,@IDUsuarioUsuario int  
 ,@IDUsuario int  
) as

if object_id('tempdb..#TemptTreeViewItem') is not null drop table #TemptTreeViewItem;

DECLARE @IDUrl INT;

 create table #TemptTreeViewItem(
		id varchar(100),
		IDUrl int,
		IDController int,
		IDAplicacion varchar(100),
		[text] varchar(100),
		hasChildren bit,
		IDTipoPermiso int,
		Permiso varchar(50),
		IDperfil int		
	);

	DECLARE @TipoPermiso INT;

	/*
		1 - Titulo
		2 - Permiso
	*/

	SET @TipoPermiso =
	(SELECT
	CASE
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatAplicaciones] WHERE IDAplicacion = @ParentID ) THEN 1
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblMenu]  WHERE ParentID = @ParentID) THEN 2
	END);

	--select @TipoPermiso;
	
	IF @TipoPermiso  = 1
	BEGIN
		 INSERT INTO #TemptTreeViewItem (id ,IDUrl, IDController ,IDAplicacion, [text] ,hasChildren ,IDTipoPermiso ,Permiso,IDperfil) 
			SELECT 
				M.IDMenu,
				u.IDUrl as IDUrl,
				isnull(c.IDController,0),
				m.IDAplicacion,
				u.Descripcion,
			   CASE
				   WHEN EXISTS( SELECT TOP 1 1 FROM App.tblMenu WHERE ParentID = M.IDMenu)
						THEN 1 
				   ELSE 0 
			   END,
			   @TipoPermiso,
			   isnull(ppc.IDTipoPermiso,'0'),
			   @IDUsuarioUsuario
				from App.tblMenu M        
					Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl 
					left join app.tblCatControllers c on u.IDController = c.IDController 
					left join app.tblCatAreas a on c.IDArea = a.IDArea   
					 left join Seguridad.tblPermisosUsuarioControllers ppc on ppc.IDController = c.IDController and ppc.IDUsuario = @IDUsuarioUsuario   
				where m.IDAplicacion = @ParentID 
				and (m.ParentID = 0)    
	END
	Else IF @TipoPermiso  = 2
	BEGIN

		

		INSERT INTO #TemptTreeViewItem (id ,IDUrl, IDController ,IDAplicacion ,[text] ,hasChildren ,IDTipoPermiso ,Permiso ,IDperfil)
			select 
				M.IDMenu,
				u.IDUrl as IDUrl,
				isnull(c.IDController,0),
				m.IDAplicacion,
				u.Descripcion,
			   CASE
				   WHEN (isnull(c.IDController,0) = 0) THEN 1
				   WHEN EXISTS( SELECT TOP 1 1 FROM [App].[tblCatPermisosEspeciales] WHERE IDUrlParent = u.IDUrl)
						THEN 1 
				   ELSE 0 
			   END,
			   @TipoPermiso,
			   isnull(ppc.IDTipoPermiso,'0')  AS IDTipoPermiso
			  ,
			   @IDUsuarioUsuario 
				from App.tblMenu M        
					Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl 
					left join app.tblCatControllers c on u.IDController = c.IDController 
					left join app.tblCatAreas a on c.IDArea = a.IDArea   
					left join Seguridad.tblPermisosUsuarioControllers ppc on ppc.IDController = c.IDController and ppc.IDUsuario = @IDUsuarioUsuario 
				where (m.ParentID = @ParentID)      
	END

	SELECT * FROM #TemptTreeViewItem
GO
