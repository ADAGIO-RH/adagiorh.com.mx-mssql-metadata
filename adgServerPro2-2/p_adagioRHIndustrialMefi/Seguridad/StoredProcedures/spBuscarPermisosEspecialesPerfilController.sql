USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE PROCEDURE [Seguridad].[spBuscarPermisosEspecialesPerfilController](  
	@IDController int,  
	@IDPerfil int,
	@IDUsuario int
)  
AS  
BEGIN  
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	
	select 
		c.IDController  
		,c.Descripcion as Controller  
		,u.IDUrl  
		,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as UrlDescripcion
		,pe.IDPermiso  
		,pe.Codigo codigoPermiso  
		,pe.CodigoParent
		,pe.Descripcion DescripcionPermiso  
		,cast(case when pep.IDPermisoEspecialPerfil is null then 0  
		else 1  
		end as bit) TienePermiso   
		,@IDPerfil as IDPerfil  
	from app.tblCatControllers c  
		inner join app.tblCatUrls u on c.IDController = u.IDController  
		inner join app.tblCatPermisosEspeciales pe on u.IDUrl = pe.IDUrlParent  
		left join Seguridad.tblPermisosEspecialesPerfiles pep on pep.IDPermiso = pe.IDPermiso  
			and pep.IDPerfil = @IDPerfil  
	where c.IDController = @IDController  
	order by pe.CodigoParent
  
  
END
GO
