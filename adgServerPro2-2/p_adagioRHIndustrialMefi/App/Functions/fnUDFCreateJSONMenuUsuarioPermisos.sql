USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [App].[fnUDFCreateJSONMenuUsuarioPermisos](
	@IDUsuario int, 
	@parentID int,
	@IDAplicacion nvarchar(100)
	) 
returns varchar(max)
begin 
    declare @json varchar(max) 

	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', 1, 'esmx'), '-',''))	

        set @json =  
            (
              	select   
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
				   ,CAST(CASE WHEN (isnull(tpu.Prioridad,'') >= isnull(tp.Prioridad,'') ) THEN 1 ELSE 0 END as Bit) TienePermiso
				   ,isnull(puc.IDTipoPermiso,'') as IDTipoPermiso
                   ,isnull(case when IDPermisoUsuarioController <> 0 then 1 else 0 end,'') as PermisoPersonalizado
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuUsuarioPermisos](@IDUsuario,M.IDMenu,@IDAplicacion)) AS Childrens
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](@IDUsuario,isnull(M.IDUrl,0 ),null)) AS Especiales
				from App.tblMenu M        
					left join app.tblCatUrls u on m.IDUrl = u.IDUrl      
					left join app.tblCatControllers c on u.IDController = c.IDController      
					left join app.tblCatAreas a on c.IDArea = a.IDArea      
					left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
					left join Seguridad.vwPermisosUsuariosController puc on   
					  puc.IDController = c.IDController
						and puc.IDUsuario = @IDUsuario 
						and u.IDUrl = puc.IDUrl
					left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
						and tpu.Prioridad >= tp.Prioridad      
				 Where         
					M.ParentID = @parentID      
				   and m.IDAplicacion = @IDAplicacion 
				   --and puc.IDUsuario = @IDUsuario
				    for json auto
            );

    return @json  
end
GO
