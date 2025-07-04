USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarAumentoMasivo]
(
    @IDAumentoMasivo INT,
    @ConfirmarEliminar BIT=0,
    @IDUsuario INT
)
AS
BEGIN

     declare 
        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarAumentoMasivo]',
		@Tabla		varchar(max) = '[Nomina].[tblAumentoMasivo]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
        @TotalRegistros int
	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    BEGIN TRY  
            
	    IF (((select count(*) from Nomina.tblAumentoMasivoEmpleado where IDAumentoMasivo = @IDAumentoMasivo) > 0) and @ConfirmarEliminar = 0)
        BEGIN
            
            select @TotalRegistros=count(*) from Nomina.tblAumentoMasivoEmpleado where IDAumentoMasivo = @IDAumentoMasivo
			        
             select 
			'Este Aumento Masivo tiene '+cast(@TotalRegistros as varchar)+ 
                CASE WHEN @TotalRegistros=1 THEN ' movimiento aplicado y será eliminado junto con su movimiento afiliatorio'
                     ELSE ' movimientos aplicados y serán eliminados junto con sus movimientos afiliatorios' END AS Mensaje
            -- cast(@TotalRegistros as varchar) as Mensaje
			,1 as TipoRespuesta
            RETURN            

        END
        ELSE
        BEGIN
             SELECT @OldJSON = a.JSON
            FROM
            (
                SELECT *
                FROM Nomina.tblAumentoMasivo
                WHERE IDAumentoMasivo=@IDAumentoMasivo
                
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML Raw))) a


            SELECT @TotalRegistros=count(*) FROM Nomina.tblAumentoMasivoEmpleado WHERE IDAumentoMasivo = @IDAumentoMasivo

            IF(@TotalRegistros>0)
            BEGIN
               
               DELETE 
               FROM IMSS.tblMovAfiliatorios
               WHERE IDMovAfiliatorio IN(
                    SELECT AME.IDMovAfiliatorio
                    FROM Nomina.tblAumentoMasivoEmpleado AME                            
                    WHERE AME.IDAumentoMasivo=@IDAumentoMasivo                    
               )
               EXEC [IMSS].[spIUVigenciaEmpleado]
               EXEC [RH].[spSincronizarEmpleadosMaster]


               
               DELETE FROM Nomina.tblAumentoMasivo WHERE IDAumentoMasivo=@IDAumentoMasivo
                               
            END
            ELSE
            BEGIN
              DELETE FROM Nomina.tblAumentoMasivo WHERE IDAumentoMasivo=@IDAumentoMasivo
            END
                    
			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

            SELECT 'Aumento eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
            RETURN;
            
        END    
    
        
		  
    END TRY  
    BEGIN CATCH  
	--    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   SELECT 'Ocurrio un error no controlado' as Mensaje
                   ,-1 as TipoRespuesta
    END CATCH ;
END;
GO
