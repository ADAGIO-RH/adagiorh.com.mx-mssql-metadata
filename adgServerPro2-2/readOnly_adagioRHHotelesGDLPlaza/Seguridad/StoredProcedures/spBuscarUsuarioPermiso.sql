USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarUsuarioPermiso] --5,  'Seguridad/Perfiles/Read'
(
	@IDUsuario int,
	@Url Varchar(max) = null
)
AS
BEGIN
	
	 select
	isnull(PP.IDUsuarioPermiso,0)as IDUsuarioPermiso
		,isnull(PP.IDUsuario,@IDUsuario) as IDUsuario
		,isnull(A.IDArea,0) as IDArea
		,A.Descripcion as Area
		,isnull(M.IDModulo,0) as IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,U.Descripcion as Accion
		,U.Tipo
		,cast(case when (pp.IDUrl is null) then 0 
			else 1
			end  as bit)as TienePermiso
	
	from App.tblCatUrls U
		left  join Seguridad.tblUsuariosPermisos PP
			on PP.IDUrl = U.IDUrl
				and PP.IDUsuario = @IDUsuario
				
	left join App.tblCatModulos M
			on M.IDModulo = U.IDModulo
		left join App.tblCatAreas A
			on A.IDArea = M.IDArea
	where U.URL = @Url
END

--select * from App.tblCatUrls U
--left  join Seguridad.tblUsuariosPermisos PP
--			on PP.IDUrl = U.IDUrl
--				and PP.IDUsuario = @IDUsuario
--left join App.tblCatModulos M
--			on M.IDModulo = U.IDModulo
--		left join App.tblCatAreas A
--			on A.IDArea = M.IDArea
--where URL = @Url
GO
