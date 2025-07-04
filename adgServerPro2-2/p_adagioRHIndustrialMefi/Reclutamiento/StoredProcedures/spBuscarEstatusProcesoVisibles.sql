USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: 
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
2024-03-27		    ANEUDY ABREU		    Agrega traducción de la tabla Reclutamiento.tblCatEstatusProceso
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarEstatusProcesoVisibles](
	@IDEstatusProceso int = 0,
	@IDUsuario int
)
AS
BEGIN
	declare  
	   @IDIdioma varchar(10)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		pr.[IDEstatusProceso]
		,JSON_VALUE(pr.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus
		,JSON_VALUE(pr.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
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
GO
