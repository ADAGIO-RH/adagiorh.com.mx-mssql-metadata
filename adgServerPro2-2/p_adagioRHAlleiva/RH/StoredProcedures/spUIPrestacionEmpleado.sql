USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIPrestacionEmpleado](  
	@IDPrestacionEmpleado int = 0  
	,@IDEmpleado int  
	,@IDTipoPrestacion int   
	,@FechaIni date  
	,@FechaFin date  
	,@IDUsuario int
)  
AS  
BEGIN  
	Declare 
		@msj nvarchar(max),
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

    IF(ISNULL(@IDTipoPrestacion,0) = 0)  
    BEGIN  
		RETURN;  
    END  
  
    IF(@IDPrestacionEmpleado = 0 or @IDPrestacionEmpleado is null)  
    BEGIN  
		if exists(select 1 from RH.tblPrestacionesEmpleado  
		where IDEmpleado = @IDEmpleado and FechaIni=@FechaIni)  
		begin  
			set @msj= cast(@FechaIni as varchar(10));  

			exec [App].[spObtenerError]  
				 @IDUsuario  = 1,  
				 @CodigoError ='0302001',  
				 @CustomMessage = @msj  
			return;  
		end;  
  
		INSERT INTO RH.tblPrestacionesEmpleado(IDEmpleado,IDTipoPrestacion,FechaIni,FechaFin)  
		VALUES(@IDEmpleado,@IDTipoPrestacion,@FechaIni,@FechaFin)  

		set @IDPrestacionEmpleado = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblPrestacionesEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestacionEmpleado = @IDPrestacionEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPrestacionesEmpleado]','[RH].[spUIPrestacionEmpleado]','INSERT',@NewJSON,''
    END  
    ELSE  
    BEGIN  
		select @NewJSON = a.JSON from [RH].[tblPrestacionesEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestacionEmpleado = @IDPrestacionEmpleado
			
		UPDATE RH.tblPrestacionesEmpleado  
		SET FechaFin = @FechaFin,  
			FechaIni = @FechaIni,  
			IDTipoPrestacion = @IDTipoPrestacion  
		WHERE IDEmpleado = @IDEmpleado  
		and IDPrestacionEmpleado = @IDPrestacionEmpleado  

		select @NewJSON = a.JSON from [RH].[tblPrestacionesEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPrestacionEmpleado = @IDPrestacionEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPrestacionesEmpleado]','[RH].[spUIPrestacionEmpleado]','UPDATE',@NewJSON,@OldJSON
    END;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
		drop table #tblTempHistorial1;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
		drop table #tblTempHistorial2;  
  
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]  
    INTO #tblTempHistorial1  
    FROM RH.tblPrestacionesEmpleado with (nolock)  
    WHERE IDEmpleado = @IDEmpleado  
    order by FechaIni asc  
  
    select   
		t1.IDPrestacionEmpleado  
		,t1.IDTipoPrestacion     
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
    FROM RH.tblPrestacionesEmpleado as [TARGET]  
		join #tblTempHistorial2 as [SOURCE] on [TARGET].IDPrestacionEmpleado = [SOURCE].IDPrestacionEmpleado  
   
	declare @tran int 
	set @tran = @@TRANCOUNT
	if(@tran = 0)
	BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
	END 
  
END
GO
