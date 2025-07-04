USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta nuevos movimientos a los créditos de infonativ
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-09-18
** Paremetros		:              

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spIHistorialInfonavitEmpleadoAvisos](      
		@IDEmpleado int      
		,@IDRegPatronal int      
		,@IDEmpresa int      
		,@NumeroCredito varchar(10)      
		,@FolioAviso varchar(50)
		,@FechaOtorgamiento [nvarchar](50) = null
		,@FechCreaAviso date  
		,@FacDescuento [decimal](18, 4) NULL
		,@MonDescuento [decimal](18, 4) NULL
		,@SelloDigital [Varchar](max) null
		,@CadenaOriginal [Varchar](max) null
		,@IDTipoDescuento int      
		,@IDTipoAvisoInfonavit int      
		,@IDTipoCredito int null     
		,@FechaUltimoAviso [varchar](50) = null
		,@IDUsuario int
) as

DECLARE @ID int,
@NewJSON varchar(max)

	 
	IF(@IDRegPatronal = 0) RETURN 0;

	IF(@IDEmpleado = 0) RETURN 0;

	IF(@IDTipoDescuento = 0) RETURN 0;

	IF(@IDTipoAvisoInfonavit = 0) RETURN 0;

	IF(isnull(@FechaOtorgamiento,'') = '') 
	BEGIN
		set @FechaOtorgamiento = ''
	END
	IF(isnull(@FechaUltimoAviso,'') = '') 
	BEGIN
		set @FechaUltimoAviso = ''
	END				

	IF not exists(select top 1 1 from RH.tblHistorialAvisosInfonavitEmpleado where NumeroCredito = @NumeroCredito and IDEmpleado = @IDEmpleado and FolioAviso = @FolioAviso and IDRegPatronal = @IDRegPatronal and IDEmpresa = @IDEmpresa)
	BEGIN
		

		insert into rh.tblHistorialAvisosInfonavitEmpleado(
				IDEmpleado
				,IDRegPatronal
				,IDEmpresa
				,NumeroCredito
				,FolioAviso
				,FechaOtorgamiento
				,FechCreaAviso
				,FacDescuento
				,MonDescuento
				,SelloDigital
				,CadenaOriginal
				,IDTipoDescuento
				,IDTipoAvisoInfonavit
				,IDTipoCredito
				,FechaUltimoAviso
		)      
		values (
		@IDEmpleado
		,@IDRegPatronal
		,@IDEmpresa
		,@NumeroCredito
		,@FolioAviso
		,@FechaOtorgamiento
		,@FechCreaAviso
		,@FacDescuento
		,@MonDescuento
		,@SelloDigital
		,@CadenaOriginal
		,@IDTipoDescuento
		,@IDTipoAvisoInfonavit
		,@IDTipoCredito
		,@FechaUltimoAviso
		) 
			set @ID = @@IDENTITY  
		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialAvisosInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleadoAvisos]','INSERT',@NewJSON,''
	END

	  --      if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
			--drop table #tblTempHistorial1;  
  
			--if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
			--drop table #tblTempHistorial2;  
  
			--select *, ROW_NUMBER()over(order by FechaEntraVigor asc) as [Row]  
			--INTO #tblTempHistorial1  
			--FROM rh.tblHistorialAvisosInfonavitEmpleado  
			--WHERE IDEmpleado = @IDEmpleado  
			--	and NumeroCredito = @NumeroCredito
			--	and FechaEntraVigor is not null
			--order by FechaEntraVigor asc  
  
			--select   
			--  t1.IDHistorialAvisosInfonavitEmpleado	
			--, t1.IDInfonavitEmpleado  
			--,t1.IDEmpleado  
			--,t1.NumeroCredito  
			--,t1.FechaEntraVigor  
			--,FechaFinVigor = case when t2.FechaEntraVigor is not null then dateadd(day,-1,t2.FechaEntraVigor)   
			--					 else '9999-12-31' end   
			--INTO #tblTempHistorial2  
			--from #tblTempHistorial1 t1  
			--left join (select *   
			--from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)  
  
			--update [TARGET]  
			--set   
			--[TARGET].FechaFinVigor = [SOURCE].FechaFinVigor  
			--FROM RH.tblHistorialAvisosInfonavitEmpleado as [TARGET]  
			--join #tblTempHistorial2 as [SOURCE] on [TARGET].IDHistorialAvisosInfonavitEmpleado = [SOURCE].IDHistorialAvisosInfonavitEmpleado  
			--and [TARGET].IDEmpleado = [SOURCE].IDEmpleado
			--and [TARGET].NumeroCredito = [SOURCE].NumeroCredito
			--and [TARGET].IDInfonavitEmpleado = [SOURCE].IDInfonavitEmpleado
GO
