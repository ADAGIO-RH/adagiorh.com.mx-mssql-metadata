USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las aplicaciones asignadas a un usuario
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2017-12-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-08-26			Andrea Zaionos		Se agrega Condicion de la visualizacion de las aplicaciones cuando el usuario es un empleado o no
2022-08-30			Aneudy Abreu		Se agregó un ISNULL en where para el campo  ISNULL(SoloEmpleados, 0)
2024-05-18			Jose Roman			Se agrega validación para verificar el contenido de las preferencias de idioma del usuario.	
***************************************************************************************************/
/*
exec [App].[spBuscarAplicacionUsuario]--5060,1
*/
CREATE proc [App].[spBuscarAplicacionUsuario]--68,1
(      
	@IDUsuario int,      
	@IDUsuarioLogin int
) as   
	declare 
		@IDIdioma varchar(20),
        @IDPerfilLogin int
	;

	select @IDIdioma= CASE WHEN ISNULL(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'),'') = '' THEN 'esmx' else  App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx') end
    select @IDPerfilLogin = IDperfil from Seguridad.tblUsuarios where IDUsuario = @IDUsuarioLogin

	

	select       
		isnull(ap.IDAplicacionUsuario,0) as IDAplicacionUsuario      
		,ca.IDAplicacion      
		--,ca.Descripcion as DescripcionAplicacion     
		,JSON_VALUE(ISNULL(ca.TraduccionCustom, ca.Traduccion), FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as DescripcionAplicacion
		,ca.Icon
		,ca.[Url]
		,Permiso = ap.Permiso--case when ap.Permiso is not null then cast(1 as bit) else cast(0 as bit) end      
		,PermisoUsuarioLogin = case when (apUsuarioLogin.IDAplicacionUsuario is not null OR apPerfilLogin.IDAplicacionPerfil is not null) then cast(1 as bit) else cast(0 as bit) end      
		,@IDUsuario as IDUsuario  
		,ISNULL(ca.SoloEmpleados, 0) as SoloEmpleados
		,isnull(CA.Orden,0) as Orden
        ,CAST (case when ap.permisoUsuario <> 0 then 1 else 0 end as bit) as PermisoPersonalizado
	from  [App].[tblCatAplicaciones] ca  
		left join  Seguridad.vwAplicacionesUsuarios ap on ap.IDAplicacion = ca.IDAplicacion and ap.IDUsuario = @IDUsuario  
		left join [Seguridad].[tblUsuarios] U on  U.IDUsuario=@IDUsuario and  (AP.IDUsuario = U.IDUsuario OR AP.IDPerfil = U.IDPerfil)
		left join [App].[tblAplicacionUsuario] apUsuarioLogin on ca.IDAplicacion = apUsuarioLogin.IDAplicacion and apUsuarioLogin.IDUsuario = @IDUsuarioLogin
        left join [App].[tblAplicacionPerfiles] apPerfilLogin on ca.IDAplicacion = apPerfilLogin.IDAplicacion and apPerfilLogin.IDPerfil = @IDPerfilLogin
	--where ISNULL(ca.SoloEmpleados, 0) = case when U.IDEmpleado is not null then ISNULL(ca.SoloEmpleados, 0) else cast(0 as bit) end  
		--	and ap.AplicacionPersonalizada is not null
	order by ca.Orden asc
GO
