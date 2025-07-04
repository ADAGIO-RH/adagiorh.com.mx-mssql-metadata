USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUClienteModelos](
	@IDClienteModelo int = 0
	,@IDCliente int
	,@IDEmpresa int
	,@FechaIni Date
	,@FechaFin date  
	,@IDUsuario int
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDCliente,0) = 0)    
    BEGIN    
		RETURN;    
    END  

    IF(ISNULL(@IDEmpresa,0) = 0)    
    BEGIN    
		RETURN;    
    END  
	
	IF(@IDClienteModelo = 0 or @IDClienteModelo is null)    
    BEGIN    
		if exists(select 1 from Procom.tblClienteModelos    
		where IDCliente = @IDCliente and FechaIni=@FechaIni)    
		begin    
			set @msj= cast(@FechaIni as varchar(10));    
			--raiserror(@msj,16,0);    
			exec [App].[spObtenerError]    
			 @IDUsuario  = 1,    
			 @CodigoError ='0302001',    
			 @CustomMessage = @msj    
			return;    
		end;    
    
		INSERT INTO Procom.tblClienteModelos(IDCliente,IDEmpresa,FechaIni,FechaFin)    
		VALUES(@IDCliente,@IDEmpresa,@FechaIni,@FechaFin) 
		
		set @IDClienteModelo = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteModelos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteModelo = @IDClienteModelo
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteModelos]','[Procom].[spIUClienteModelos]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteModelos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteModelo = @IDClienteModelo
	 
		UPDATE [Procom].[tblClienteModelos]    
		SET FechaFin = @FechaFin,    
		FechaIni = @FechaIni ,
		IDEmpresa = @IDEmpresa  
		WHERE IDCliente = @IDCliente   
		and IDClienteModelo = @IDClienteModelo
		
		select @NewJSON = a.JSON from [Procom].[tblClienteModelos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteModelo = @IDClienteModelo
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteModelos]','[Procom].[spIUClienteModelos]','UPDATE',@NewJSON,@OldJSON
		    
    END;    
    
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null    
    drop table #tblTempHistorial1;    
    
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null    
    drop table #tblTempHistorial2;    
    
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]    
    INTO #tblTempHistorial1    
    FROM [Procom].[tblClienteModelos]    
    WHERE IDCliente = @IDCliente    
    order by FechaIni asc    
    
    select     
    t1.IDClienteModelo        
    ,t1.IDCliente    
    ,t1.IDEmpresa    
    ,t1.FechaIni    
    ,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni)     
    else '9999-12-31' end     
    INTO #tblTempHistorial2    
    from #tblTempHistorial1 t1    
    left join (select *     
    from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)    
    
    update [TARGET]    
    set     
    [TARGET].FechaFin = [SOURCE].FechaFin    
    FROM [Procom].[tblClienteModelos] as [TARGET]    
    join #tblTempHistorial2 as [SOURCE] on [TARGET].IDClienteModelo = [SOURCE].IDClienteModelo    
     

END
GO
