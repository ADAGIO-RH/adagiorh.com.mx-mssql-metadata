USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from  [App].[tblAplicacionUsuario] where IDUsuario = 1


--[App].[spBuscarAplicacionUsuario] 2891,1
--GO

CREATE proc [App].[spBuscarAplicacionUsuario](      
	@IDUsuario int,      
	@IDUsuarioLogin int  
) as   
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select       
		isnull(ap.IDAplicacionUsuario,0) as IDAplicacionUsuario      
		,ca.IDAplicacion      
		--,ca.Descripcion as DescripcionAplicacion     
		,JSON_VALUE(ca.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as DescripcionAplicacion
		,ca.Icon
		,ca.Url  
		,Permiso = case when ap.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,PermisoUsuarioLogin = case when apUsuarioLogin.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,@IDUsuario as IDUsuario  
	from  [App].[tblCatAplicaciones] ca  
		left join [App].[tblAplicacionUsuario] ap on ap.IDAplicacion = ca.IDAplicacion and ap.IDUsuario = @IDUsuario  
		left join [App].[tblAplicacionUsuario] apUsuarioLogin on ca.IDAplicacion = apUsuarioLogin.IDAplicacion and apUsuarioLogin.IDUsuario = @IDUsuarioLogin  
		--	and ap.AplicacionPersonalizada is not null
	order by ca.Orden asc
GO
