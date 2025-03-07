USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBorrarMovAfiliatorio]  
(  
   
 @IDMovAfiliatorio int,
 @IDUsuario int = 0  
  
)  
AS  
BEGIN  
   
 declare @IDEmpleado int,
		@CodigoTipoMovimiento Varchar(10)  
  
 select top 1 @IDEmpleado = M.IDEmpleado,
			@CodigoTipoMovimiento = TM.Codigo 
 from IMSS.tblMovAfiliatorios M  
	inner join IMSS.tblCatTipoMovimientos TM
		on TM.IDTipoMovimiento = M.IDTipoMovimiento
 where M.IDMovAfiliatorio = @IDMovAfiliatorio  

IF(@CodigoTipoMovimiento = 'A') 
BEGIN
	EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0502001'
		return 0;
END  

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

		select @OldJSON = a.JSON from [IMSS].[tblMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMovAfiliatorio = @IDMovAfiliatorio  

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblMovAfiliatorios]','[IMSS].[spBorrarMovAfiliatorio]','DELETE','',@OldJSON

    	
     DELETE FROM Asistencia.tblSaldoVacacionesEmpleado 
     WHERE IDMovAfiliatorio = @IDMovAfiliatorio

	 DELETE IMSS.tblMovAfiliatorios   
	 WHERE IDMovAfiliatorio = @IDMovAfiliatorio  


   if object_id('tempdb..#tempMovAfil') is not null    
		drop table #tempMovAfil    
    
	select IDEmpleado, FechaAlta, FechaBaja,            
		case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso            
		,IDMovAfiliatorio    
	into #tempMovAfil            
	from (select distinct tm.IDEmpleado,            
	case when(IDEmpleado is not null) then (select top 1 Fecha             
				from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
			join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
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
				where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
			and mReingreso.Fecha <= '9999-12-31'  
			and isnull(mReingreso.RespetarAntiguedad,0) <> 1              
			order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
	,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
			join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
				where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')      
				and mSalario.Fecha <= '9999-12-31'          
				order by mSalario.Fecha desc ) as IDMovAfiliatorio                                             
	from [IMSS].[tblMovAfiliatorios]  tm ) mm   
	Where IDEmpleado = @IDEmpleado

	
	UPDATE E
		set e.FechaAntiguedad = CASE WHEN isnull(M.FechaReingreso,'1900-01-01') >= M.FechaAlta THEN ISNULL(M.FechaReingreso,'1900-01-01')              
			ELSE M.FechaAlta              
			END  
	FROM RH.tblEmpleados E
		inner join #tempMovAfil M
			on E.IDEmpleado = M.IDEmpleado

 EXEC [IMSS].[spIUVigenciaEmpleado] @IDEmpleado = @IDEmpleado
 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado  
END
GO
