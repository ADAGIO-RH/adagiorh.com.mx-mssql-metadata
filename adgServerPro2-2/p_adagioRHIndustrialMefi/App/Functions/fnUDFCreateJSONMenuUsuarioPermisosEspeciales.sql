USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*select [App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](5060,1217,0) */

CREATE function [App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](
	@IDUsuario int, 
	@parentID int,
	@CodigoParent varchar(20)
	
) 
returns varchar(max)
begin 
    declare @json varchar(max) 

	--@IDUsuario int = 3914, 
	--@parentID int = 1218,
	--@CodigoParent varchar(20) = null

	
set @json =  
            (
              	select   
					isnull(PE.IDPermiso ,0) as id       
				   ,isnull(PE.IDUrlParent,0 )  as IDUrlParent     
				   ,isnull(PE.Codigo,'') Codigo       
				   ,isnull(PE.CodigoParent,'')as  CodigoParent        
				   ,isnull(PE.Descripcion,'')as  [text]
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](@IDUsuario,@parentID, PE.Codigo)) AS items
				   ,peu.TienePermiso as  checked
                   ,cast(isnull(case when peu.IDPermisoEspecialUsuario <> 0 then 1 else 0 end,'') as bit) as PermisoPersonalizado
				from App.tblCatPermisosEspeciales PE
					inner join Seguridad.vwPermisosEspecialesUsuarios peu
						on pe.IDPermiso = peu.IDPermiso
						and peu.IDUsuario = @IDUsuario
				 Where         
					PE.IDUrlParent= @parentID 
					and isnull(PE.CodigoParent,'') = isnull(@CodigoParent,'')
					and peu.IDUsuario = @IDUsuario
				    for json auto
            );

    return @json  
end
GO
