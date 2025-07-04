USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarAprobadores]  (
	@IDItem int
)
AS
BEGIN
	Select 
		A.IDAprobadorDocumento,
		a.IDDocumento,
		docs.Nombre as Documento,
		a.IDUsuario as IDAprobador,
		u.Nombre +' '+u.Apellido as Nombre,
		isnull(a.Aprobacion,0) as Aprobacion,
		a.Observacion,
		a.FechaAprobacion as FechaAprobacion,
		isnull(ua.Cuenta+' - '+ua.Nombre+' '+ua.Apellido,'') as [Publicador],
		a.Secuencia as Secuencia,
		ROW_NUMBER()Over(partition by a.secuencia order by a.IDAprobadorDocumento asc) as Orden,
		ROW_NUMBER()Over(order by a.IDAprobadorDocumento asc) as ROWNUMBER
	from Docs.tblAprobadoresDocumentos a
		inner join Seguridad.tblUsuarios u
			on a.IDUsuario = u.IDUsuario
		inner join Docs.tblCarpetasDocumentos docs
			on docs.TipoItem = 1
			and docs.IDItem = a.IDDocumento
		left join Seguridad.tblUsuarios ua
			on docs.IDPublicador = ua.IDUsuario
	where a.IDDocumento = @IDItem		 

END;
GO
