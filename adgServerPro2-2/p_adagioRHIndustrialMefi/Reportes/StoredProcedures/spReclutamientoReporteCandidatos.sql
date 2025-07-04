USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReclutamientoReporteCandidatos] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
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
		,@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
        
	select @IdiomaSQL = [SQL]        
	from App.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaIni'

	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaFin'

	select 
		 concat(Candidato.Nombre,' ',Candidato.SegundoNombre) AS [NOMBRE(S)]
		,Candidato.Paterno AS [APELLIDO PATERNO]
		,Candidato.Materno AS [APELLIDO MATERNO]
		,Candidato.Sexo AS [SEXO]
		,FORMAT(Candidato.FechaNacimiento ,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
		,Candidato.RFC AS [RFC  ]
		,Candidato.CURP AS [CURP]
		,Candidato.NSS AS [NSS  ]
		,Candidato.IDAFORE AS [AFORE]
		,PaisNacimiento.Descripcion AS [PAIS DE NACIMIENTO]
		,EstadoNacimiento.NombreEstado AS [ESTADO DE NACIMIENTO]
		,MunicipioNacimiento.Descripcion AS [MUNICIPIO DE NACIMIENTO]
		,LocalidadNacimiento.Descripcion AS [LOCALIDAD DE NACIMIENTO]
		,EstadoCivil.Descripcion AS [ESTADO CIVIL]
		,Candidato.Estatura AS [ESTATURA]
		,Candidato.Peso AS [PESO]
		,Candidato.TipoSangre AS [TIPO DE SANGRE]
		,JSON_VALUE(EstatusProceso.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [ESTATUS PROCESO]
		,ISNULL(Email.Value, '') AS [EMAIL]
		,ISNULL(Celular.Value, '')  AS [CELULAR]
		,ISNULL(TelFijo.Value, '') AS [TELEFONO FIJO]
		,''	AS [CODIGO POSTAL DE RESIDENCIA]
		,''	AS [CALLE DE RESIDENCIA]
		,''	AS [NUMERO EXT DE RESIDENCIA]
		,''	AS [NUMERO INT DE RESIDENCIA]
		,''	AS [PAIS DE RESIDENCIA]
		,''	AS [ESTADO DE RESIDENCIA]
		,''	AS [MUNICIPIO DE RESIDENCIA]
		,''	AS [LOCALIDAD DE RESIDENCIA]
	from [Reclutamiento].[tblCandidatos] Candidato
		inner join [Sat].[tblCatPaises] PaisNacimiento on Candidato.IDPaisNacimiento = PaisNacimiento.IDPais
		inner join [Sat].[tblCatEstados] EstadoNacimiento on Candidato.IDEstadoNacimiento = EstadoNacimiento.IDEstado
		inner join [Sat].[tblCatMunicipios] MunicipioNacimiento on Candidato.IDMunicipioNacimiento = MunicipioNacimiento.IDMunicipio
		inner join [Sat].[tblCatLocalidades] LocalidadNacimiento on Candidato.IDLocalidadNacimiento = LocalidadNacimiento.IDLocalidad

		inner join [RH].[tblCatEstadosCiviles] EstadoCivil on Candidato.IDEstadoCivil = EstadoCivil.IDEstadoCivil
		inner join [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on Candidato.IDEstadoNacimiento = EstatusProceso.IDEstatusProceso

		left join [Reclutamiento].[tblContactoCandidato] Celular on Candidato.IDCandidato = Celular.IDCandidato and Celular.IDTipoContacto = 1
		left join [Reclutamiento].[tblContactoCandidato] TelFijo on  Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDTipoContacto = 2
		left join [Reclutamiento].[tblContactoCandidato] Email on  Candidato.IDCandidato = Email.IDCandidato and Email.IDTipoContacto = 3
END
GO
