USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarMenuUsuario](     
	@IDUsuario int  
	,@IDAplicacion nvarchar(100) 
)        
AS        
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))	
	
	if object_id('tempdb..#TempConfiguracionMenu') is not null drop table #TempConfiguracionMenu;
     
	create table #TempConfiguracionMenu (    
		IDMenu int,    
		IDUrl int,    
		ParentID int,    
		CssClass varchar(100),    
		Descripcion varchar(255),    
		URL varchar(255),    
		Orden int ,  
		IDAplicacion nvarchar(100),  
        BadgeVariant varchar(100)COLLATE database_default	null,
        BadgeText    varchar(100)COLLATE database_default	null			
	)    
    
	insert into #TempConfiguracionMenu    
	select  
		M.IDMenu        
		,M.IDUrl        
		,M.ParentID        
		,M.CssClass         
		,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion       
		,case when (U.URL ='#') then '' else U.URL end as URL        
		,isnull(M.Orden,0) as Orden    
		,m.IDAplicacion   
        ,m.BadgeVariant
        ,m.BadgeText
	from App.tblMenu M        
		Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl 
		left join app.tblCatControllers c on u.IDController = c.IDController 
		left join app.tblCatAreas a on c.IDArea = a.IDArea      
	where (m.ParentID = 0 OR U.URL ='#')    
		and m.IDAplicacion = @IDAplicacion  
		and IDMenu not in (Select IDMenu from #TempConfiguracionMenu)    
 
	insert into #TempConfiguracionMenu        
	select distinct  
		M.IDMenu        
	   ,M.IDUrl        
	   ,M.ParentID        
	   ,M.CssClass         
	   ,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion           
	   ,case when (U.URL ='#') then '' else U.URL end as URL        
	   ,isnull(M.Orden,0) as Orden        
	   ,m.IDAplicacion 
       ,m.BadgeVariant
       ,m.BadgeText  
	from App.tblMenu M        
		left join app.tblCatUrls u on m.IDUrl = u.IDUrl      
		left join app.tblCatControllers c on u.IDController = c.IDController      
		left join app.tblCatAreas a on c.IDArea = a.IDArea      
		left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
		--left join app.TblControllerDependencias cd  on ((c.IDController = cd.IDControllerParent)or(c.IDController = cd.IDControllerChild))      
		left join Seguridad.vwPermisosUsuariosController puc on -- (((puc.IDController = cd.IDControllerParent)or(puc.IDController = cd.IDControllerChild))      
		 -- OR 
		  puc.IDController = c.IDController
		  --)      
			and puc.IDUsuario = @IDUsuario 
		left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
			and tpu.Prioridad >= tp.Prioridad      
	 Where puc.IDUsuario = @IDUsuario        
	   and M.ParentID in (Select IDMenu from #TempConfiguracionMenu )      
	   and IDMenu not in (Select IDMenu from #TempConfiguracionMenu)    
	   and m.IDAplicacion = @IDAplicacion 
   
	insert into #TempConfiguracionMenu       
	select distinct  
		M.IDMenu        
	   ,M.IDUrl        
	   ,M.ParentID        
	   ,M.CssClass         
	   ,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion              
	   ,case when (U.URL ='#') then '' else U.URL end as URL        
	   ,isnull(M.Orden,0) as Orden        
	   ,m.IDAplicacion   
        ,m.BadgeVariant
        ,m.BadgeText
	from App.tblMenu M        
		Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl      
		left join app.tblCatControllers c on u.IDController = c.IDController      
		left join app.tblCatAreas a on c.IDArea = a.IDArea      
		left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
		--left join app.TblControllerDependencias cd on ((c.IDController = cd.IDControllerParent)or(c.IDController = cd.IDControllerChild))      
		left join Seguridad.vwPermisosUsuariosController puc on -- (((puc.IDController = cd.IDControllerParent)or(puc.IDController = cd.IDControllerChild))      
		--	OR
		puc.IDController = c.IDController
		--)      
				and puc.IDUsuario = @IDUsuario 
		left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
			and tpu.Prioridad >= tp.Prioridad      
	Where puc.IDUsuario = @IDUsuario        
		and M.ParentID in (Select IDMenu from #TempConfiguracionMenu )     
		and IDMenu not in (Select IDMenu from #TempConfiguracionMenu)     
		and m.IDAplicacion = @IDAplicacion  

	insert into #TempConfiguracionMenu       
	select distinct  
		M.IDMenu        
		,M.IDUrl        
		,M.ParentID        
		,M.CssClass         
		,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion             
		,case when (U.URL ='#') then '' else U.URL end as URL        
		,isnull(M.Orden,0) as Orden        
		,m.IDAplicacion   
        ,m.BadgeVariant
        ,m.BadgeText
	from App.tblMenu M        
		Inner join app.tblCatUrls u on m.IDUrl = u.IDUrl      
		left join app.tblCatControllers c on u.IDController = c.IDController      
		left join app.tblCatAreas a on c.IDArea = a.IDArea      
		left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
	--	left join app.TblControllerDependencias cd on ((c.IDController = cd.IDControllerParent)or(c.IDController = cd.IDControllerChild))      
		inner join Seguridad.vwPermisosUsuariosController puc on-- (((puc.IDController = cd.IDControllerParent)or(puc.IDController = cd.IDControllerChild))      
		--	OR 
			puc.IDController = c.IDController
			--)      
				and puc.IDUsuario = @IDUsuario 
		left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
			and tpu.Prioridad >= tp.Prioridad      
	Where puc.IDUsuario = @IDUsuario        
		and M.ParentID in (Select IDMenu from #TempConfiguracionMenu )     
		and IDMenu not in (Select IDMenu from #TempConfiguracionMenu)     
		and m.IDAplicacion = @IDAplicacion    
         
	Delete #TempConfiguracionMenu        
	where IDMenu not in (Select ParentID from #TempConfiguracionMenu )      
	and URL = ''      
 
	Delete cm
	from #TempConfiguracionMenu cm
		inner join app.tblCatUrls u on u.IDUrl = cm.IDUrl
		inner join app.tblCatControllers c on c.IDController = u.IDController
		left join Seguridad.vwPermisosUsuariosController PUC on PUC.IDController = c.IDController
	where u.URL <> ''
		and isnull(puc.IDTipoPermiso,'') < 'RV'   
		and PUC.IDUsuario = @IDUsuario
         
	select distinct * from #TempConfiguracionMenu        
	order by ParentID, Orden ASC        
END
GO
