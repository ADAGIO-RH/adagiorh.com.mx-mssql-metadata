USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReporteSTPSPlantillaDeptoPuesto] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)	
	;
	
	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaIni'

	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaFin'

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

	SELECT ISNULL(Depto.Codigo,'0000')+' - '+ E.Departamento AS DEPARTAMENTO
		, ISNULL(P.Codigo,'0000')+' - '+ E.Puesto AS PUESTO
		, P.SueldoBase AS [SUELDO BASE]
		, p.TopeSalarial as [TOPE SALARIAL]
		, 0 AS [NIVEL SALARIAL]
		, count(*) as TOTAL
	FROM @dtEmpleados E
		left join RH.tblCatDepartamentos Depto WITH(NOLOCK)
			on E.IDDepartamento = Depto.IDDepartamento
		left join RH.tblCatPuestos P WITH(NOLOCK)
			on E.IDPuesto = P.IDPuesto
	GROUP BY Depto.Codigo
			,E.Departamento
			,P.Codigo
			,E.Puesto
			,P.SueldoBase
			,p.TopeSalarial
			--,p.NivelSalarial
	ORDER BY Depto.Codigo, E.Departamento, P.Codigo, E.Puesto


END
GO
