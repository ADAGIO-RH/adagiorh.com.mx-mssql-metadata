USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
[Reportes].[spReporteBasicoListaDeAsistenciaImpreso]       
	@Departamentos = '2',    
	@FechaIni = '2024-08-20', 
	@IDTurno = '1', 
	@IDUsuario = 1
*/
CREATE proc [Reportes].[spReporteBasicoListaDeAsistenciaImpreso](        
	@Divisiones varchar(max)= '',
	@Departamentos varchar(max) = '',   
	@Sucursales varchar(max)= '',  
	@FechaIni date, 
	@IDTurno varchar(max)= '', 
	@IDUsuario int        
) as        
	SET FMTONLY OFF     
	declare @empleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date         
		,@dtFiltros Nomina.dtFiltrosRH         
    
		,@IDCliente int    
		,@IDTipoNominaInt int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)    
		,@Fecha Datetime
		,@IDTurnoInt int
		,@TituloRazonSocial varchar(Max)
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null  
	;

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u
		Inner join App.tblPreferencias p
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

    Select @TituloRazonSocial = Valor from app.tblConfiguracionesGenerales where IDConfiguracion = 'NombreEmpresaReportes'
    

	if OBJECT_ID('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;
	create table #tempRespuesta (
		Titulo			varchar(255)
		,ClaveEmpleado	varchar(20)
		,NombreCompleto	varchar(300)
		,Empresa		varchar(255)
		,Division		varchar(255)
		,Sucursal		varchar(255)
		,Departamento	varchar(255)
		,Puesto	varchar(255)
		,Entrada		datetime
		,Salida			datetime
		,CodigoDepartamento varchar(20)
		,TiempoTrabajado as cast(cast(Salida - Entrada as time) as varchar(5))
	)

	--SET @Fecha = (Select top 1 cast(item as datetime) from App.Split(@FechaIni,','))    
	SET @IDTurnoInt = (Select top 1 cast(item as int) from App.Split(@IDTurno,','))    
  
	 insert into @dtFiltros(Catalogo,Value)      
	 values
		('Sucursales',@Sucursales)      
		,('Departamentos',@Departamentos)      
		,('Divisiones',@Divisiones)      
      
	/* Se buscan el periodo seleccionado */        
	insert into @empleados                  
    exec [RH].[spBuscarEmpleados] @FechaIni=@FechaIni, @Fechafin = @FechaIni, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario        
  
	insert #tempRespuesta(
		Titulo			
		,ClaveEmpleado	
		,NombreCompleto	
		,Empresa		
		,Division		
		,Sucursal		
		,Departamento
		,Puesto	
		,Entrada		
		,Salida		
		,CodigoDepartamento	
	)
	select     
		'LISTA DE ASISTENCIA DEL DÍA '
			+App.fnAddString(2,CAST(DATEPART(DAY,@FechaIni) AS VARCHAR(2)),'0',1) 
			+' DE '
			+upper(DateName(month,@FechaIni))
			+' DE '
			+CAST(DATEPART(YEAR,@FechaIni) AS VARCHAR(4))
			+'    '+E.Division
			as Titulo
		,E.ClaveEmpleado    
		,E.NOMBRECOMPLETO as NombreCompleto    
		,ISNULL(@TituloRazonSocial,'SIN EMPRESA') as Empresa   
		,E.Division    
		,E.Sucursal    
		,E.Departamento    
		,E.Puesto    
		, NULL Entrada
		, NULL Salida
		,d.Codigo
		--,(select top 1 Fecha
		--	from Asistencia.tblChecadas 
		--	where IDTipoChecada in ('ET') and FechaOrigen = @Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha asc) Entrada
		--,(select top 1 Fecha
		--	from Asistencia.tblChecadas 
		--	where IDTipoChecada in ('ST') and FechaOrigen = @Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Salida
    from @empleados E    
		join RH.tblCatDepartamentos d
			on E.IDDepartamento = d.IDDepartamento
		left join Asistencia.tblHorariosEmpleados HE    
			on HE.IDEmpleado = E.IDEmpleado    
			and HE.Fecha = @FechaIni  
		left join Asistencia.tblCatHorarios H    
			on H.IDHorario = he.IDHorario    
		and ((H.IDTurno = @IDTurnoInt) or (isnull(@IDTurno,0) = 0))  
	where isnull(E.RequiereChecar,0) = 1

	select 
		Titulo			
		,ClaveEmpleado	
		,NombreCompleto	
		,Empresa		
		,Division		
		,Sucursal		
		,Departamento
		,Puesto	
		,cast(cast(Entrada as time)	as varchar(5)) as Entrada	
		,cast(cast(Salida  as time)	as varchar(5)) as Salida
		,TiempoTrabajado
		,CodigoDepartamento
	from #tempRespuesta
	order by CodigoDepartamento, ClaveEmpleado
GO
