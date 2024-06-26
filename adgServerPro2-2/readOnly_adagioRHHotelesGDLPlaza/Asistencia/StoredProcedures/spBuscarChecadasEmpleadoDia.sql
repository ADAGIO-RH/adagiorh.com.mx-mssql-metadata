USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[Asistencia].[spBuscarChecadasEmpleadoDia] @IDEmpleado = 1279 , @Fecha = '2021-09-09', @IDUsuario = 1
--GO

CREATE proc [Asistencia].[spBuscarChecadasEmpleadoDia](      
	@IDEmpleado int      
	,@Fecha date        
	,@IDUsuario int      
) as      
      
	--if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;      
	--if object_id('tempdb..#fechasEntrada') is not null drop table #fechasEntrada;      
	--if object_id('tempdb..#fechasSalida') is not null drop table #fechasSalida;   
	--if object_id('tempdb..#fechasEntradaComer') is not null drop table #fechasEntradaComer;      
	--if object_id('tempdb..#fechasSalidaComer') is not null drop table #fechasSalidaComer;  	   
    
	--declare @tempChecadas as table(      
	--	IDChecada int      
	--	,Fecha  datetime     
	--	,FechaOrigen date     
	--	,IDLector int      
	--	,Lector varchar(100)      
	--	,IDEmpleado int      
	--	,IDTipoChecada varchar(20)      
	--	,TipoChecada varchar(100)      
	--	,IDUsuario int      
	--	,Cuenta varchar(20)      
	--	,Comentario  varchar(500)      
	--	,IDZonaHoraria int    
	--	,ZonaHoraria varchar(500)      
	--	,Automatica bit    
	--	,FechaReg datetime     
	--);     
    
	--insert into @tempChecadas    
	select     
		c.IDChecada,    
		c.Fecha,    
		isnull(c.FechaOrigen,'1900-01-01') as FechaOrigen,    
		isnull(l.IDLector,0) as IDLector,    
		ISNULL(l.Lector,'') as Lector,    
		c.IDEmpleado,    
		c.IDTipoChecada,    
		tc.TipoChecada,    
		ISNULL(c.IDUsuario,0) as IDUsuario,    
		u.Cuenta as Cuenta,    
		isnull(c.Comentario,'') as Comentario,    
		ISNULL(c.IDZonaHoraria,0) as IDZonaHoraria,    
		z.Name as ZonaHoraria,    
		c.Automatica,    
		c.FechaReg    
	From Asistencia.tblChecadas c with (nolock)    
		left join Asistencia.tblLectores l (nolock) on l.IDLector = c.IDLector    
		left join Asistencia.tblCatTiposChecadas tc (nolock) on tc.IDTipoChecada = c.IDTipoChecada    
		left join Tzdb.Zones z (nolock) on c.IDZonaHoraria = z.Id    
		left join Seguridad.tblUsuarios u (nolock) on c.IDUsuario = u.IDUsuario    
	WHERE (cast(c.FechaOrigen as date) = @Fecha) and c.IDEmpleado = @IDEmpleado     
     
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
    
 --select * from #fechasEntrada    
 --select * from #fechasSalida    
    
	--select     
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
	--order by FechaOrigen asc
GO
