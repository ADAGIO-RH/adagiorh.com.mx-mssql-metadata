USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar Objetivo Empleado
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-02-07
** Paremetros		:   
			@IDObjetivoEmpleado int
			@IDUsuario int				
			
				    		  

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Evaluacion360].[spBorrarObjetivoEmpleado](
	@IDObjetivoEmpleado int
   ,@IDCicloMedicionObjetivo int
   ,@ConfirmarEliminar	bit  = 0
   ,@IDEmpleado int
   ,@IDUsuario int
   
) as

	declare 
        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarObjetivoEmpleado]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblObjetivosEmpleados]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
        @TotalPlanDeAccion int

	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    BEGIN TRY  
        
    if (((select count(*) from Evaluacion360.tblPlanAccionObjetivos where IDObjetivoEmpleado = @IDObjetivoEmpleado) > 0) and @ConfirmarEliminar = 0)
        begin
            
            select @TotalPlanDeAccion=count(*) from Evaluacion360.tblPlanAccionObjetivos where IDObjetivoEmpleado = @IDObjetivoEmpleado
            
			        
            select 
			'Este objetivo tiene  '+cast(@TotalPlanDeAccion as varchar)+ 
                CASE WHEN @TotalPlanDeAccion=1 THEN ' plan de acción asociado y será eliminado ¿Desea continuar?'
                     ELSE ' planes de acción asociados y serán eliminados ¿Desea continuar?' END AS Mensaje
			,1 as TipoRespuesta
            RETURN

        end
        else
        begin

            SELECT @OldJSON = a.JSON
            FROM
            (
                SELECT *
                FROM Evaluacion360.tblObjetivosEmpleados
                WHERE IDObjetivoEmpleado = @IDObjetivoEmpleado
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML Raw))) a


            DELETE FROM Evaluacion360.tblObjetivosEmpleados WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado
    

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

            
            exec Evaluacion360.spUProgresoGeneralPorCicloEmpleado @IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo, @IDEmpleado = @IDEmpleado
            
            SELECT 'Objetivo eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
            RETURN;
            
        end    
		  
    END TRY  
    BEGIN CATCH  
	     SELECT 'Ocurrio un error no controlado' as Mensaje
                   ,-1 as TipoRespuesta
    END CATCH ;
GO
