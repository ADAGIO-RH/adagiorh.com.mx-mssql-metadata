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
CREATE PROCEDURE [Reclutamiento].[spBuscarEstatusProcesoVisibles]
(
	@IDEstatusProceso int = 0
)
AS
BEGIN



SELECT [IDEstatusProceso]
      ,[Descripcion]
      ,[Orden]
	  ,[Color]
  FROM [Reclutamiento].[tblCatEstatusProceso]
  where [MostrarEnProcesoSeleccion] = 1
  order by orden



END
GO
