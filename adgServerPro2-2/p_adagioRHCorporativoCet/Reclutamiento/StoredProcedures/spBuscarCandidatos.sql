USE [p_adagioRHCorporativoCet]
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
CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatos]
(
	@IDCandidato int = 0
)
AS
BEGIN

	DECLARE @IDDocumentoTrabajoPasaporte INT;

	SELECT 
		@IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM 
		[Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE 
		[Descripcion] = 'PASAPORTE'


			SELECT 

		 [Candidato].[IDCandidato]  as [IDCandidato]
		,[Nombre]
		,[SegundoNombre]
		,[Paterno]
		,[Materno]
		,[Sexo]
		,[FechaNacimiento]
		,[IDPaisNacimiento]
		,[IDEstadoNacimiento]
		,[IDMunicipioNacimiento]
		,[IDLocalidadNacimiento]
		,[RFC]
		,[CURP]
		,[NSS]
		,[IDAfore]
		,[IDEstadoCivil]
		,[Estatura]
		,[Peso]
		,[TipoSangre]
		,[Extranjero]
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
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER

	FROM [Reclutamiento].[tblCandidatos] Candidato
	LEFT JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelCelular ON Candidato.IDCandidato = TelCelular.IDCandidato and TelCelular.IDTipoContacto = 1
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelFijo ON Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDTipoContacto = 2
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] CorreoElectronico ON Candidato.IDCandidato = CorreoElectronico.IDCandidato and CorreoElectronico.IDTipoContacto = 3
	LEFT JOIN [Reclutamiento].[tblDocumentosTrabajoCandidato] Pasaporte on Candidato.IDCandidato = Pasaporte.IDCandidato and Pasaporte.IDDocumentoTrabajo = @IDDocumentoTrabajoPasaporte
    LEFT JOIN [RH].[tblCatPuestos] Puestos on CandidatosProceso.IDPuestoPreasignado = Puestos.IDPuesto
	LEFT JOIN [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on CandidatosProceso.IDEstatusProceso = EstatusProceso.IDEstatusProceso
	LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato
    LEFT JOIN sat.tblCatCodigosPostales as cp on cp.IDCodigoPostal=DireccionCandidato.IDCodigoPostal
	WHERE (Candidato.[IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)



END
GO
