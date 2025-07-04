USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUICentroCostoEmpleado]  
(  
 @IDCentroCostoEmpleado INT = 0  
 ,@IDEmpleado INT  
 ,@IDCentroCosto INT   
 ,@FechaIni DATE  
 ,@FechaFin DATE 
 ,@IDUsuario int 
)  
AS  
BEGIN  
    Declare @msj nvarchar(max) ;  
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)
  
    IF(ISNULL(@IDCentroCosto,0) = 0)  
    BEGIN  
		RETURN;  
    END  
  
  
    IF(@IDCentroCostoEmpleado = 0 or @IDCentroCostoEmpleado is null)  
    BEGIN  
		if exists(select 1 from RH.tblCentroCostoEmpleado  
		where IDEmpleado = @IDEmpleado and FechaIni=@FechaIni)  
		begin  
			set @msj= cast(@FechaIni as varchar(10));  
			--raiserror(@msj,16,0);  
			exec [App].[spObtenerError]  
			 @IDUsuario  = 1,  
			 @CodigoError ='0302001',  
			 @CustomMessage = @msj  
			return;  
		end;  
  
		INSERT INTO RH.tblCentroCostoEmpleado(IDEmpleado,IDCentroCosto,FechaIni,FechaFin)  
		VALUES(@IDEmpleado,@IDCentroCosto,@FechaIni,@FechaFin)  

		set @IDCentroCostoEmpleado = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCentroCostoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCostoEmpleado = @IDCentroCostoEmpleado
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCentroCostoEmpleado]','[RH].[spUICentroCostoEmpleado]','INSERT',@NewJSON,''

    END  
    ELSE  
    BEGIN  
		select @OldJSON = a.JSON from [RH].[tblCentroCostoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCostoEmpleado = @IDCentroCostoEmpleado

		UPDATE RH.tblCentroCostoEmpleado  
			SET FechaFin = @FechaFin,  
			FechaIni = @FechaIni,
			IDCentroCosto = @IDCentroCosto	  
		WHERE IDEmpleado = @IDEmpleado  
			and IDCentroCostoEmpleado = @IDCentroCostoEmpleado  

		select @NewJSON = a.JSON from [RH].[tblCentroCostoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCentroCostoEmpleado = @IDCentroCostoEmpleado
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCentroCostoEmpleado]','[RH].[spUICentroCostoEmpleado]','UPDATE',@NewJSON,@OldJSON

    END;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
    drop table #tblTempHistorial1;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
    drop table #tblTempHistorial2;  
  
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]  
    INTO #tblTempHistorial1  
    FROM RH.tblCentroCostoEmpleado  
    WHERE IDEmpleado = @IDEmpleado  
    order by FechaIni asc  
  
    select   
    t1.IDCentroCostoEmpleado  
    ,t1.IDEmpleado  
    ,t1.IDCentroCosto  
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
    FROM RH.tblCentroCostoEmpleado as [TARGET]  
    join #tblTempHistorial2 as [SOURCE] on [TARGET].IDCentroCostoEmpleado = [SOURCE].IDCentroCostoEmpleado  
  
  declare @tran int 
   set @tran = @@TRANCOUNT
   if(@tran = 0)
   BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
   END  
END
GO
