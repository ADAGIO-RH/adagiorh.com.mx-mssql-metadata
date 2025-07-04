USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarClienteModelos(
	@IDClienteModelo int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@IDCliente int

	select @OldJSON = a.JSON from [Procom].[tblClienteModelos] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDClienteModelo = @IDClienteModelo

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteModelos]','[Procom].[spBorrarClienteModelos]','DELETE','',@OldJSON


	 select @IDCliente=IDCliente
	 from [Procom].[tblClienteModelos] 
	 where IDClienteModelo = @IDClienteModelo

	 Delete [Procom].[tblClienteModelos]  
	 where IDClienteModelo = @IDClienteModelo

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
