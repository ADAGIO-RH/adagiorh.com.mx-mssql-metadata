USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [IMSS].[fnObtenerFechaAntiguedad](
	@IDEmpleado int,
	@IDMovAfiliatorio int
)
RETURNS DATE 
AS
BEGIN

	DECLARE 
	@dtVigenciaEmpleados [RH].[dtVigenciaEmpleado],
	@FechaMovimiento Date,
	@FechaAntiguedad Date

	SELECT @FechaMovimiento = Fecha 
	FROM IMSS.tblMovAfiliatorios WITH(NOLOCK)
	WHERE IDMovAfiliatorio = @IDMovAfiliatorio
		AND IDEmpleado = @IDEmpleado

	insert into @dtVigenciaEmpleados
	select mm.IDEmpleado
		,FechaAlta
		,FechaBaja
		,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
		,FechaReingresoAntiguedad            
		,mm.IDMovAfiliatorio    
		,mmSueldos.SalarioDiario
		,mmSueldos.SalarioVariable
		,mmSueldos.SalarioIntegrado
		,mmSueldos.SalarioDiarioReal
	from (select distinct tm.IDEmpleado,            
		case when(IDEmpleado is not null) then (select  MAX(Fecha)             
					from [IMSS].[tblMovAfiliatorios] mAlta WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
					where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'
					--Order By mAlta.Fecha Desc , c.Prioridad DESC
					) end as FechaAlta,            
		case when (IDEmpleado is not null) then (select max(Fecha)             
					from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
					where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'
				and mBaja.Fecha <= @FechaMovimiento             
					--order by mBaja.Fecha desc, C.Prioridad desc
				) end as FechaBaja,            
		case when (IDEmpleado is not null) then (select MAX(Fecha)             
					from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
					where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo in('R','A')
				and mReingreso.Fecha <= @FechaMovimiento  
				--and isnull(mReingreso.RespetarAntiguedad,0) <> 1
				--order by mReingreso.Fecha desc, C.Prioridad desc
				) end as FechaReingreso
		,case when (IDEmpleado is not null) then (select MAX( Fecha)             
					from [IMSS].[tblMovAfiliatorios]  mReingresoAnt WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento            
					where mReingresoAnt.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','R')
				and mReingresoAnt.Fecha <= @FechaMovimiento  
				and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1
				--order by mReingresoAnt.Fecha desc, C.Prioridad desc
				) end as FechaReingresoAntiguedad
		,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
					where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')      
					and mSalario.Fecha <= @FechaMovimiento         
					order by mSalario.Fecha desc ) as IDMovAfiliatorio   
		from [IMSS].[tblMovAfiliatorios] tm with (nolocK)
			where TM.IDEmpleado = @IDEmpleado
		) mm   
			JOIN [IMSS].[tblMovAfiliatorios] mmSueldos with (nolocK) on mm.IDMovAfiliatorio = mmSueldos.IDMovAfiliatorio
	WHERE (mm.IDEmpleado = @IDEmpleado) OR (ISNULL(@IDEmpleado,0) = 0)
	
	SELECT @FechaAntiguedad = FechaReingresoAntiguedad FROM @dtVigenciaEmpleados
	
	RETURN @FechaAntiguedad;

END
GO
