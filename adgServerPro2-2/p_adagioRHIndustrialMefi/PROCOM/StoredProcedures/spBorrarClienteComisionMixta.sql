USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spBorrarClienteComisionMixta(
	@IDClienteComisionMixta int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@IDCliente int

	BEGIN TRY  
		Select top 1 @IDCliente 
		from [Procom].[tblClienteComisionMixta] with(nolock)
		where IDClienteComisionMixta = @IDClienteComisionMixta

		select @OldJSON = a.JSON from [Procom].[tblClienteComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionMixta = @IDClienteComisionMixta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteComisionMixta]','[Procom].[spBorrarClienteComisionMixta]','DELETE','',@OldJSON

		Delete [Procom].[tblClienteComisionMixta]  
		where IDClienteComisionMixta = @IDClienteComisionMixta

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

	END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH ;
END
GO
