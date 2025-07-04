USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Seguridad].[spBuscarPermisosPerfilesControllerTreeViewPorMenu](  
	@ParentID varchar(100)
	,@IDPerfil int  
	,@IDUsuario int  
) as
	DECLARE  
		@IDIdioma varchar(225),
		@IDUrl INT;
	;
	DECLARE @TipoPermiso INT;

	/*
		0 - Applicacion
		1 - Titulo
		2 - Permiso
		3 - Permiso Especial Parent
		4 - Permiso Especial Child
	*/
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))	

	if object_id('tempdb..#TemptTreeViewItem') is not null drop table #TemptTreeViewItem;

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

	SET @TipoPermiso = (
		SELECT
			CASE
				WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatAplicaciones] WHERE IDAplicacion = @ParentID ) THEN 1
				--WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatPermisosEspeciales] WHERE CodigoParent = @ParentID ) THEN 4
				WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblMenu]  WHERE ParentID = @ParentID) THEN 2
				--WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatPermisosEspeciales] WHERE IDUrlParent = (SELECT top 1 IDUrl from App.tblMenu where IDMenu = @ParentID) ) THEN 3
			END
		);

	--select @TipoPermiso;
	
	IF @TipoPermiso  = 1
	BEGIN
		INSERT INTO #TemptTreeViewItem (id ,IDUrl, IDController ,IDAplicacion, [text] ,hasChildren ,IDTipoPermiso ,Permiso,IDperfil) 
		SELECT 
			M.IDMenu,
			u.IDUrl as IDUrl,
			isnull(c.IDController,0),
			m.IDAplicacion,
			JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
			CASE
				WHEN EXISTS( SELECT TOP 1 1 FROM App.tblMenu WHERE ParentID = M.IDMenu)
					THEN 1 
				ELSE 0 
			END,
			@TipoPermiso,
			isnull(ppc.IDTipoPermiso,'0'),
			@IDPerfil
		from App.tblMenu M        
			Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl 
			left join app.tblCatControllers c on u.IDController = c.IDController 
			left join app.tblCatAreas a on c.IDArea = a.IDArea   
			left join Seguridad.tblPermisosPerfilesControllers ppc on ppc.IDController = c.IDController and ppc.IDPerfil = @IDPerfil  
		where m.IDAplicacion = @ParentID 
		and (m.ParentID = 0)    
	END
	Else IF @TipoPermiso  = 2
	BEGIN
		INSERT INTO #TemptTreeViewItem (id ,IDUrl ,IDController ,IDAplicacion ,[text] ,hasChildren ,IDTipoPermiso ,Permiso ,IDperfil)
		select 
			M.IDMenu,
			u.IDUrl as IDUrl,
			isnull(c.IDController,0),
			m.IDAplicacion,
			JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
			CASE
				WHEN (isnull(c.IDController,0) = 0) THEN 1
				WHEN EXISTS( SELECT TOP 1 1 FROM [App].[tblCatPermisosEspeciales] WHERE IDUrlParent = u.IDUrl)
					THEN 1 
				ELSE 0 
			END,
			@TipoPermiso,
			isnull(ppc.IDTipoPermiso,'0') IDTipoPermiso,
			@IDPerfil 
		from App.tblMenu M        
			Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl 
			left join app.tblCatControllers c on u.IDController = c.IDController 
			left join app.tblCatAreas a on c.IDArea = a.IDArea   
			left join Seguridad.tblPermisosPerfilesControllers ppc on ppc.IDController = c.IDController and ppc.IDPerfil = @IDPerfil  
		where (m.ParentID = @ParentID)      
	END
	
	SELECT * FROM #TemptTreeViewItem
GO
