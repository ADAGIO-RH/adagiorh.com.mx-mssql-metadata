USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Procom.fnBuscarUltimoEstatusCuotaAfiliacion(
	@IDClienteCuotaAfiliacion int,
	@IDUsuario int
)
RETURNS TABLE  
AS  
RETURN  
    SELECT Top 1 
		E.IDClienteCuotaAfiliacionEstatus
		,E.IDClienteCuotaAfiliacion
		,E.IDCatEstatusCuotaAfiliacion
		,CE.Descripcion as EstatusCuotaAfiliacion
		,isnull(CE.LayoutDescargable,0) as LayoutDescargable
		,E.FechaHora
	FROM PROCOM.tblClienteCuotaAfiliacionEstatus E with(nolock)
		inner join Procom.tblCatEstatusCuotaAfiliacion CE with(nolock)
			on E.IDCatEstatusCuotaAfiliacion = Ce.IDCatEstatusCuotaAfiliacion
	WHERE e.IDClienteCuotaAfiliacion=@IDClienteCuotaAfiliacion 
	ORDER BY E.FechaHora desc
GO
