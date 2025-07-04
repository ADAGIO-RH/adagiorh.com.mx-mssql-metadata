USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Reportes].[spReclutamientoEmpleadosDescartados] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

		Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@IDTipoContactoEmail int

		select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
			from @dtFiltros where Catalogo = 'FechaIni'
		select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
			from @dtFiltros where Catalogo = 'FechaFin'


					DECLARE @IDDocumentoTrabajoPasaporte INT;

	SELECT 
		@IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM 
		[Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE 
		[Descripcion] = 'PASAPORTE'


		select
		Candidato.[IDCandidato]  as [IDCandidato]
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
		--,CandidatosProceso.[VacanteDeseada]
		,CandidatosProceso.[SueldoDeseado]
		,ISNULL(TelCelular.Value,'') as [TelefonoCelular]
		,ISNULL(TelFijo.Value,'') as [TelefonoFijo]
		,ISNULL(CorreoElectronico.Value,'') as [CorreoElectronico]
		,'NumPasaporte' as [NumPasaporte]
		,ISNULL(DireccionCandidato.IDPais,0)	as [IDPaisResidencia]
		,ISNULL(DireccionCandidato.IDEstado,0)	as [IDEstadoResidencia]
		,ISNULL(DireccionCandidato.IDMunicipio,0)	as [IDMunicipioResidencia]
		,ISNULL(DireccionCandidato.IDLocalidad,0)	as [IDLocalidadResidencia]
		,ISNULL(DireccionCandidato.IDCodigoPostal,0)as [IDCodigoPostalResidencia]
		,ISNULL(DireccionCandidato.IDColonia,0)	as [IDColoniaResidencia]
		,ISNULL(DireccionCandidato.Calle,'') as [CalleResidencia]
		,ISNULL(DireccionCandidato.NumExt,'')	as [NumeroExtResidencia]
		,ISNULL(DireccionCandidato.NumInt,'') as [NumeroIntResidencia]
		,CandidatosProceso.IDEstatusProceso
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER

	FROM [Reclutamiento].[tblCandidatos] Candidato
	INNER JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelCelular ON Candidato.IDCandidato = TelCelular.IDCandidato and TelCelular.IDContactoCandidato = 1
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelFijo ON Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDContactoCandidato = 2
	LEFT JOIN [Reclutamiento].[tblContactoCandidato] CorreoElectronico ON Candidato.IDCandidato = CorreoElectronico.IDCandidato and CorreoElectronico.IDContactoCandidato = 3
	LEFT JOIN [Reclutamiento].[tblDocumentosTrabajoCandidato] PermisoTrabajo on Candidato.IDCandidato = PermisoTrabajo.IDCandidato and PermisoTrabajo.IDDocumentoTrabajo <> 5
	LEFT JOIN [Reclutamiento].[tblDocumentosTrabajoCandidato] Pasaporte on Candidato.IDCandidato = Pasaporte.IDCandidato and Pasaporte.IDDocumentoTrabajo = @IDDocumentoTrabajoPasaporte
	LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato

		where CandidatosProceso.IDEstatusProceso = 0



	END
GO
