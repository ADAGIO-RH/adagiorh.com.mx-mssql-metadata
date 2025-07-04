USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUITipoNominaEmpleado]    
(    
	@IDTipoNominaEmpleado int = 0    
	,@IDEmpleado int    
	,@IDTipoNomina int    
	,@FechaIni date     
	,@FechaFin date  
	,@IDUsuario int   
)    
AS    
BEGIN    
    declare   
		@msj nvarchar(max)   
		,@IDClienteActual int = 0  
		,@IDClienteDelNuevoTipoDeNomina int = 0  
	; 
	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	
    IF(ISNULL(@IDTipoNomina,0) = 0)    
    BEGIN    
		RETURN;    
    END    
  
	declare @tran int   
	set @tran = @@TRANCOUNT  
  
	--select top 1 @IDClienteActual = isnull(ctn.IDCliente,0)  
	--from RH.tblTipoNominaEmpleado tn with (nolock)  
	--	join Nomina.tblCatTipoNomina ctn with (nolock) on tn.IDTipoNomina = ctn.IDTipoNomina  
	--where tn.IDEmpleado = @IDEmpleado  
	--order by tn.FechaFin desc

	select top 1 @IDClienteActual = isnull(ce.IDCliente,0)  
	from RH.tblClienteEmpleado ce with (nolock)  
	where ce.IDEmpleado = @IDEmpleado  
	order by ce.FechaFin desc
  
	select @IDClienteDelNuevoTipoDeNomina = isnull(ctn.IDCliente,0)  
	from Nomina.tblCatTipoNomina ctn with (nolock)   
	where ctn.IDTipoNomina = @IDTipoNomina  
    
    IF(isnull(@IDTipoNominaEmpleado,0) = 0)    
    BEGIN    
		if exists(select 1   
			from RH.tblTipoNominaEmpleado with (nolock)     
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
  
		INSERT INTO RH.tblTipoNominaEmpleado(IDEmpleado,IDTipoNomina,FechaIni,FechaFin)    
		VALUES(@IDEmpleado,@IDTipoNomina,@FechaIni,@FechaFin)    

			
			set @IDTipoNominaEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblTipoNominaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDTipoNominaEmpleado = @IDTipoNominaEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoNominaEmpleado]','[RH].[spUITipoNominaEmpleado]','INSERT',@NewJSON,''
		   
		 


  
		if ((@IDClienteActual = 0) or (@IDClienteActual <> @IDClienteDelNuevoTipoDeNomina))  
		begin  
			if(@tran = 0)  
			BEGIN 
				exec RH.spUIClienteEmpleado @IDClienteEmpleado = 0  
					,@IDEmpleado    = @IDEmpleado  
					,@IDCliente     = @IDClienteDelNuevoTipoDeNomina  
					,@FechaIni     = @FechaIni  
					,@FechaFin     = @FechaFin  
					,@IDUsuario		= @IDUsuario
			end
		end;  
    END    
    ELSE    
    BEGIN    
		
			select @OldJSON = a.JSON from [RH].[tblTipoNominaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDTipoNominaEmpleado = @IDTipoNominaEmpleado

		UPDATE RH.tblTipoNominaEmpleado    
		SET FechaFin = @FechaFin,    
			FechaIni = @FechaIni,    
			IDTipoNomina = @IDTipoNomina    
		WHERE IDEmpleado = @IDEmpleado and IDTipoNominaEmpleado = @IDTipoNominaEmpleado    
  
			select @NewJSON = a.JSON from [RH].[tblTipoNominaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDTipoNominaEmpleado = @IDTipoNominaEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoNominaEmpleado]','[RH].[spUITipoNominaEmpleado]','UPDATE',@NewJSON,@OldJSON
		   

		if ((@IDClienteActual = 0) or (@IDClienteActual <> @IDClienteDelNuevoTipoDeNomina))  
		begin  
			exec RH.spUIClienteEmpleado @IDClienteEmpleado = 0  
				,@IDEmpleado    = @IDEmpleado  
				,@IDCliente     = @IDClienteDelNuevoTipoDeNomina  
				,@FechaIni     = @FechaIni  
				,@FechaFin     = @FechaFin  
				,@IDUsuario		= @IDUsuario
		end;  
    END;    
    
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null drop table #tblTempHistorial1;    
    
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null drop table #tblTempHistorial2;    
    
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]    
    INTO #tblTempHistorial1    
    FROM RH.tblTipoNominaEmpleado with (nolock)    
    WHERE IDEmpleado = @IDEmpleado    
    order by FechaIni asc    
    
	select     
		t1.IDTipoNominaEmpleado    
	  ,t1.IDEmpleado       
	  ,t1.FechaIni    
	  ,FechaFin = case 
						when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni)     
						else '9999-12-31' end     
    INTO #tblTempHistorial2    
    from #tblTempHistorial1 t1    
		left join (select *     
					from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)    
    
    update [TARGET]    
    set     
		[TARGET].FechaFin = [SOURCE].FechaFin    
    FROM RH.tblTipoNominaEmpleado as [TARGET]    
		join #tblTempHistorial2 as [SOURCE] on [TARGET].IDTipoNominaEmpleado = [SOURCE].IDTipoNominaEmpleado    
    
 
	if(@tran = 0)  
	BEGIN  
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado    
	END  
END
GO
