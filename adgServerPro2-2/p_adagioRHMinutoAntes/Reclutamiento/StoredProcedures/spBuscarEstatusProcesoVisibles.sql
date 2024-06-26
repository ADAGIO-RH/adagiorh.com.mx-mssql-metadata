USE [p_adagioRHMinutoAntes]
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

SELECT pr.[IDEstatusProceso]
      ,pr.[Descripcion]
      ,pr.[Orden]
	  ,pr.[Color]
	  ,pr.[ProcesoFinal]
	  ,isnull(pr.[IDPlantilla],0) IDPlantilla
	  ,isnull(pl.[Descripcion],'') DescripcionPlantilla
  FROM [Reclutamiento].[tblCatEstatusProceso] pr
  LEFT JOIN [Reclutamiento].[tblPlantillas] pl ON pl.IDPlantilla = pr.IDPlantilla
  where  pr.[MostrarEnProcesoSeleccion] = 1
  order by orden

END

select * from Reclutamiento.tblPlantillas
GO
