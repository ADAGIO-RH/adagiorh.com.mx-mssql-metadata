USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Pasos de las Rutas
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2022-02-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Enrutamiento].[spBuscarRutaStep]
(
	@IDRutaStep int = 0,
	@IDCatRuta int,
	@IDUsuario int
)
AS
BEGIN
	Select 
	RS.IDRutaStep
	,RS.IDCatRuta
	,R.Nombre as Ruta
	,RS.IDCatTipoStep
	,TS.Codigo as TipoStep
	,TS.Data as TipoStepData
	,RS.Orden
	from Enrutamiento.tblRutaSteps RS WITH(NOLOCK)
		INNER JOIN Enrutamiento.TblCatRutas R WITH(NOLOCK)
			ON RS.IDCatRuta = R.IDCatRuta
		INNER JOIN Enrutamiento.[tblCatTiposSteps] TS WiTH(NOLOCK)
			on TS.IDCatTipoStep = RS.IDCatTipoStep
	WHERE RS.IDCatRuta = @IDCatRuta
	and ((RS.IDRutaStep = @IDRutaStep)OR(ISNULL(@IDRutaStep,0) = 0))
	ORDER BY RS.Orden ASC

END
GO
