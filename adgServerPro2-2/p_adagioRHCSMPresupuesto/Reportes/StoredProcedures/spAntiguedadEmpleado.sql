USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spAntiguedadEmpleado] --@IDPeriodo = 1    
(      
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly,   
	@IDUsuario int    
)    
AS    
BEGIN    
    
	Declare 
        @empleados [RH].[dtEmpleados],
		@IDIdioma Varchar(5),        
		@IdiomaSQL varchar(100) = null,  
		@FechaIni date,     
		@FechaFin date,     
		@TipoVigente varchar(max) = '1',       
		@TipoNomina varchar(max) = '0',    
		@ClaveEmpleadoInicial Varchar(20) = '0',    
		@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
		@Cliente Varchar(max) = '',
		@Departamentos Varchar(max) = '',
		@Sucursales Varchar(max) = '',
		@Puestos Varchar(max) = '',
		@RazonesSociales Varchar(max) = '',
		@RegPatronales Varchar(max) = '',
		@Divisiones Varchar(max) = '',
		@Prestaciones Varchar(max) = ''
	;
 
	SET DATEFIRST 7;        
        
	select top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with(nolock)       
		Inner join App.tblPreferencias p with(nolock)
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with(nolock)       
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with(nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with(nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	SET @FechaIni = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)       
	SET @FechaFin = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)      
	SET @TipoVigente = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'))
	SET @TipoNomina = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'))   
 
	SET @ClaveEmpleadoInicial = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')      
	SET @ClaveEmpleadoFinal = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')       
     
	declare --@dtFiltros [Nomina].[dtFiltrosRH]    
		@dtEmpleados [RH].[dtEmpleados]    
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@IDTipoRotacion int
	;

   
	SET @ClaveEmpleadoInicial	= CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal		= CASE WHEN ISNULL(@ClaveEmpleadoFinal,'')  = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina	= (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente	= (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))
    
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@FechaIni, @FechaFin = @FechaFin ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
	
    select
		  Empleados.ClaveEmpleado as [Clave]
		, Empleados.NOMBRECOMPLETO as [NOMBRE COMPLETO]
		, depto.Codigo +' - '+ depto.Descripcion as [DEPTO]
		, Suc.Codigo +' - '+ Suc.Descripcion as [SUCURSAL]
		, Puestos.Codigo +' - '+ Puestos.Descripcion as [PUESTO]
		, tp.Codigo +' - '+tp.Descripcion as [PRESTACION]
        ,CP.Descripcion AS [CLASIFICACIÓN CORPORATIVA]
		, FORMAT(Empleados.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
		, [Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin) as [ANIOS CUMPLIDOS]
		From @empleados Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD
			on Empleados.IDTipoPrestacion = TPD.IDTipoPrestacion
			and TPD.Antiguedad = CEILING([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)) 
        LEFT JOIN RH.tblCatClasificacionesCorporativas CP with(nolock)
            on Empleados.IDClasificacionCorporativa=CP.IDClasificacionCorporativa

	ORDER BY Empleados.ClaveEmpleado ASC
    
	
END
GO
