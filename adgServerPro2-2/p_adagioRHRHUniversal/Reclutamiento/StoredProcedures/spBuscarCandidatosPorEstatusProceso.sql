USE [p_adagioRHRHUniversal]
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
	,@IDPlaza int = 0
)
AS
BEGIN
/*
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
		,CandidatosProceso.IDEstatusProceso
		*/

SELECT        
		cp.IDCandidatoPlaza, 
		cp.IDCandidato, 
		c.Nombre, 
		c.SegundoNombre, 
		c.Paterno, 
		c.Materno, 
		c.Sexo, 
		c.FechaNacimiento, 
		c.IDPaisNacimiento, 
		c.IDEstadoNacimiento, 
		c.IDMunicipioNacimiento, 
		c.IDLocalidadNacimiento, 
		c.RFC, 
        c.CURP,
		c.NSS,
		c.IDAFORE,
		c.IDEstadoCivil,
		c.Estatura,
		c.Peso,
		c.TipoSangre,
		c.Extranjero,
		EP.IDEstatusProceso
		,ROW_NUMBER()over(ORDER BY cp.[IDCandidato])as ROWNUMBER
FROM            Reclutamiento.tblCandidatoPlaza AS cp INNER JOIN
                         Reclutamiento.tblCatEstatusProceso AS EP ON EP.IDEstatusProceso = cp.IDProceso INNER JOIN
                         Reclutamiento.tblCandidatos AS c ON cp.IDCandidato = c.IDCandidato INNER JOIN
                         RH.tblCatPlazas AS pla ON cp.IDPlaza = pla.IDPlaza INNER JOIN
                         RH.tblCatPuestos AS catPue ON pla.IDPuesto = catPue.IDPuesto
	
	WHERE 
		(EP.[IDEstatusProceso] = @IDEstatusProceso OR isnull(@IDEstatusProceso,-1) = -1)
		AND
		(cp.IDPlaza = @IDPlaza or ISNULL(@IDPlaza,0) = 0)

END
GO
