USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Seguridad.spBuscarUsuarioPermisos --7
(
	@IDUsuario int

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
		left outer join Seguridad.tblUsuariosPermisos PP
			on PP.IDUrl = U.IDUrl
				and PP.IDUsuario = @IDUsuario
		Inner join App.tblCatModulos M
			on M.IDModulo = U.IDModulo
		Inner join App.tblCatAreas A
			on A.IDArea = M.IDArea
	
END
GO
