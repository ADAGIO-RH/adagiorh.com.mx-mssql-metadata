USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar una lista de fecha de colaborador indicando que día estuvo vigente o no
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-15
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de esta sp será necesario modificar los siguientes sp's:
		- [Asistencia].[spBuscarEventosCalendario]
		- Reportes.spAsistenciaDiaria

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-29			Aneudy Abreu	Se cambió el Parámetro @IDEmpleado por @dtEmpleados, con esto
									el sp puede retorna la lista de fechas de múltiples empleados.
***************************************************************************************************/
CREATE proc [RH].[spBuscarListaFechasVigenciaEmpleado](
	 @dtEmpleados RH.dtEmpleados readonly
	,@Fechas [App].[dtFechas] READONLY 
	,@IDUsuario int 
) as
	declare  
		 @IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil;
    
	select IDEmpleado,FechaAlta, FechaBaja,            
     case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso       
	 -- FechaReingreso
      ,IDMovAfiliatorio    
	  ,Fecha
	into #tempMovAfil            
    from (select distinct tm.IDEmpleado,            
    case when(tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
                where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'              
                Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
    case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
                where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B' and mBaja.Fecha <= Fechas.Fecha             
    order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
    case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
            join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
                where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
            and mReingreso.Fecha <= Fechas.Fecha             
            order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
    ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
            join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
                where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')             
                order by mSalario.Fecha desc ) as IDMovAfiliatorio   
	,Fechas.Fecha                                          
    from [IMSS].[tblMovAfiliatorios]  tm 
		join @dtEmpleados e on tm.IDEmpleado = e.IDEmpleado
	 ,@Fechas Fechas
	--where tm.IDEmpleado = @IDEmpleado
	) mm    

	select m.IDEmpleado, Fecha,Vigente = case when ( (M.FechaAlta<=Fecha and (M.FechaBaja>=Fecha or M.FechaBaja is null)) or (M.FechaReingreso<=Fecha)) then cast(1 as bit) else cast(0 as bit) end                           
	from #tempMovAfil M
	--,@Fechas Fechas
GO
