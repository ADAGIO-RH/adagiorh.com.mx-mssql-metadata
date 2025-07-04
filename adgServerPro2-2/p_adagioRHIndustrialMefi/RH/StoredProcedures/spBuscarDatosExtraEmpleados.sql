USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarDatosExtraEmpleados](
	@IDEmpleado int
) AS
BEGIN
	SELECT
			DE.IDDatoExtra
			,DE.Nombre
			,DE.Descripcion
			,DE.TipoDato
			,ISNULL(DEE.IDDatoExtraEmpleado,0) IDDatoExtraEmpleado
			,CASE WHEN (DE.TipoDato in ('bool','BIT'))THEN ISNULL(DEE.Valor,'false')
				WHEN (DE.TipoDato in ('string','Varchar'))THEN ISNULL(DEE.Valor,'')
				WHEN (DE.TipoDato in ('Date'))THEN ISNULL(DEE.Valor,'')
				WHEN (DE.TipoDato in ('INT','FLOAT','REAL','DECIMAL', 'NUMERIC'))THEN ISNULL(DEE.Valor,'0')
			 ELSE '0'
			 END as Valor
			,@IDEmpleado as IDEmpleado
			,ROW_NUMBER()Over(Order by DE.IDDatoExtra ASC) ROWNUMBER
	FROM RH.tblCatDatosExtra DE
		left join RH.tblDatosExtraEmpleados DEE on DE.IDDatoExtra = DEE.IDDatoExtra
	  and  DEE.IDEmpleado = @IDEmpleado	
END
GO
