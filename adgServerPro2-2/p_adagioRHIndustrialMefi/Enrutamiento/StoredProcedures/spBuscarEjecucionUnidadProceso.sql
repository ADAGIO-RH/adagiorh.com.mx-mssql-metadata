USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spBuscarEjecucionUnidadProceso]
(
	@IDEjecucionUnidadProceso int = 0,
	@IDRutaUnidadProceso int,
	@IDUsuario int
)
AS
BEGIN
	SELECT EUP.IDEjecucionUnidadProceso
		,EUP.IDRutaUnidadProceso
		,EUP.IDUsuario
		,coalesce(U.Cuenta,'') +' - '+coalesce(U.Nombre,'') +' '+coalesce(U.Apellido,'') as Usuario
		,isnull(EUP.Realizado,0) as Realizado
		,CASE WHEN (ISNULL(EUP.Realizado,0) = 0) THEN 'NO'
			  WHEN (ISNULL(EUP.Realizado,0) = 1) THEN 'SI'
			  ELSE 'NO DEFINIDO'
			  END RealizadoStr
		,isnull(EUP.FechaHoraRealizacion,'9999-12-31') as FechaHoraRealizacion
	FROM Enrutamiento.tblEjecucionUnidadProceso EUP
		inner join Seguridad.tblUsuarios U
			on EUP.IDUsuario = U.IDUsuario
	WHERE EUP.IDRutaUnidadProceso = @IDRutaUnidadProceso
	and (EUP.IDEjecucionUnidadProceso = @IDEjecucionUnidadProceso OR ISNULL(@IDEjecucionUnidadProceso,0)= 0)
	ORDER BY EUP.FechaHoraRealizacion  ASC
END
GO
