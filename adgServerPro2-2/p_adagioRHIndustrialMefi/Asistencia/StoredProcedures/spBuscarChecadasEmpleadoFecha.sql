USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************       
** Descripción  : Buscar las Checadas por empleados por rangos de fecha      
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx      
** FechaCreacion : 2018-10-01      
** Paremetros  :     @IDEmpleado int      
     ,@FechaInicio date      
     ,@FechaFin date      
     ,@IDUsuario int            
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd) Autor   Comentario      
------------------- ------------------- ------------------------------------------------------------      
0000-00-00  NombreCompleto  ¿Qué cambió?      
***************************************************************************************************/     
CREATE proc [Asistencia].[spBuscarChecadasEmpleadoFecha]--1279,'2019-08-27','2019-10-08',1    
(      
	@IDEmpleado int      
	,@FechaInicio date      
	,@FechaFin date      
	,@IDUsuario int      
) as      
      Declare 
@IDIdioma varchar(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;      
	if object_id('tempdb..#fechasEntrada') is not null drop table #fechasEntrada;      
	if object_id('tempdb..#fechasSalida') is not null drop table #fechasSalida;   
	if object_id('tempdb..#fechasEntradaComer') is not null drop table #fechasEntradaComer;      
	if object_id('tempdb..#fechasSalidaComer') is not null drop table #fechasSalidaComer;  	   
    
	create TABLE #tempChecadas(      
		IDChecada  int      
		,Fecha   datetime     
		,FechaOrigen     date     
		,IDLector  int      
		,Lector   varchar(100)      
		,IDEmpleado  int      
		,IDTipoChecada varchar(20)      
		,TipoChecada    varchar(100)      
		,IDUsuario    int      
		,Cuenta   varchar(20)      
		,Comentario  varchar(500)      
		,IDZonaHoraria int    
		,ZonaHoraria varchar(500)      
		,Automatica  bit    
		,FechaReg     datetime     
	);     
    
	--insert into #tempChecadas    
	select     
		c.IDChecada,    
		c.Fecha,    
		isnull(c.FechaOrigen,'1900-01-01') as FechaOrigen,    
		isnull(l.IDLector,0) as IDLector,    
		ISNULL(l.Lector,'') as Lector,    
		c.IDEmpleado,    
		c.IDTipoChecada,    
		JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada ,    
		ISNULL(c.IDUsuario,0) as IDUsuario,    
		u.Cuenta as Cuenta,    
		isnull(c.Comentario,'') as Comentario,    
		ISNULL(c.IDZonaHoraria,0) as IDZonaHoraria,    
		z.Name as ZonaHoraria,    
		c.Automatica,    
		c.FechaReg    
	From Asistencia.tblChecadas c with (nolock)    
		left join Asistencia.tblLectores l (nolock)    
			on l.IDLector = c.IDLector    
		left join Asistencia.tblCatTiposChecadas tc (nolock)    
			on tc.IDTipoChecada = c.IDTipoChecada    
		left join Tzdb.Zones z (nolock)    
			on c.IDZonaHoraria = z.Id    
		left join Seguridad.tblUsuarios u (nolock)     
			on c.IDUsuario = u.IDUsuario    
	WHERE (cast(c.Fecha as date) BETWEEN @FechaInicio and @FechaFin) and c.IDEmpleado = @IDEmpleado     
     
	--select min(Fecha) as fecha, FechaOrigen     
	--into #fechasEntrada    
	--from #tempChecadas  
	--where IDTipoChecada in ('ET', 'SH')    
	--Group by FechaOrigen    
   
	--select min(Fecha) as fecha, FechaOrigen     
	--into #fechasSalidaComer    
	--from #tempChecadas  
	--where IDTipoChecada in ('SC')    
	--Group by FechaOrigen  
     
	--select min(Fecha) as fecha, FechaOrigen     
	--into #fechasEntradaComer    
	--from #tempChecadas  
	--where IDTipoChecada in ('EC')    
	--Group by FechaOrigen  	 
	  
	--select MAX(Fecha) as fecha, FechaOrigen     
	--into #fechasSalida    
	--from #tempChecadas    
	--where IDTipoChecada in ('ST', 'SH')    
	--Group by FechaOrigen    
    
 ----select * from #fechasEntrada    
 ----select * from #fechasSalida    
    
	--select distinct     
	--	IDChecada      
	--	,Fecha as Fecha       
	--	,FechaOrigen      
	--	,IDLector      
	--	,Lector       
	--	,IDEmpleado      
	--	,IDTipoChecada    
	--	,TipoChecada      
	--	,IDUsuario       
	--	,Cuenta       
	--	,Comentario      
	--	,IDZonaHoraria    
	--	,ZonaHoraria     
	--	,Automatica      
	--	,FechaReg         
	--From #tempChecadas    
	--where Fecha in (select fecha from #fechasEntrada 
	--			UNION Select Fecha from #fechasSalida 
	--			union Select Fecha from #fechasSalidaComer
	--			union Select Fecha from #fechasEntradaComer)
GO
