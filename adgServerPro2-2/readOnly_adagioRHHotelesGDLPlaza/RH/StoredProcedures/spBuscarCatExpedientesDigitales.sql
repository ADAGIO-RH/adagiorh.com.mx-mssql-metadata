USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de ExpedientesDigitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarCatExpedientesDigitales]
(
	@IDExpedienteDigital int = 0,
	@IDUsuario int = 0
)
AS
BEGIN
      SELECT
	   [IDExpedienteDigital]
      ,[Codigo]
      ,[Descripcion]
      ,[Requerido]
	  ,iif([Requerido] = 1,'Si','No') as [RequeridoTexto]
	  ,ROW_NUMBER()over(ORDER BY [IDExpedienteDigital])as ROWNUMBER
  FROM [RH].[tblCatExpedientesDigitales]
  WHERE (IDExpedienteDigital = @IDExpedienteDigital OR isnull(@IDExpedienteDigital,0) = 0)

END
GO
