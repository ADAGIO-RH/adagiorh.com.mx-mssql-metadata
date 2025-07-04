USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC [App].[spBuscarMenuUsuarioPermisos] 1,'Colaboradores'
	EXEC [App].[spBuscarMenuUsuarioPermisos] 22635,'Nomina'
*/

CREATE PROCEDURE [App].[spBuscarMenuUsuarioPermisos](     
	@IDUsuario int  
	,@IDAplicacion nvarchar(100) 
)        
AS        
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))	



	  SELECT 
        (SELECT 
            isnull(M.IDMenu ,0) as IDMenu       
				   ,isnull(M.IDUrl,0 )  as IDUrl     
				   ,isnull(M.ParentID,0) ParentID       
				   ,isnull(M.CssClass,'')as  CssClass        
				   ,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion           
				   ,case when (U.URL ='#') then '' else U.URL end as URL        
				   ,isnull(M.Orden,0) as Orden        
				   ,isnull(m.IDAplicacion,'') as IDAplicacion
				   ,isnull(c.IDController,0) as IDController
				   ,isnull(puc.IDUsuario,@IDUsuario) as IDUsuario
				   ,cast(case when tpu.Prioridad >= tp.Prioridad  THEN 1 ELSE 0 END as bit) TienePermiso
				   ,isnull(puc.IDTipoPermiso,'') as IDTipoPermiso
                   ,isnull(case when IDPermisoUsuarioController <> 0 then 1 else 0 end,'') as PermisoPersonalizado
				   ,JSON_QUERY ([app].[fnUDFCreateJSONMenuUsuarioPermisos](@IDUsuario,M.IDMenu,@IDAplicacion)) AS Childrens
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](@IDUsuario,isnull(M.IDUrl,0 ),null)) AS Especiales
				   
         FROM App.tblMenu M      
             left join app.tblCatUrls u on m.IDUrl = u.IDUrl      
					left join app.tblCatControllers c on u.IDController = c.IDController      
					left join app.tblCatAreas a on c.IDArea = a.IDArea      
					left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
					left join Seguridad.vwPermisosUsuariosController puc on   
					  puc.IDController = c.IDController
						and puc.IDUsuario = @IDUsuario 
						and puc.IDUrl = u.IDUrl
					left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
						and tpu.Prioridad >= tp.Prioridad      
				WHERE
					M.ParentID = 0      
				   and m.IDAplicacion = @IDAplicacion
				  order by m.Orden
				    for json auto) AS Aplicacion



		

END
GO
