USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIDepartamentoEmpleado]  
(  
 @IDDepartamentoEmpleado int = 0  
 ,@IDEmpleado int  
 ,@IDDepartamento int   
 ,@FechaIni date  
 ,@FechaFin date
 ,@IDUsuario int  
)  
AS  
BEGIN  
    Declare @msj nvarchar(max) ;  
  
	  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


    IF(ISNULL(@IDDepartamento,0) = 0)  
    BEGIN  
		RETURN;  
    END  
  
    IF(@IDDepartamentoEmpleado = 0 or @IDDepartamentoEmpleado is null)  
    BEGIN  
		if exists(select 1 from RH.tblDepartamentoEmpleado  
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
  
		INSERT INTO RH.tblDepartamentoEmpleado(IDEmpleado,IDDepartamento,FechaIni,FechaFin)  
		VALUES(@IDEmpleado,@IDDepartamento,@FechaIni,@FechaFin)    

		SET @IDDepartamentoEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblDepartamentoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDepartamentoEmpleado = @IDDepartamentoEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDepartamentoEmpleado]','[RH].[spUIDepartamentoEmpleado]','INSERT',@NewJSON,''



    END  
    ELSE  
    BEGIN  

	
		select @OldJSON = a.JSON from [RH].[tblDepartamentoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDepartamentoEmpleado = @IDDepartamentoEmpleado

    UPDATE RH.tblDepartamentoEmpleado  
        SET FechaFin = @FechaFin,  
        FechaIni = @FechaIni,  
        IDDepartamento = @IDDepartamento  
    WHERE IDEmpleado = @IDEmpleado  
        and IDDepartamentoEmpleado = @IDDepartamentoEmpleado  

		
		select @NewJSON = a.JSON from [RH].[tblDepartamentoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDepartamentoEmpleado = @IDDepartamentoEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDepartamentoEmpleado]','[RH].[spUIDepartamentoEmpleado]','UPDATE',@NewJSON,@OldJSON

    END;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
    drop table #tblTempHistorial1;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
    drop table #tblTempHistorial2;  
  
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]  
    INTO #tblTempHistorial1  
    FROM RH.tblDepartamentoEmpleado  
    WHERE IDEmpleado = @IDEmpleado  
    order by FechaIni asc  
  
    select   
    t1.IDDepartamentoEmpleado  
    ,t1.IDEmpleado  
    ,t1.IDDepartamento  
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
    FROM RH.tblDepartamentoEmpleado as [TARGET]  
    join #tblTempHistorial2 as [SOURCE] on [TARGET].IDDepartamentoEmpleado = [SOURCE].IDDepartamentoEmpleado  
   

   declare @tran int 
   set @tran = @@TRANCOUNT
   if(@tran = 0)
   BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
   END
END
GO
