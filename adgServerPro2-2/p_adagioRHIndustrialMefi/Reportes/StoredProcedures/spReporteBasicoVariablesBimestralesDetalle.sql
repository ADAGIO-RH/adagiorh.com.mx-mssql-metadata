USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-31
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Reportes].[spReporteBasicoVariablesBimestralesDetalle](    	
    @IDCalculoVariablesBimestralesMaster int 
    -- Add additional parameters as needed
)
AS
BEGIN

    SELECT 
         [CC].Codigo                    AS [Codigo]
        ,[CC].Descripcion               AS [Descripcion]
        ,[DETALLE].[Integrable]         AS [Integrable]
        ,[DETALLE].[Importetotal1]      AS [ImporteTotal1]
    FROM NOMINA.TblCalculoVariablesBimestralesDetalle DETALLE
    INNER JOIN NOMINA.tblCatConceptos CC
        ON CC.IDCONCEPTO=DETALLE.IDConcepto        
    WHERE IDCalculoVariablesBimestralesMaster = @IDCalculoVariablesBimestralesMaster

END
GO
