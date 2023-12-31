USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec  Reportes.[spReporteFormatoFaltasEnimsa]  @FechaIni = '2020-10-01',@FechaFin = '2020-10-03',@ClaveEmpleadoInicial = '0014',@IDUsuario=1, @Aplicar = 0
CREATE proc [Reportes].[spReporteFormatoPermisoGeneralEnimsa] (
	 @FechaIni date 
	,@FechaFin date
	,@ClaveEmpleadoInicial varchar (max) = '0'
	,@Afectar int = 0
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		 ,@Titulo Varchar(max)   
		 ,@MAXVacaciones date
		 ,@MAXDiffVacaciones int
		 ,@fechasfaltas [App].[dtFechas]
	;

	select 
		@ClaveEmpleadoInicial	= case when @ClaveEmpleadoInicial	= '' then '0' else @ClaveEmpleadoInicial end
		
  

	if object_id('tempdb..#tempvacaciones') is not null drop table #tempvacaciones;    
	if object_id('tempdb..#tempVacacionesDiff') is not null drop table #tempVacacionesDiff;    
	if object_id('tempdb..#tempFinal') is not null drop table #tempFinal;    

	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
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
	insert @dtEmpleados  
		exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @ClaveEmpleadoInicial
		,@EmpleadoFin	= @ClaveEmpleadoInicial
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros     

	

	--select IE.* 
	--	into #tempvacaciones
	--from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)
 --		inner join @dtEmpleados e
	--		on IE.IDEmpleado = e.IDEmpleado
	--where IE.IDIncidencia = 'V'
	--and IE.Autorizado = 1
	--and e.ClaveEmpleado = @ClaveEmpleadoInicial
	--and IE.Fecha < @FechaIni
	--order by IE.Fecha desc

	--select v.IDIncidenciaEmpleado
	--	,v.IDEmpleado
	--	,v.IDIncidencia
	--	,v.Fecha
	--	,prev.Fecha as FechaPrev
	--	,datediff(day,v.Fecha, isnull(prev.fecha,v.fecha)) diff
	--	into #tempVacacionesDiff
	--from #tempvacaciones v
	--	left join #tempvacaciones prev
	--		on prev.Fecha = (select max(fecha) from #tempvacaciones where Fecha < v.Fecha)
	--where datediff(day,v.Fecha, isnull(prev.fecha,v.fecha)) <= 1
	--order by v.Fecha desc

	--select top 1 @MAXVacaciones = MAX(Fecha)
	--	, @MAXDiffVacaciones = diff
	--FROM #tempVacacionesDiff 
	--group by diff

	----select @MAXVacaciones,@MAXDiffVacaciones

	--IF(@MAXDiffVacaciones < -1 )
	--BEGIN
	--	Delete #tempVacacionesDiff
	--	where Fecha < @MAXVacaciones
	--END
	--ELSE
	--BEGIN
	--	DELETE #tempVacacionesDiff
	--	where diff < -1
	--END
	
	select 
		e.ClaveEmpleado as Clave
		,E.Paterno
		,E.Materno
		,E.Nombre
		,E.SegundoNombre
		,e.Puesto
		,e.Departamento
		,e.FechaAntiguedad
		,e.IMSS
		,Representante = 'DENNIS DAMAYANTI ORTIZ DELGADO'	
		,@FechaIni as FechaIniFalta
		,@FechaFin as FechaFinFalta
		,dateadd(day,1,@FechaFin) as FechainiLabores
		into #tempFinal
	from @dtEmpleados e
	
	

	select 
		Clave
		,Nombre
		,SegundoNombre
		,Paterno
		,Materno
		,Puesto
		,Departamento
		,IMSS
		,Representante
		,FechaIniFalta =   LOWER(Utilerias.fnDateToStringByFormat(FechaIniFalta,'FM',@IdiomaSQL) )
		,FechaFinFalta =   LOWER(Utilerias.fnDateToStringByFormat(FechaFinFalta,'FM',@IdiomaSQL) )
		,FechainiLabores = LOWER(Utilerias.fnDateToStringByFormat(FechainiLabores,'FM',@IdiomaSQL)) 
		,FechaHoy =  LOWER (Utilerias.fnDateToStringByFormat(getdate(),'FM',@IdiomaSQL)) 
		
	from #tempFinal


		IF (@Afectar = 1)
		BEGIN
			insert into @fechasfaltas
			exec [App].[spListaFechas]@fechaini, @FechaFin

			insert into Asistencia.tblIncidenciaEmpleado(IDEmpleado, IDIncidencia, Fecha, Autorizado, AutorizadoPor, FechaHoraCreacion, FechaHoraAutorizacion,ComentarioTextoPlano)
			select e.IDEmpleado
				,'PG'
				,f.Fecha
				,1
				,@IDUsuario
				,getdate()
				,getdate()
				,'FORMATO DE PERMISO GENERAL'
			from  @fechasfaltas f
				cross apply @dtEmpleados e
		END

		select * from Asistencia.tblCatIncidencias
GO
