USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: sp para buscar los candidatos relacionados con la aplicación a una plaza
** Autor			: Emmanuel Contreras
** Email			: econtreras@adagio.com.mx
** FechaCreacion	: 2022-05-27
** Paremetros		:              

** DataTypes Relacionados: 

	[Reclutamiento].[spBuscarCandidatoPlaza]@IDCandidato = 0, @IDPlaza=0,@query = '""'
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-09-20			ANEUDY ABREU		Agrega información del reclutador
2024-03-27		    ANEUDY ABREU		Agrega traducción de la tabla Reclutamiento.tblCatEstatusProceso
***************************************************************************************************/

CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatoPlaza](
	@IDCandidatoPlaza	int = 0
	,@IDPlaza			int = 0
	,@IDEstatusProceso	int = 0
	,@IDCandidato		int = 0
	,@PageNumber		int = 1
	,@PageSize			int = 2147483647
	,@query				varchar(100) = '""'
	,@orderByColumn		varchar(50) = 'Orden'
	,@orderDirection	varchar(4) = 'asc'
	,@IDUsuario			int = null
)
AS
BEGIN
	SET FMTONLY OFF;
	declare 
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDIdioma varchar(20)
	 ;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
					
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
				
	declare @tempResponse as table (
		IDCandidatoPlaza INT, 
		IDCandidato int,
		IDPlaza int,
		Plaza Varchar(255),
		IDEstatusProceso int,
		EstatusProceso Varchar(255),
		FechaAplicacion datetime,
		Nombre varchar(200),
		SegundoNombre varchar(200),
		Paterno varchar(200),
		Materno varchar(200),
		Sexo varchar(200),
		PaisDeNacimiento varchar(200),
		EstadoDeNacimiento varchar(200),
		MunicipioDeNacimiento varchar(200),
		LocalidadDeNacimiento varchar(200),
		RFC varchar(15),
		CURP varchar(30),
		NSS varchar(30),
		AFORE varchar(50),
		EstadoCivil varchar(50),
		Estatura decimal(18,4),
		Peso decimal(18,4),
		TipoSangre varchar(8),
		Extranjero bit,
		SueldoDeseado decimal,
		Reclutador varchar(max)
	);

	insert @tempResponse
	SELECT        
		cp.IDCandidatoPlaza
		, cp.IDCandidato
		, cp.IDPlaza
		, JSON_VALUE(catPue.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Plaza 
		, cp.IDProceso
		, JSON_VALUE(ep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) 
		, cp.FechaAplicacion
		, c.Nombre
		, c.SegundoNombre
		, c.Paterno
		, c.Materno
		, c.Sexo
		, p.Descripcion AS PaisDeNacimiento
		, e.NombreEstado AS EstadoDeNacimiento
		, m.Descripcion AS MunicipioDeNacimiento
		, l.Descripcion AS LocalidadDeNacimiento
		, c.RFC
		, c.CURP
		, c.NSS
		, isnull(c.IDAFORE		, 0) as IDAFORE
		, isnull(c.IDEstadoCivil, 0) as IDEstadoCivil
		, isnull(c.Estatura		, 0) as Estatura
		, isnull(c.Peso			, 0) as Peso			
		,c.TipoSangre
		, isnull(c.Extranjero	, 0) as Extranjero
		,ISNULL(cp.SueldoDeseado,0.00) SueldoDeseado
		,(	select 
				rec.IDEmpleado,
				rec.ClaveEmpleado,
				rec.NOMBRECOMPLETO as NombreCompleto
			from RH.tblEmpleadosMaster rec
			where rec.IDEmpleado = cp.IDReclutador
			for json auto, without_array_wrapper
		) as Reclutador
	FROM Reclutamiento.tblCandidatoPlaza cp 
		INNER JOIN Reclutamiento.tblCatEstatusProceso	as EP	ON EP.IDEstatusProceso = CP.IDProceso 
		INNER JOIN Reclutamiento.tblCandidatos			as c	ON cp.IDCandidato = c.IDCandidato  
		inner JOIN RH.tblCatPlazas						as pla	ON cp.IDPlaza = pla.IDPlaza 
		LEFT JOIN Sat.tblCatPaises						as p	ON c.IDPaisNacimiento = p.IDPais 
		LEFT JOIN Sat.tblCatEstados						as e	ON c.IDEstadoNacimiento = e.IDEstado 
		LEFT JOIN Sat.tblCatMunicipios					as m	ON c.IDMunicipioNacimiento = m.IDMunicipio AND m.IDEstado = c.IDEstadoNacimiento 
		LEFT JOIN Sat.tblCatLocalidades					as l	ON c.IDLocalidadNacimiento = l.IDLocalidad AND l.IDEstado = c.IDEstadoNacimiento 
		inner JOIN RH.tblCatPuestos						as catPue ON pla.IDPuesto = catPue.IDPuesto
	WHERE (cp.IDCandidatoPlaza = @IDCandidatoPlaza OR ISNULL(@IDCandidatoPlaza,0) = 0) 
		and (pla.IDPlaza = @IDPlaza OR ISNULL(@IDPlaza,0) = 0) 
		and (EP.IDEstatusProceso = @IDEstatusProceso OR ISNULL(@IDEstatusProceso,0) = 0)
		and (cp.IDCandidato = @IDCandidato OR ISNULL(@IDCandidato,0) = 0) 
		and (@query = '""' or contains(c.* ,@query)) 
    order by cp.IDCandidatoPlaza

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDCandidatoPlaza) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then IDCandidatoPlaza end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then IDCandidatoPlaza end desc,					
		IDCandidatoPlaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
