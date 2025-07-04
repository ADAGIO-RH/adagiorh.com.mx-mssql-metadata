USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Seguridad].[vwAplicacionesUsuarios]
AS
	SELECT 
		isnull(AU.IDAplicacionUsuario,0) as IDAplicacionUsuario      
		,ca.IDAplicacion      
		--,ca.Descripcion as DescripcionAplicacion   
		,ca.TraduccionCustom
		,ca.Traduccion
		,ca.Icon
		,ca.[Url]
		--,Permiso = case when AP.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,Permiso = case when isnull(AP.IDAplicacionPerfil,0) <> 0  OR isnull(AU.AplicacionPersonalizada,0) <> 0 or isnull(AU.IDAplicacionUsuario,0) <> 0 THEN cast(1 as bit) 
						else cast(0 as bit) end      

		,isnull(u.IDPerfil,0) as IDPerfil 
        ,isnull(Ap.IDAplicacionPerfil,0) as PermisoPerfil 
		,isnull(u.IDUsuario,0) as IDUsuario 
        ,isnull(Au.IDAplicacionUsuario,0) as PermisoUsuario
		,ISNULL(ca.SoloEmpleados, 0) as SoloEmpleados
		,ca.Orden
	FROM [App].[tblCatAplicaciones] ca  with(nolock)
	CROSS APPLY [Seguridad].[tblCatPerfiles] p  with(nolock)
	CROSS APPLY [Seguridad].[tblUsuarios] U with(nolock)
	LEFT JOIN [App].[tblAplicacionPerfiles] AP with(nolock)
		on AP.IDAplicacion = CA.IDAplicacion
		and AP.IDPerfil = P.IDPerfil
	LEFT JOIN [app].[tblAplicacionUsuario] AU with(nolock)
		on AU.IDUsuario = U.IDUsuario
		and AU.IDAplicacion = CA.IDAplicacion
	WHERE p.IDPerfil = U.IDPerfil
	--ORDER BY u.IDUsuario desc

	
	
	--LEFT JOIN [App].[tblAplicacionUsuario] AU with(nolock)
	--	on AU.IDAplicacion = CA.IDAplicacion
	--LEFT JOIN [Seguridad].[tblUsuarios] U with(nolock)
	--	on U.IDUsuario = AU.IDUsuario
	--LEFT JOIN [App].[tblAplicacionPerfiles] AP with(nolock)
	--	on ca.IDAplicacion = ap.IDAplicacion
	--	and U.IDPerfil = AP.IDPerfil
	----WHERE p.IDPerfil = 8

	--ORDER BY u.IDUsuario desc
GO
