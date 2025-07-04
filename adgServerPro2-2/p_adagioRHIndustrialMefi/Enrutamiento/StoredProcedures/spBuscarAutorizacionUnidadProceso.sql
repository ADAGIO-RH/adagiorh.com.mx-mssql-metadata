USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Enrutamiento.spBuscarAutorizacionUnidadProceso
(
	@IDAutorizacionUnidadProceso int = 0,
	@IDRutaUnidadProceso int,
	@IDUsuario int
)
AS
BEGIN
	SELECT AUP.IDAutorizacionUnidadProceso
		,AUP.IDRutaUnidadProceso
		,AUP.IDSecuencia
		,AUP.IDUsuario
		,coalesce(U.Cuenta,'') +' - '+coalesce(U.Nombre,'') +' '+coalesce(U.Apellido,'') as Usuario
		,isnull(AUP.Autorizado,0) as Autorizado
		,CASE WHEN (ISNULL(AUP.Autorizado,0) = 0) THEN 'PENDIENTE'
			  WHEN (ISNULL(AUP.Autorizado,0) = 1) THEN 'AUTORIZADO'
			  WHEN (ISNULL(AUP.Autorizado,0) = 2) THEN 'RECHAZADO'
			  ELSE 'NO DEFINIDO'
			  END AutorizadoStr
		,isnull(AUP.FechaHoraAutorizacion,'9999-12-31') as FechaHoraAutorizacion
		,isnull(AUP.Observacion,'') as Observacion
	FROM Enrutamiento.tblAutorizacionUnidadProceso AUP
		inner join Seguridad.tblUsuarios U
			on AUP.IDUsuario = U.IDUsuario
	WHERE AUP.IDRutaUnidadProceso = @IDRutaUnidadProceso
	and (AUP.IDAutorizacionUnidadProceso = @IDAutorizacionUnidadProceso OR ISNULL(@IDAutorizacionUnidadProceso,0)= 0)
	ORDER BY AUP.FechaHoraAutorizacion ASC
END
GO
