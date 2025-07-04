USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para BORRAR los finiquitos 
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 11-04-2019  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  

CREATE PROCEDURE [Nomina].[spBorrarFiniquitos] --1  
(   
	@IDFiniquito int = 0,  
	@IDPeriodo int = 0,
	@IDUsuario int,
	@ConfirmarEliminar BIT = 0
)  
AS
BEGIN
	declare 
		@IDEmpleado int,
		@EstatusFiniquito varchar(max),
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarFiniquitos]',
		@Tabla		varchar(max) = '[Nomina].[tblControlFiniquitos]',
		@Accion		varchar(20)	= 'DELETE',
		@CustomMessage varchar(max),
		@Mensaje  VARCHAR(MAX) = '',
		@tran int,
        @ID_ESTATUS_FINIQUITO_APLICAR INT = 2

	;

	BEGIN TRY  
		set @tran = @@TRANCOUNT

		select @OldJSON = a.JSON 
		from (
			Select       
				CF.IDFiniquito,      
				ISNULL(CF.IDPeriodo,0) as IDPeriodo,      
				P.ClavePeriodo,      
				P.Descripcion as Periodo,      
				ISNULL(CF.IDEmpleado,0) as IDEmpleado,      
				E.ClaveEmpleado,      
				e.NOMBRECOMPLETO as Colaborador,      
				ISNULL(CF.FechaBaja,getdate())FechaBaja,      
				ISNULL(CF.FechaAntiguedad,getdate())FechaAntiguedad,      
				CF.DiasVacaciones,      
				CF.DiasAguinaldo,      
				CF.DiasIndemnizacion90Dias,      
				CF.DiasIndemnizacion20Dias,      
				ISNULL(CF.IDEStatusFiniquito,0) as IDEstatusFiniquito,      
				EF.Descripcion as EstatusFiniquito,
				isnull(DiasDePago,0) as DiasDePago,				
				isnull(DiasPorPrimaAntiguedad,0) as DiasPorPrimaAntiguedad,	
				isnull(SueldoFiniquito,0) as SueldoFiniquito,
				cast(case when ISNULL(CF.IDEStatusFiniquito,0) in(0,1) then 0 else 1 end as bit) as Aplicado,
				isnull(c.Codigo,'000') +' - '+ isnull(c.Descripcion,'SIN CONCEPTO')  as ConceptoPago,
				isnull(dp.ImporteTotal1,0.00) as ImporteTotal1
			from Nomina.tblControlFiniquitos CF with (nolock)     
				Inner join Nomina.tblCatPeriodos P with (nolock) on P.IDPeriodo = CF.IDPeriodo      
				Inner Join RH.tblEmpleadosMaster E with (nolock) on CF.IDEmpleado = E.IDEmpleado      
				Inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario  
				Inner join Nomina.tblCatEstatusFiniquito EF with (nolock) on EF.IDEStatusFiniquito = CF.IDEStatusFiniquito 
				left join Nomina.tblDetallePeriodoFiniquito dp with (nolock) on dp.IDConcepto in(select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5) and dp.IDEmpleado = cf.IDEmpleado and dp.IDPeriodo = cf.IDPeriodo and dp.ImporteTotal1 is not null
				left join Nomina.tblcatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
			WHERE (CF.IDFiniquito = @IDFiniquito) OR (CF.IDPeriodo = @IDPeriodo) 
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		

		select TOP 1 
			@IDEmpleado = IDEmpleado
			, @EstatusFiniquito = ef.Descripcion
		from Nomina.tblControlFiniquitos cf with (nolock)
			inner join Nomina.tblCatEstatusFiniquito ef with (nolock)
				on ef.IDEStatusFiniquito = cf.IDEStatusFiniquito
		where IDFiniquito = @IDFiniquito and IDPeriodo = @IDPeriodo


        IF(SELECT TOP 1 1 FROM Nomina.tblControlFiniquitos WHERE IDFiniquito = @IDFiniquito and IDPeriodo = @IDPeriodo and IDEStatusFiniquito = @ID_ESTATUS_FINIQUITO_APLICAR) = 1
        BEGIN
            SELECT 	    				    			
	    			FORMATMESSAGE('El finiquito no puede estar aplicado para su eliminación')  as Mensaje
	    			,-1 as TipoRespuesta
        END

		IF (@ConfirmarEliminar = 0) 
        BEGIN
            IF EXISTS (SELECT TOP 1 1 FROM Nomina.tblDetallePeriodoFiniquito WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo)
            BEGIN
                SET @Mensaje = '<li>El empleado cuenta con conceptos calculados en este finiquito.</li>'
            END    

            IF EXISTS (SELECT TOP 1 1 FROM Nomina.tblDetallePeriodo WHERE IDEmpleado = @IDEmpleado AND IDPeriodo = @IDPeriodo)
            BEGIN
                SET @Mensaje = ISNULL(@Mensaje, '') + '<li>El empleado cuenta con registros de nómina aplicados.</li>'
            END    

            IF (@Mensaje IS NOT NULL AND @Mensaje <> '')
            BEGIN            
                SET @Mensaje = '<p>Nota: el finiquito que intenta eliminar tiene las siguientes condiciones:</p>' + @Mensaje
                SELECT @Mensaje AS Mensaje, 1 AS TipoRespuesta
                RETURN            
            END
            ELSE
            BEGIN
                SET @ConfirmarEliminar = 1
            END
        END

		
		IF(@ConfirmarEliminar = 1)
		BEGIN 
			BEGIN TRANSACTION TranBorrarFiniquito  

				Delete Nomina.tblDetallePeriodoFiniquito
				where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo

				Delete Nomina.tblDetallePeriodo
				where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo

				delete Nomina.tblControlFiniquitos
				where IDFiniquito = @IDFiniquito and IDPeriodo = @IDPeriodo

                SELECT 'Finiquito eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
                
				COMMIT TRANSACTION TranBorrarFiniquito
		END
		
	END TRY  
	BEGIN CATCH  

		set @tran = @@TRANCOUNT
		IF (@tran > 0) ROLLBACK TRANSACTION TranBorrarFiniquito
		
		set @CustomMessage = ERROR_MESSAGE()
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage=@CustomMessage
		return 0;
	END CATCH ;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
