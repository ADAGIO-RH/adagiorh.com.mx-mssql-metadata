USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatosProceso]
(
	@IDCandidatoProceso int = 0,
	@IDCandidato int = 0
)
AS
BEGIN

declare 
    @IDIdioma varchar(20);

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	SELECT Proceso.[IDCandidatoProceso]
		  ,Proceso.[IDCandidato]
		  ,JSON_VALUE(Puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  as Descripcion
		  ,Proceso.[SueldoDeseado]
		  ,Proceso.[IDPuestoPreasignado]
		  ,Proceso.[SueldoPreasignado]
		  ,Proceso.[IDEstatusProceso]
		  ,ROW_NUMBER()over(ORDER BY Proceso.[IDCandidatoProceso])as ROWNUMBER
	  FROM [Reclutamiento].[tblCandidatosProceso] Proceso
	  left join RH.tblCatPlazas Plazas on Proceso.IDPlaza = Plazas.IDPlaza
	  left join RH.tblCatPuestos Puestos on Plazas.IDPuesto = Puestos.IDPuesto
	   WHERE 
	   ([IDCandidatoProceso] = @IDCandidatoProceso OR isnull(@IDCandidatoProceso,0) = 0)
	   AND ([IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)
	 
END
GO
