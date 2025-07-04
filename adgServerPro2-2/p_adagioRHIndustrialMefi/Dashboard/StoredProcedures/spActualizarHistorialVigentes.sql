USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza la tabla [Dashboard].[tblHistorialVigenciasPorFechas]
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-09
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Dashboard].[spActualizarHistorialVigentes](
	@FechaIni date = null,
	@Fechafin date = null 
)as 

	select 
		@FechaIni = isnull(@FechaIni,getdate()-15)
		,@Fechafin = isnull(@Fechafin,getdate())

DECLARE
	@Total int = 0;

	while (@FechaIni <= @FechaFin)
	begin	   
		SELECT 
		 @Total = count(E.IDEmpleado)
		FROM [RH].[tblEmpleados] E WITH(NOLOCK)	
		  ,(select IDEmpleado, FechaAlta, FechaBaja,
				  case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
				  ,IDMovAfiliatorio
				  from (select distinct tm.IDEmpleado,
					   case when(IDEmpleado is not null) then (select top 1 Fecha 
													    from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)
														  join [IMSS].[tblCatTipoMovimientos]	  c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento
													    where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'  
													    Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,
					   case when (IDEmpleado is not null) then (select top 1 Fecha 
													    from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)
														  join [IMSS].[tblCatTipoMovimientos]	  c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento
													    where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'  
														  and mBaja.Fecha <= @FechaIni 
														  order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,
					   case when (IDEmpleado is not null) then (select top 1 Fecha 
													    from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)
														  join [IMSS].[tblCatTipoMovimientos]	  c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento
													    where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'  
														  and mReingreso.Fecha <= @FechaIni 
														  order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso  
					   ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)
														  join [IMSS].[tblCatTipoMovimientos]	  c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento
													    where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R') 
													    order by mSalario.Fecha desc ) as IDMovAfiliatorio											                      
					   from [IMSS].[tblMovAfiliatorios]  tm ) mm ) M			
		WHERE E.IDEmpleado = m.IDEmpleado and ( (M.FechaAlta<=@FechaIni and (M.FechaBaja>=@FechaIni or M.FechaBaja is null)) or (M.FechaReingreso<=@FechaIni))	

	   print cast(@FechaIni as varchar)+' - ' + cast(@Total as varchar)			
 	   

	   if exists (
		  select top 1 1
			 from [Dashboard].[tblHistorialVigenciasPorFechas] with (nolock)
			 where Fecha = @FechaIni) 
	   BEGIN
		  update [Dashboard].[tblHistorialVigenciasPorFechas]
		  set Total = @Total
		  where Fecha = @FechaIni
	   end else
	   BEGIN
		  insert into [Dashboard].[tblHistorialVigenciasPorFechas](Fecha, Total)
		  select @FechaIni, @Total
	   end;

	   set @FechaIni = DATEADD(day,1,@FechaIni);
	end;
GO
