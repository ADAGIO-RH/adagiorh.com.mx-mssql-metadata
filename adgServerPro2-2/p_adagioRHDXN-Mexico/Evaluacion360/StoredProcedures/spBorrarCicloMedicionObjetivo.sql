USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar Ciclo de medicion empleado
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-03-16
** Paremetros		:   
			@IDCicloMedicionObjetivo int
			@IDUsuario int				
			
				    		  

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE PROC [Evaluacion360].[spBorrarCicloMedicionObjetivo](	
    @IDCicloMedicionObjetivo int
   ,@ConfirmarEliminar	bit  = 0
   ,@IDUsuario int
   
) as

	declare 
        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarCicloMedicionObjetivo]',
		@Tabla		varchar(max) = '[Evaluacion360.tblCatCiclosMedicionObjetivos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
        @TotalObjetivos int
	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    BEGIN TRY  
            
		if (((select count(*) from Evaluacion360.tblObjetivosEmpleados where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo) > 0) and @ConfirmarEliminar = 0)
        begin
            
            select @TotalObjetivos=count(*) from Evaluacion360.tblObjetivosEmpleados where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
            
			        
            -- select 
			-- 'Este ciclo tiene  '+cast(@TotalObjetivos as varchar)+ case when @TotalObjetivos=1 then ' objetivo' else ' objetivos' end+' asociados que serán eliminados. ¿Desea continuar?' as Mensaje
			-- ,1 as TipoRespuesta
             select 
			'Este ciclo tiene  '+cast(@TotalObjetivos as varchar)+ 
                CASE WHEN @TotalObjetivos=1 THEN ' objetivo asociado y será eliminado ¿Desea continuar?'
                     ELSE ' objetivos asociados y serán eliminados ¿Desea continuar?' END AS Mensaje
			,1 as TipoRespuesta
            RETURN
            RETURN

        end
        else
        begin
                SELECT @OldJSON = a.JSON
            FROM
            (
                SELECT *
                FROM Evaluacion360.tblCatCiclosMedicionObjetivos
                WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo
                
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML Raw))) a


            DELETE FROM Evaluacion360.tblCatCiclosMedicionObjetivos WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo
    

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

            SELECT 'Ciclo eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
            RETURN;
            
        end    
    
        
		  
    END TRY  
    BEGIN CATCH  
	--    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   SELECT 'Ocurrio un error no controlado' as Mensaje
                   ,-1 as TipoRespuesta
    END CATCH ;
GO
