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

    

    DECLARE @ExisteEnVacaciones BIT = 0
    DECLARE @ExisteEnFiniquitos BIT = 0
    DECLARE @ExisteEnSistema BIT = 0
    
    -- First get all related tables using your query
    DECLARE @RelatedTables TABLE (
        foreign_key_name VARCHAR(255),
        foreign_table VARCHAR(255),
        foreign_column VARCHAR(255),
        parent_table VARCHAR(255),
        parent_column VARCHAR(255),
        schema_id VARCHAR(255)
    )
    
    INSERT INTO @RelatedTables
    SELECT 
        CAST(f.name AS VARCHAR(255)) AS foreign_key_name,
        CAST(c.name AS VARCHAR(255)) AS foreign_table,
        CAST(fc.name AS VARCHAR(255)) AS foreign_column,
        CAST(p.name AS VARCHAR(255)) AS parent_table,
        CAST(rc.name AS VARCHAR(255)) AS parent_column,
        CAST(SCHEMA_NAME(c.schema_id) AS VARCHAR(255)) AS schema_id       	
    FROM sysobjects f
        INNER JOIN sys.objects c ON f.parent_obj = c.object_id
        INNER JOIN sysreferences r ON f.id = r.constid
        INNER JOIN dbo.sysobjects p ON r.rkeyid = p.id
        INNER JOIN syscolumns rc ON r.rkeyid = rc.id AND r.rkey1 = rc.colid
        INNER JOIN syscolumns fc ON r.fkeyid = fc.id AND r.fkey1 = fc.colid
        INNER JOIN sys.foreign_keys fk ON f.name = fk.name
    WHERE f.type = 'F' 
        AND fc.name = 'IDMovAfiliatorio' 
        AND p.name = 'tblMovAfiliatorios'
        AND fk.delete_referential_action = 0 --NO_ACTION

    -- Check each known table that might cause issues
    -- Example for Nomina table
    IF EXISTS (SELECT 1 FROM Asistencia.tblAjustesSaldoVacacionesEmpleado WHERE IDMovAfiliatorio = @IDMovAfiliatorio)
    BEGIN
        SET @ExisteEnVacaciones = 1
    END
    IF EXISTS (SELECT 1 FROM Asistencia.tblSaldoVacacionesEmpleado WHERE IDMovAfiliatorio = @IDMovAfiliatorio)
    BEGIN
        SET @ExisteEnVacaciones = 1
    END

    -- Example for Incapacidades table
    IF EXISTS (SELECT 1 FROM nomina.tblControlFiniquitos WHERE IDMovAfiliatorio = @IDMovAfiliatorio)
    BEGIN
        SET @ExisteEnFiniquitos = 1
    END

    -- Check all other system tables dynamically
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @TableName VARCHAR(255)
    DECLARE @Schema_ID VARCHAR(255)
    DECLARE TableCursor CURSOR FOR 
        SELECT foreign_table,schema_id 
        FROM @RelatedTables 
        WHERE foreign_table NOT IN ('tblAjustesSaldoVacacionesEmpleado', 'tblSaldoVacacionesEmpleado','tblControlFiniquitos') -- Exclude already checked tables

    OPEN TableCursor
    FETCH NEXT FROM TableCursor INTO @TableName,@Schema_ID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'IF EXISTS (SELECT 1 FROM ' + @Schema_ID + '.' + @TableName +
                   ' WHERE IDMovAfiliatorio = ' + CAST(@IDMovAfiliatorio AS VARCHAR(20)) + ')' +
                   ' SET @ExisteEnSistema = 1'

        
        
        EXEC sp_executesql @sql, N'@ExisteEnSistema BIT OUTPUT', @ExisteEnSistema OUTPUT

        FETCH NEXT FROM TableCursor INTO @TableName,@Schema_ID
    END

    CLOSE TableCursor
    DEALLOCATE TableCursor

    -- Raise appropriate error based on findings
    IF @ExisteEnVacaciones = 1
    BEGIN
        RAISERROR('No se puede eliminar el movimiento porque tiene asociados registros de Vacaciones. Por favor, contacte a su asesor de soporte', 16, 1)
        RETURN
    END

    IF @ExisteEnFiniquitos = 1
    BEGIN
        RAISERROR('No se puede eliminar el movimiento porque existe un finiquito asociado. Por favor, revise el módulo de finiquitos.', 16, 1)
        RETURN
    END

    IF @ExisteEnSistema = 1
    BEGIN
        RAISERROR('No se puede eliminar el movimiento porque está siendo utilizado en otros módulos del sistema. Por favor, contacte a su asesor de soporte', 16, 1)
        RETURN
    END
   
    BEGIN TRY

	    DELETE IMSS.tblMovAfiliatorios   
	    WHERE IDMovAfiliatorio = @IDMovAfiliatorio 

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblMovAfiliatorios]','[IMSS].[spBorrarMovAfiliatorio]','DELETE','',@OldJSON

    END TRY
    BEGIN CATCH
        RAISERROR('Error al intentar eliminar el movimiento afiliatorio.', 16, 1)
    END CATCH


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
