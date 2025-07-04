USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosEspecialesUsuariosControllerTreeView](  
	@CodigoParent VARCHAR(100)
	,@IDController int
	,@IDUsuario int  
) as
	if object_id('tempdb..#TemptTreeViewItem') is not null drop table #TemptTreeViewItem;

	create table #TemptTreeViewItem(
		id varchar(100) COLLATE database_default,
		IDController int,
		IDAplicacion varchar(100) COLLATE database_default,
		[text] varchar(100) COLLATE database_default,
		hasChildren bit,
		IDTipoPermiso int,
		Permiso varchar(50) COLLATE database_default,
		IDperfil int		
	);

	DECLARE @TipoPermiso INT;
	/*
		1 - Permiso Especial Parent
		2 - Permiso Especial Child
	*/

	SET @TipoPermiso = (
		SELECT
			CASE
				WHEN ( @CodigoParent is null ) THEN 1
			ELSE 2
		END
	);

	IF @TipoPermiso = 1
	BEGIN
		INSERT INTO #TemptTreeViewItem (id ,IDController ,IDAplicacion ,[text] ,hasChildren ,IDTipoPermiso ,Permiso ,IDperfil)
		select 
			PE.Codigo,
			ISNULL(U.IDUrl,0),
			'PermisoEspecialParent',
			PE.Descripcion AS Descripcion,
			CASE
				   WHEN EXISTS( SELECT TOP 1 1  FROM [App].[tblCatPermisosEspeciales] WHERE CodigoParent = PE.Codigo)
						THEN 1 
				   ELSE 0 
			END,
			pe.IDPermiso,
			cast(case when (PEP.IDPermiso is null) then 0 
				else 1
				end  as bit)as TienePermiso,
			@IDUsuario
		from app.tblCatControllers c  
			inner join app.tblCatUrls u on c.IDController = u.IDController  
			inner join app.tblCatPermisosEspeciales pe on u.IDUrl = pe.IDUrlParent  
			left outer join [Seguridad].[vwPermisosEspecialesUsuarios] PEP 
				on PEP.IDPermiso = PE.IDPermiso and PEP.IDUsuario = @IDUsuario  and PEP.TienePermiso = 1
		where c.IDController = @IDController and pe.CodigoParent IS NULL
	END
	Else 
	BEGIN
		INSERT INTO #TemptTreeViewItem (id ,IDController ,IDAplicacion ,[text] ,hasChildren ,IDTipoPermiso ,Permiso ,IDperfil)
		select 
			PE.Codigo,
			ISNULL(U.IDUrl,0),
			'PermisoEspecialChild',
			PE.Descripcion AS Descripcion,
			CASE
				   WHEN EXISTS( SELECT TOP 1 1  FROM [App].[tblCatPermisosEspeciales] WHERE CodigoParent = PE.Codigo)
						THEN 1 
				   ELSE 0 
			END,
			pe.IDPermiso,
			cast(case when (PEP.IDPermiso is null) then 0 
				else 1
				end  as bit)as TienePermiso,
			@IDUsuario
		from app.tblCatControllers c  
			inner join app.tblCatUrls u on c.IDController = u.IDController  
			inner join app.tblCatPermisosEspeciales pe on u.IDUrl = pe.IDUrlParent  
			left outer join [Seguridad].[vwPermisosEspecialesUsuarios] PEP
				on PEP.IDPermiso = PE.IDPermiso and PEP.IDUsuario = @IDUsuario and PEP.TienePermiso = 1
		where c.IDController = @IDController 
			and pe.CodigoParent = @CodigoParent
		order by pe.CodigoParent
	END
	
	SELECT 
		 temp.id			
		,temp.IDController
		,temp.IDAplicacion
		,case when isnull(pe.[Data], '') = '' then temp.[text] else coalesce(temp.[text],'') + ' ('+coalesce(pe.[Data], '0')+' días)'  end as [text]
		,temp.hasChildren	
		,temp.IDTipoPermiso
		,temp.Permiso		
		,temp.IDperfil	
	FROM #TemptTreeViewItem temp
		inner join app.tblCatPermisosEspeciales pe on pe.Codigo = temp.id
GO
