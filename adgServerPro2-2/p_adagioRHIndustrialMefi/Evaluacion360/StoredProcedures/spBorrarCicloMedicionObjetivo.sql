USE [p_adagioRHIndustrialMefi]
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
        @TotalObjetivos int,
        @ID_TIPO_COMENTARIO_PLAN_ACCION int = 5,
        @ID_TIPO__PLAN_ACCION_OBJETIVO int = 1

	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    BEGIN TRY  
            
		if (((select count(*) from Evaluacion360.tblObjetivosEmpleados where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo) > 0) and @ConfirmarEliminar = 0)
        begin
            
            select @TotalObjetivos=count(*) from Evaluacion360.tblObjetivosEmpleados where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
            			                    
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

            ---Eliminando comentarios de plan de acción
            DELETE 
            FROM App.tblComentarios 
            WHERE IDReferencia IN(
                SELECT IDPlanAccion
                FROM APP.tblPlanAccion PA
                WHERE PA.IDReferencia IN(
                    SELECT IDObjetivoEmpleado
                    FROM Evaluacion360.tblObjetivosEmpleados
                    WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo
                ) AND PA.IDTipoPlanAccion=@ID_TIPO__PLAN_ACCION_OBJETIVO
            ) AND IDTipoComentario=@ID_TIPO_COMENTARIO_PLAN_ACCION
            ---Eliminando planes de acción
            DELETE
            FROM APP.tblPlanAccion 
            WHERE IDReferencia IN(
                SELECT IDObjetivoEmpleado
                FROM Evaluacion360.tblObjetivosEmpleados
                WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo
            ) AND IDTipoPlanAccion=@ID_TIPO__PLAN_ACCION_OBJETIVO

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
