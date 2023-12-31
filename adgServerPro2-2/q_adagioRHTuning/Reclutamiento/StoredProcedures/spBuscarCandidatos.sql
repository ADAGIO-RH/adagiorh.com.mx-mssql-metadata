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
CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatos](
	@IDCandidato int = 0
)
AS
BEGIN

	DECLARE 
		@IDDocumentoTrabajoPasaporte int,
		@IDTipoCatalogo int = 7 -- Tipos de medios de reclutamiento
	;

	SELECT 
		@IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM [Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE [Descripcion] = 'PASAPORTE'

	SELECT 
		 [Candidato].[IDCandidato]  as [IDCandidato]
		,[Candidato].[Nombre]
		,[Candidato].[SegundoNombre]
		,[Candidato].[Paterno]
		,[Candidato].[Materno]
		,[Candidato].[Sexo]
		,[Candidato].[FechaNacimiento]
		,[Candidato].[IDPaisNacimiento]
		,[Candidato].[IDEstadoNacimiento]
		,[Candidato].[IDMunicipioNacimiento]
		,[Candidato].[IDLocalidadNacimiento]
		,[Candidato].[RFC]
		,[Candidato].[CURP]
		,[Candidato].[NSS]
		,[Candidato].[IDAfore]
		,[Candidato].[IDEstadoCivil]
		,[Candidato].[Estatura]
		,[Candidato].[Peso]
		,[Candidato].[TipoSangre]
		,[Candidato].[Extranjero]
		,ISNULL(Pasaporte.Validacion,'') as [NumeroPasaporte]
		,ISNULL(CandidatosProceso.[VacanteDeseada],'') as [VacanteDeseada]
		,ISNULL(CandidatosProceso.[SueldoDeseado],'') as [SueldoDeseado]
		,ISNULL(TelCelular.Value,'') as [TelefonoCelular]
		,ISNULL(TelFijo.Value,'') as [TelefonoFijo]
		,ISNULL(CorreoElectronico.Value,'') as [CorreoElectronico]
		,Pasaporte.Validacion as [NumPasaporte]
		,ISNULL(DireccionCandidato.IDPais,0)	as [IDPaisResidencia]
		,ISNULL(DireccionCandidato.IDEstado,0)	as [IDEstadoResidencia]
		,ISNULL(DireccionCandidato.IDMunicipio,0)	as [IDMunicipioResidencia]
		,ISNULL(DireccionCandidato.IDLocalidad,0)	as [IDLocalidadResidencia]
		,ISNULL(DireccionCandidato.IDCodigoPostal,0)as [IDCodigoPostalResidencia]
		,ISNULL(DireccionCandidato.IDColonia,0)	as [IDColoniaResidencia]

		,ISNULL(DireccionCandidato.Calle,'') as [CalleResidencia]
		,ISNULL(DireccionCandidato.NumExt,'')	as [NumeroExtResidencia]
		,ISNULL(DireccionCandidato.NumInt,'') as [NumeroIntResidencia]
        ,isnull(cp.CodigoPostal,'') as [CodigoPostalResidencia]

		,ISNULL(CandidatosProceso.IDPuestoPreasignado,0) as [IDPuestoPreasignado]
		,ISNULL(CandidatosProceso.[SueldoPreasignado],'') as [SueldoPreasignado]
		,ISNULL(CandidatosProceso.IDEstatusProceso,0) as [IDEstatusProceso]

        ,ISNULL(Puestos.Descripcion,'SIN PUESTO PREASIGNADO') as [PuestoPreasignado]
		,ISNULL(EstatusProceso.Descripcion,'SIN ESTATUS') as [EstatusProceso]
		,ISNULL(candidato.IDMedioReclutamiento, 0)  as IDMedioReclutamiento
		,tiposMedios.Catalogo as TipoMedioReclutamiento
		,ISNULL(mr.Nombre, 'SIN MEDIO DE RECLUTAMIENTO')  as MedioReclutamiento
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER

	FROM [Reclutamiento].[tblCandidatos] Candidato
		LEFT JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelCelular ON Candidato.IDCandidato = TelCelular.IDCandidato and TelCelular.IDTipoContacto = 1
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelFijo ON Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDTipoContacto = 2
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] CorreoElectronico ON Candidato.IDCandidato = CorreoElectronico.IDCandidato and CorreoElectronico.IDTipoContacto = 3
		LEFT JOIN [Reclutamiento].[tblDocumentosTrabajoCandidato] Pasaporte on Candidato.IDCandidato = Pasaporte.IDCandidato and Pasaporte.IDDocumentoTrabajo = @IDDocumentoTrabajoPasaporte
		LEFT JOIN [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on CandidatosProceso.IDEstatusProceso = EstatusProceso.IDEstatusProceso
		LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato
		LEFT JOIN [Reclutamiento].[tblMediosReclutamiento] mr on mr.IDMedioReclutamiento = candidato.IDMedioReclutamiento
		left join (
			select * 
			from App.tblCatalogosGenerales cg
			where IDTipoCatalogo = @IDTipoCatalogo
		) tiposMedios on tiposMedios.IDCatalogoGeneral = mr.IDTipoMedioReclutamiento
		LEFT JOIN sat.tblCatCodigosPostales as cp on cp.IDCodigoPostal=DireccionCandidato.IDCodigoPostal
		LEFT JOIN [RH].[tblCatPuestos] Puestos on CandidatosProceso.IDPuestoPreasignado = Puestos.IDPuesto
	WHERE (Candidato.[IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)



END
GO
