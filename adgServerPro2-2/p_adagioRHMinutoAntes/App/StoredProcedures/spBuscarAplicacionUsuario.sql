USE [p_adagioRHMinutoAntes]
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
***************************************************************************************************/
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
		,JSON_VALUE(ISNULL(ca.TraduccionCustom, ca.Traduccion), FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as DescripcionAplicacion
		,ca.Icon
		,ca.[Url]
		,Permiso = case when ap.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,PermisoUsuarioLogin = case when apUsuarioLogin.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,@IDUsuario as IDUsuario  
		,ISNULL(SoloEmpleados, 0)
	from  [App].[tblCatAplicaciones] ca  
		left join [App].[tblAplicacionUsuario] ap on ap.IDAplicacion = ca.IDAplicacion and ap.IDUsuario = @IDUsuario  
		left join [App].[tblAplicacionUsuario] apUsuarioLogin on ca.IDAplicacion = apUsuarioLogin.IDAplicacion and apUsuarioLogin.IDUsuario = @IDUsuarioLogin
		left join [Seguridad].[tblUsuarios] U on  U.IDUsuario=@IDUsuario -- AP.IDUsuario = U.IDUsuario and
	where ISNULL(SoloEmpleados, 0) = case when U.IDEmpleado is not null then ISNULL(SoloEmpleados, 0) else cast(0 as bit) end  
		--	and ap.AplicacionPersonalizada is not null
	order by ca.Orden asc
GO
