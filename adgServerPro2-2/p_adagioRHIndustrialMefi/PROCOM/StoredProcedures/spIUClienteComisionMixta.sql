USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spIUClienteComisionMixta(
	@IDClienteComisionMixta int = 0
	,@IDCliente int = 0
	,@Nombre Varchar(MAX)
	,@FechaIni Date
	,@FechaFin Date
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

	IF(ISNULL(@Nombre,'') = '')    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@FechaIni,'') = '')    
    BEGIN    
		RETURN;    
    END 


	IF(@IDClienteComisionMixta = 0 or @IDClienteComisionMixta is null)    
    BEGIN      
	
	if exists(select 1 from Procom.tblClienteComisionMixta    
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

    
		INSERT INTO Procom.tblClienteComisionMixta(
			 IDCliente
			,Nombre
			,FechaIni
			,FechaFin
		)    
		VALUES(
		@IDCliente
		,UPPER(@Nombre)
		,@FechaIni
		,@FechaFin
		) 
		
		set @IDClienteComisionMixta = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionMixta = @IDClienteComisionMixta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteComisionMixta]','[Procom].[spIUClienteComisionMixta]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionMixta = @IDClienteComisionMixta
	 
		UPDATE [Procom].[tblClienteComisionMixta]    
		SET 
		 Nombre = UPPER(@Nombre)
		,FechaIni = @FechaIni
		,@FechaFin = @FechaFin
		WHERE IDCliente = @IDCliente   
		and IDClienteComisionMixta = @IDClienteComisionMixta
		
		select @NewJSON = a.JSON from [Procom].[tblClienteComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionMixta = @IDClienteComisionMixta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteComisionMixta]','[Procom].[spIUClienteComisionMixta]','UPDATE',@NewJSON,@OldJSON
		    
    END;    

	if OBJECT_ID('tempdb..#tblTempHistorial1') is not null    
    drop table #tblTempHistorial1;    
    
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null    
    drop table #tblTempHistorial2;    
    
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]    
    INTO #tblTempHistorial1    
    FROM [Procom].[tblClienteComisionMixta]    
    WHERE IDCliente = @IDCliente    
    order by FechaIni asc    
    
    select     
    t1.IDClienteComisionMixta        
    ,t1.IDCliente    
    ,t1.Nombre    
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
    FROM [Procom].[tblClienteComisionMixta] as [TARGET]    
    join #tblTempHistorial2 as [SOURCE] on [TARGET].IDClienteComisionMixta = [SOURCE].IDClienteComisionMixta    

END;
GO
