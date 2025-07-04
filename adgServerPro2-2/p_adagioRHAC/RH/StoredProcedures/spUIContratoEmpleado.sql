USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: spUIContratoEmpleado
** Autor			: Aneudy Abreu | Jose Romá,
** Email			: aneudy.abreu@adagio.com.mx | jose.roman@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              
** Versión 1 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-07-24          Julio castillo      Se agrego una validacion en la actualizacion de la fechaFin del contrato. 
                                        Para evitar que la fecha fin se alargue en el primer contrato si el segundo es mucho despues. 
                                        Asi mismo se agrego un update a la columna de duracion para cundo se ajuste la fecha fin de algun contrato.
2024-04-24			Javier Paredes		Se agrego la funcionalidad de la CARTA RESPONSIVA
2025-04-08			Aneudy Abreu		Cambia validaciones para que ser permita capturar más de un documento en la misma fecha
***************************************************************************************************/

CREATE PROCEDURE [RH].[spUIContratoEmpleado] (          
	@IDContratoEmpleado INT = 0          
	, @IDEmpleado INT          
	, @IDTipoContrato INT          
	, @IDTipoTrabajador INT          
	, @IDDocumento INT          
	, @FechaIni DATE           
	, @FechaFin DATE        
	, @Duracion INT        
	, @IDTipoDocumento INT
	, @ActualizarTipoTrabajador BIT
	, @IDReferencia INT = 0
	, @CalificacionEvaluacion decimal(18,2) = null
	, @IDUsuario INT          
)          
AS          
BEGIN        
	
	SET NOCOUNT ON

	-- SET @ActualizarTipoTrabajador=1 -- PASAR POR PARAMETRO SE NECESITA CAMBIO EN LA VENTANA DEL FRONT DE MASIVO
    
    DECLARE 
		@msj NVARCHAR(MAX)        
		, @EsContrato BIT = 0
		, @IDTipoPension INT
		, @IDTipoSalario INT
		, @OldJSON VARCHAR(MAX)
		, @NewJSON VARCHAR(MAX)
		, @EmpleadosJson VARCHAR(MAX)
		, @IDEmpleadoAux INT = 0		
		, @CARTA_RESPONSIVA INT = 4
		, @FechaAsignacion DATE;
	;	

	DECLARE @TblEmpleados TABLE(
		[IDEmpleado] INT
	)

    IF(ISNULL(@IDDocumento,0) = 0)          
    BEGIN     
		RAISERROR('Debe seleccionar un documento', 16, 0);
		RETURN
    END          

          
	SELECT TOP 1 @EsContrato = EsContrato FROM RH.tblCatDocumentos WITH(NOLOCK) WHERE IDDocumento = @IDDocumento        
        
	SELECT @IDTipoSalario = ISNULL(IDTipoSalario, 0)
			, @IDTipoPension = ISNULL(IDTipoPension, 0)
	FROM RH.tblTipoTrabajadorEmpleado  
	WHERE IDEmpleado = @IDEmpleado  

	IF(@IDTipoDocumento = @CARTA_RESPONSIVA)
	BEGIN			
		SELECT @FechaAsignacion = CAST(FechaHora AS DATE) FROM [ControlEquipos].[tblEstatusArticulos] WHERE IDEstatusArticulo = @IDReferencia
		SET @FechaIni = @FechaAsignacion;
		SET @FechaFin = @FechaAsignacion;
	END
		
	IF(@EsContrato = 1)        
	BEGIN        
		IF(ISNULL(@IDTipoContrato,0) = 0)          
		BEGIN          
			RETURN;          
		END;          
          
		IF(@IDContratoEmpleado = 0 or @IDContratoEmpleado is null )          
		BEGIN          
			if exists(select top 1 1     
				from RH.tblContratoEmpleado ce with (nolock) 
					inner join rh.tblCatDocumentos d on ce.IDDocumento = d.IDDocumento         
				where ce.IDEmpleado = @IDEmpleado and isnull(d.EsContrato,0) = 1 and  FechaIni=@FechaIni)          
			begin          
				set @msj= cast(@FechaIni as varchar(10));          
				exec [App].[spObtenerError]          
					@IDUsuario  = 1,          
					@CodigoError ='0302001',          
					@CustomMessage = @msj          
				return;          
			end;          
             
			INSERT INTO RH.tblContratoEmpleado(IDEmpleado,IDTipoContrato,IDTipoTrabajador,IDDocumento,FechaIni,FechaFin,Duracion,IDTipoDocumento,FechaGeneracion, CalificacionEvaluacion)          
			VALUES(@IDEmpleado,@IDTipoContrato,@IDTipoTrabajador,@IDDocumento,@FechaIni,case when @Duracion = 0 then '9999-12-31' else @FechaFin end,@Duracion,@IDTipoDocumento,getdate(), @CalificacionEvaluacion)   
	   
			set @IDContratoEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblContratoEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDContratoEmpleado = @IDContratoEmpleado
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContratoEmpleado]','[RH].[spUIContratoEmpleado]','INSERT',@NewJSON,''
		END          
		ELSE          
		BEGIN   
			select @OldJSON = a.JSON from [RH].[tblContratoEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDContratoEmpleado = @IDContratoEmpleado
		       
			UPDATE RH.tblContratoEmpleado          
			SET FechaFin = case when @Duracion = 0 then '9999-12-31' else @FechaFin end,          
				FechaIni	= @FechaIni,          
				IDDocumento = @IDDocumento,          
				IDTipoContrato		= @IDTipoContrato,        
				IDTipoTrabajador	= @IDTipoTrabajador,        
				IDTipoDocumento		= @IDTipoDocumento,        
				Duracion			= @Duracion ,
				CalificacionEvaluacion	= @CalificacionEvaluacion
			WHERE IDEmpleado = @IDEmpleado and IDContratoEmpleado = @IDContratoEmpleado    
   
			select @NewJSON = a.JSON from [RH].[tblContratoEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDContratoEmpleado = @IDContratoEmpleado
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContratoEmpleado]','[RH].[spUIContratoEmpleado]','UPDATE',@NewJSON,@OldJSON
		END;          
          
		if OBJECT_ID('tempdb..#tblTempHistorial1') is not null drop table #tblTempHistorial1;          
		if OBJECT_ID('tempdb..#tblTempHistorial2') is not null drop table #tblTempHistorial2;          
          
		select ce.*,isnull(d.EsContrato,0)EsContrato, ROW_NUMBER()over(order by ce.FechaIni asc) as [Row]          
		INTO #tblTempHistorial1          
		FROM RH.tblContratoEmpleado ce with (nolock)
			inner join RH.tblCatDocumentos d with (nolock)
				on d.IDDocumento  = ce.IDDocumento        
		WHERE ce.IDEmpleado = @IDEmpleado and ISNULL(d.EsContrato,0) = 1        
		order by ce.FechaIni asc          

		select           
			 t1.IDContratoEmpleado          
			,t1.IDEmpleado          
			,t1.IDDocumento          
			,t1.IDTipoContrato          
			,t1.IDTipoTrabajador          
			,t1.FechaIni     
			,t1.EsContrato         
			,FechaFin = case when t2.FechaIni is not null then 
                                                          case when t2.FechaIni between t1.FechaIni and t1.FechaFin then dateadd(day,-1,t2.FechaIni) 
                                                               else dateadd(day,t1.Duracion -1 ,t1.FechaIni) end 
                                                                   
                             when t1.IDTipoContrato <> 1 then dateadd(day,t1.Duracion -1 ,t1.FechaIni)       
                             else '9999-12-31' end            
		INTO #tblTempHistorial2          
		from #tblTempHistorial1 t1          
			left join (select *           
						from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)        
     
		update [TARGET]          
			set           
				[TARGET].FechaFin = [SOURCE].FechaFin,
				[TARGET].Duracion = case 
									when SOURCE.IDTipoContrato <> 1 
									then DATEDIFF(day,SOURCE.FechaIni,SOURCE.FechaFin) + 1 
									ELSE 0 END        
		FROM RH.tblContratoEmpleado as [TARGET]          
			join #tblTempHistorial2 as [SOURCE] on [TARGET].IDContratoEmpleado = [SOURCE].IDContratoEmpleado          
		where ISNULL(SOURCE.EsContrato,0) = 1   
			
		if(isnull(@ActualizarTipoTrabajador,0) = 1)
		BEGIN
			exec RH.spUITipoTrabajadorEmpleado 
				@IDEmpleado			= @IDEmpleado
				,@IDTipoTrabajador	= @IDTipoTrabajador
				,@IDTipoContrato	= @IDTipoContrato
				,@IDTipoSalario		= @IDTipoSalario
				,@IDTipoPension		= @IDTipoPension
				,@IDUsuario			= @IDUsuario
		END
	END        
	ELSE        
	BEGIN
		/*
			*** INICIAL CARTA RESPONSIVA
			- VALIDA SI EL DOCUMENTO ES DE TIPO CARTA RESPONSIVA
			- VALIDA QUE EL ARTICULO ESTE ASIGNADO AL COLABORADOR
		*/
		IF(@IDTipoDocumento = @CARTA_RESPONSIVA)
			BEGIN
				
				SELECT @EmpleadosJson = Empleados FROM [ControlEquipos].[tblEstatusArticulos] WHERE IDEstatusArticulo = @IDReferencia;

				INSERT INTO @TblEmpleados 
				SELECT Emp.IDEmpleado
				FROM OPENJSON(JSON_QUERY(@EmpleadosJson,  '$'))
				  WITH (
					IDEmpleado NVARCHAR(50) '$.IDEmpleado'
				  ) AS Emp
		
				SELECT TOP 1 @IDEmpleadoAux = IDEmpleado FROM @TblEmpleados WHERE IDEmpleado = @IDEmpleado;	
				
				IF(@IDEmpleadoAux = 0)
					BEGIN
						RAISERROR('El artículo no esta asignado al colaborador', 16, 0);
						RETURN
					END	
			END
		ELSE
		BEGIN
			SET @IDReferencia = NULL;
		END 
		-- TERMINA CARTA RESPONSIVA

		IF(@IDContratoEmpleado = 0 or @IDContratoEmpleado is null )          
		BEGIN      
			IF(@IDTipoDocumento = @CARTA_RESPONSIVA)
			BEGIN
				IF EXISTS(
					select top 1 1
					from RH.tblContratoEmpleado ce
						join RH.tblCatDocumentos  d on d.IDDocumento = ce.IDDocumento
					where ISNULL(d.EsContrato, 0) = 0 and ce.FechaIni=@FechaIni AND ce.IDReferencia = @IDReferencia and ISNULL(@IDReferencia, 0) != 0
				)
				BEGIN
					set @msj= cast(@FechaIni as varchar(10));          
					exec [App].[spObtenerError]          
						@IDUsuario  = 1,          
						@CodigoError ='0302001',          
						@CustomMessage = @msj          
					return; 
				END
				--if exists(select 1 
				--	from RH.tblContratoEmpleado ce with (nolock)
				--	inner join rh.tblCatDocumentos d  with (nolock)       
				--	on ce.IDDocumento = d.IDDocumento         
				--	where IDEmpleado = @IDEmpleado and isnull(d.EsContrato,0) = 0 and  FechaIni=@FechaIni)          
				--begin          
				--	set @msj= cast(@FechaIni as varchar(10));          
				--	exec [App].[spObtenerError]          
				--		@IDUsuario  = 1,          
				--		@CodigoError ='0302001',          
				--		@CustomMessage = @msj          
				--	return;          
				--end; 
			END
			--ELSE
			--BEGIN
			--	IF EXISTS(
			--		select top 1 1
			--		from RH.tblContratoEmpleado ce
			--			join RH.tblCatDocumentos  d on d.IDDocumento = ce.IDDocumento
			--		where ISNULL(d.EsContrato, 0) = 0 and ce.FechaIni=@FechaIni AND ce.IDReferencia = @IDReferencia and ISNULL(@IDReferencia, 0) != 0
			--	)
			--	BEGIN
			--		set @msj= cast(@FechaIni as varchar(10));          
			--		exec [App].[spObtenerError]          
			--			@IDUsuario  = 1,          
			--			@CodigoError ='0302001',          
			--			@CustomMessage = @msj          
			--		return; 
			--	END
			--END
             
			INSERT INTO RH.tblContratoEmpleado(IDEmpleado,IDTipoContrato,IDTipoTrabajador,IDDocumento,FechaIni,FechaFin,Duracion,IDTipoDocumento,FechaGeneracion,IDReferencia)          
			VALUES(@IDEmpleado,Null,null,@IDDocumento,@FechaIni,@FechaIni,@Duracion,@IDTipoDocumento,getdate(),@IDReferencia)          

			set @IDContratoEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblContratoEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDContratoEmpleado = @IDContratoEmpleado
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContratoEmpleado]','[RH].[spUIContratoEmpleado]','INSERT',@NewJSON,''
		END          
		ELSE          
		BEGIN   
			select @OldJSON = a.JSON from [RH].[tblContratoEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDContratoEmpleado = @IDContratoEmpleado
				       
			UPDATE RH.tblContratoEmpleado          
			SET FechaFin = @FechaIni,          
				FechaIni = @FechaIni,          
				IDDocumento			= @IDDocumento,          
				IDTipoContrato		= Null,        
				IDTipoTrabajador	= Null,        
				IDTipoDocumento		= @IDTipoDocumento,        
				Duracion			= @Duracion, 
				IDReferencia		= @IDReferencia
			WHERE IDEmpleado = @IDEmpleado and IDContratoEmpleado = @IDContratoEmpleado      
			
			select @NewJSON = a.JSON from [RH].[tblContratoEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDContratoEmpleado = @IDContratoEmpleado
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContratoEmpleado]','[RH].[spUIContratoEmpleado]','UPDATE',@NewJSON,@OldJSON
		END;          
	END    

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado  
	EXEC RH.spBuscarContratoEmpleado @IDEmpleado = @IDEmpleado, @IDContratoEmpleado = @IDContratoEmpleado          
END
GO
