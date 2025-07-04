USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure IMSS.spBuscarTiposReportesSuaIDSE
(
	@IDTipoReporte int
)
AS
BEGIN
	-- 1 : SUA
	-- 2 : IDSE
	-- 3 : AMBOS

	IF(@IDTipoReporte = 1)
	BEGIN
		SELECT IDReporte
				,Descripcion
				,SUA
				,IDSE
		FROM IMSS.tblcatReportesSuaIdse
		WHERE SUA = 1
	END

	IF(@IDTipoReporte = 2)
	BEGIN
		SELECT IDReporte
				,Descripcion
				,SUA
				,IDSE
		FROM IMSS.tblcatReportesSuaIdse
		WHERE IDSE = 1
	END

	IF(@IDTipoReporte = 3)
	BEGIN
		SELECT IDReporte
				,Descripcion
				,SUA
				,IDSE
		FROM IMSS.tblcatReportesSuaIdse
	END
END
GO
