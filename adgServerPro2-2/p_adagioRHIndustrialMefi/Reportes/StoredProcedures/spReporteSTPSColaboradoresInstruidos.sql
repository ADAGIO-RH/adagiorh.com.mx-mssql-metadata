USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Reportes].[spReporteSTPSColaboradoresInstruidos] (
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

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDCursoCapacitacion int = 0
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)

	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	


	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'

	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	select @IDCursoCapacitacion = CAST(CASE WHEN ISNULL(Value,'') = '' THEN 0 ELSE  Value END as int)
		from @dtFiltros where Catalogo = 'CursoCapacitacion'

		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


Select M.ClaveEmpleado as [CLAVE EMPLEADO]
			,M.NOMBRECOMPLETO as [NOMBRE COMPLETO]
			,FORMAT(M.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTGUEDAD]
			,CC.Codigo +' - '+CC.Nombre AS [CURSO]
			,FORMAT(PCC.FechaIni,'dd/MM/yyyy') as FECHA
			,ECE.Descripcion as [APROBADO]
			,ISNULL(PCCE.Calificacion,'') as [CALIFICACION]
			,M.Departamento
			,M.Puesto
			,M.Sucursal
			,CASE WHEN Emp.Vigente = 1 THEN 'SI' ELSE 'NO' END Vigente
		From @dtEmpleados M
		inner join STPS.tblProgramacionCursosCapacitacionEmpleados PCCE WITH(NOLOCK)
			on M.IDEmpleado = PCCE.IDEmpleado
		inner join STPS.tblEstatusCursosEmpleados ECE WITH(NOLOCK)
			on PCCE.IDEstatusCursoEmpleados = ECE.IDEstatusCursoEmpleados
		inner join STPS.tblProgramacionCursosCapacitacion PCC WITH(NOLOCK)
			on PCCE.IDProgramacionCursoCapacitacion = PCC.IDProgramacionCursoCapacitacion
		
		Inner join STPS.tblCursosCapacitacion CC WITH(NOLOCK)
			on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion
		left join STPS.tblCatTematicas Tematica WITH(NOLOCK)
			on Tematica.IDTematica = CC.IDAreaTematica
		left join STPS.tblAgentesCapacitacion agentes WITH(NOLOCK)
			on PCC.IDAgenteCapacitacion = agentes.IDAgenteCapacitacion
		left join STPS.tblCatModalidades modalidades WITH(NOLOCK)
			on modalidades.IDModalidad = PCC.IDModalidad
		left join STPS.tblCatCapacitaciones capacitaciones WITH(NOLOCK)
			on capacitaciones.IDCapacitaciones = CC.IDCapacitaciones
		left join STPS.tblCatCursos C WITH(NOLOCK)
			on CC.IDCurso = C.IDCursos
		left join RH.tblEmpleadosMaster Emp WITH(NOLOCK)
			on emp.IDEmpleado = M.IDEmpleado
	WHERE CC.IDCursoCapacitacion = @IDCursoCapacitacion OR ISNULL(@IDCursoCapacitacion,0) = 0
	order by M.ClaveEmpleado

END
GO
