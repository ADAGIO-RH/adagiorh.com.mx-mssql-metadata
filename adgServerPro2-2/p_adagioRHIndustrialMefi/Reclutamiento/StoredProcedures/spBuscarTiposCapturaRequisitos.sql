USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Reclutamiento.spBuscarTiposCapturaRequisitos
(
	@IDTipoCapturaRequisito int  = 0
)
AS
BEGIN
	SELECT 
		IDTipoCapturaRequisito
		,Texto
		,Tipo
	FROM Reclutamiento.tblCatTiposCapturaRequisitos
	WHERE IDTipoCapturaRequisito = @IDTipoCapturaRequisito OR ISNULL(@IDTipoCapturaRequisito,0) = 0
	ORDER BY IDTipoCapturaRequisito
END
GO
