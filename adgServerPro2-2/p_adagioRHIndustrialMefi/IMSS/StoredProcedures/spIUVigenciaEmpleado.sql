USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spIUVigenciaEmpleado](
	@IDEmpleado int = 0
)
AS
BEGIN
	  
	DECLARE @dtVigenciaEmpleados [RH].[dtVigenciaEmpleado]

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
		case when(IDEmpleado is not null) then (select top 1 Fecha             
					from [IMSS].[tblMovAfiliatorios] mAlta WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
					where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'
					Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
		case when (IDEmpleado is not null) then (select top 1 Fecha             
					from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
					where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'
				and mBaja.Fecha <= '9999-12-31'             
		order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
		case when (IDEmpleado is not null) then (select top 1 Fecha             
					from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
					where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo in('R','A')
				and mReingreso.Fecha <= '9999-12-31'  
				--and isnull(mReingreso.RespetarAntiguedad,0) <> 1
				order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso
		,case when (IDEmpleado is not null) then (select top 1 Fecha             
					from [IMSS].[tblMovAfiliatorios]  mReingresoAnt WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento            
					where mReingresoAnt.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','R')
				and mReingresoAnt.Fecha <= '9999-12-31'  
				and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1
				order by mReingresoAnt.Fecha desc, C.Prioridad desc) end as FechaReingresoAntiguedad
		,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
					where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')      
					and mSalario.Fecha <= '9999-12-31'          
					order by mSalario.Fecha desc ) as IDMovAfiliatorio   
		from [IMSS].[tblMovAfiliatorios] tm with (nolocK) ) mm   
			JOIN [IMSS].[tblMovAfiliatorios] mmSueldos with (nolocK) on mm.IDMovAfiliatorio = mmSueldos.IDMovAfiliatorio
	WHERE (mm.IDEmpleado = @IDEmpleado) OR (ISNULL(@IDEmpleado,0) = 0)

	MERGE IMSS.TblVigenciaEmpleado AS TARGET                  
		USING @dtVigenciaEmpleados AS SOURCE                  
			ON (TARGET.IDEmpleado = SOURCE.IDEmpleado)                  
		WHEN MATCHED Then                  
			update                  
				Set                       
				 TARGET.FechaAlta					= SOURCE.FechaAlta                
				,TARGET.FechaBaja					= SOURCE.FechaBaja  
				,TARGET.FechaReingreso				= SOURCE.FechaReingreso  
				,TARGET.FechaReingresoAntiguedad	= SOURCE.FechaReingresoAntiguedad  
				,TARGET.IDMovAfiliatorio			= SOURCE.IDMovAfiliatorio  
				,TARGET.SalarioDiario				= SOURCE.SalarioDiario  
				,TARGET.SalarioVariable				= SOURCE.SalarioVariable  
				,TARGET.SalarioIntegrado			= SOURCE.SalarioIntegrado  
				,TARGET.SalarioDiarioReal			= SOURCE.SalarioDiarioReal  
                      
		WHEN NOT MATCHED BY TARGET THEN             
		INSERT(IDEmpleado,FechaAlta,FechaBaja,FechaReingreso,FechaReingresoAntiguedad,IDMovAfiliatorio,SalarioDiario,SalarioVariable,SalarioIntegrado,SalarioDiarioReal)                  
		VALUES(SOURCE.IDEmpleado,SOURCE.FechaAlta,SOURCE.FechaBaja,SOURCE.FechaReingreso,SOURCE.FechaReingresoAntiguedad,SOURCE.IDMovAfiliatorio
		, SOURCE.SalarioDiario, SOURCE.SalarioVariable, SOURCE.SalarioIntegrado, SOURCE.SalarioDiarioReal) ;                
END
GO
