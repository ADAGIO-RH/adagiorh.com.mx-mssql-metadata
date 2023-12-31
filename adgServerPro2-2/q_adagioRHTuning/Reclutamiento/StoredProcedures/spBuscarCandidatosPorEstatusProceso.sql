USE [q_adagioRHTuning]
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
CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatosPorEstatusProceso]
(
	@IDEstatusProceso int = -1
)
AS
BEGIN
	DECLARE 
		@IDTipoCatalogo int = 7 -- Tipos de medios de reclutamiento
	;

	SELECT 
		 Candidato.[IDCandidato]
		,Candidato.[Nombre]
		,Candidato.[SegundoNombre]
		,Candidato.[Paterno]
		,Candidato.[Materno]
		,Candidato.[Sexo]
		,Candidato.[FechaNacimiento]
		,Candidato.[IDPaisNacimiento]
		,Candidato.[IDEstadoNacimiento]
		,Candidato.[IDMunicipioNacimiento]
		,Candidato.[IDLocalidadNacimiento]
		,Candidato.[RFC]
		,Candidato.[CURP]
		,Candidato.[NSS]
		,Candidato.[IDAfore]
		,Candidato.[IDEstadoCivil]
		,Candidato.[Estatura]
		,Candidato.[Peso]
		,Candidato.[TipoSangre]
		,Candidato.[Extranjero]
		,CandidatosProceso.IDEstatusProceso
		,ISNULL(candidato.IDMedioReclutamiento, 0)  as IDMedioReclutamiento
		,tiposMedios.Catalogo as TipoMedioReclutamiento
		,ISNULL(mr.Nombre, 'SIN MEDIO DE RECLUTAMIENTO')  as MedioReclutamiento
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER
	FROM [Reclutamiento].[tblCandidatos] Candidato
		INNER JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON Candidato.IDCandidato = CandidatosProceso.IDCandidato
		LEFT JOIN [Reclutamiento].[tblMediosReclutamiento] mr on mr.IDMedioReclutamiento = candidato.IDMedioReclutamiento
		left join (
			select * 
			from App.tblCatalogosGenerales cg
			where IDTipoCatalogo = @IDTipoCatalogo
		) tiposMedios on tiposMedios.IDCatalogoGeneral = mr.IDTipoMedioReclutamiento
	WHERE ([IDEstatusProceso] = @IDEstatusProceso OR isnull(@IDEstatusProceso,-1) = -1)

END
GO
