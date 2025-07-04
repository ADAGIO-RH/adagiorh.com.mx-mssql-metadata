USE [p_adagioRHRuggedTech]
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
   ,@IDUsuarioConsulta int
   
) as

	declare 
        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarObjetivoEmpleado]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblObjetivosEmpleados]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
        @TotalPlanDeAccion int,
        @TotalAvanceObjetivoEmpleado int,
        @IDEstatusAutorizacion int,
        @IDUsuarioCreo int,        
        @IDEmpleadoUsuarioCreo int,
        @PermitirIngresoObjetivosEmpleados bit,
        @ID_ESTATUS_AUTORIZACION_PENDIENTE_AUTORIZACION INT = 1,
        @ID_ESTATUS_AUTORIZACION_AUTORIZADO INT = 2,
        @ID_ESTATUS_AUTORIZACION_NO_AUTORIZADO INT = 3,
        @ID_TIPO__PLAN_ACCION_OBJETIVO int = 1;

	    
	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;


    SELECT 
        @IDEstatusAutorizacion=ISNULL(IDEstatusAutorizacion,0)
       ,@IDUsuarioCreo=ISNULL(IDUsuarioCreo,0)
    FROM Evaluacion360.tblObjetivosEmpleados OE
    WHERE OE.IDObjetivoEmpleado=@IDObjetivoEmpleado

    SELECT 
        @IDEmpleadoUsuarioCreo=ISNULL(IDEmpleado,0)
    FROM Seguridad.tblUsuarios 
    WHERE IDUsuario=@IDUsuarioCreo

    SELECT @PermitirIngresoObjetivosEmpleados=ISNULL(PermitirIngresoObjetivosEmpleados,CAST(0 AS BIT))
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos
    WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo

    BEGIN TRY  
        
        IF(@IDUsuarioConsulta<>@IDUsuarioCreo)
        BEGIN
            SELECT 'No puedes eliminar este objetivo porque no ha sido capturado por tu usuario' AS Mensaje,
            -1 AS TipoRespuesta;
            RETURN
        END
        IF((@IDEmpleadoUsuarioCreo=@IDEmpleado) AND @PermitirIngresoObjetivosEmpleadoS=CAST(0 AS BIT))
        BEGIN
            SELECT 'No puedes eliminar este objetivo debido a la configuración del ciclo de medición' AS Mensaje,
            -1 AS TipoRespuesta;
            RETURN
        END
        
        
        select @TotalPlanDeAccion=count(*) from App.tblPlanAccion where IDReferencia = @IDObjetivoEmpleado and IDTipoPlanAccion = @ID_TIPO__PLAN_ACCION_OBJETIVO 
           select @TotalAvanceObjetivoEmpleado=count(*) from Evaluacion360.tblAvanceObjetivoEmpleado where IDObjetivoEmpleado=@IDObjetivoEmpleado

        IF (( ISNULL(@TotalPlanDeAccion,0)> 0 OR ISNULL(@TotalAvanceObjetivoEmpleado,0)>0) and @ConfirmarEliminar = 0)
        BEGIN

            IF(( ISNULL(@TotalPlanDeAccion,0)> 0 AND ISNULL(@TotalAvanceObjetivoEmpleado,0)>0))
            BEGIN
                 SELECT 'Este objetivo tiene ' + CAST(@TotalPlanDeAccion AS VARCHAR) + 
                        ' plan(es) de acción asociado(s) y ' + CAST(@TotalAvanceObjetivoEmpleado AS VARCHAR) +
                        ' registro(s) de avance  asociado(s). ¿Desea continuar?' AS Mensaje,
                        1 AS TipoRespuesta;
            END
            ELSE IF(ISNULL(@TotalPlanDeAccion,0)> 0)
            BEGIN
                SELECT 'Este objetivo tiene ' + CAST(@TotalPlanDeAccion AS VARCHAR) + 
                      ' plan(es) de acción asociado(s). ¿Desea continuar?' AS Mensaje,
                        1 AS TipoRespuesta;
            END
            ELSE IF(ISNULL(@TotalAvanceObjetivoEmpleado,0)> 0)
            BEGIN
                SELECT 'Este objetivo tiene ' + CAST(@TotalAvanceObjetivoEmpleado AS VARCHAR) +
                        ' registro(s) de avance  asociado(s). ¿Desea continuar?' AS Mensaje,
                        1 AS TipoRespuesta;
            END            
        END
        ELSE
        BEGIN
            
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
				@IDUsuario		= @IDUsuarioConsulta
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

            IF((select count(*) from App.tblPlanAccion where IDReferencia = @IDObjetivoEmpleado and IDTipoPlanAccion = @ID_TIPO__PLAN_ACCION_OBJETIVO  ) > 0)
            BEGIN
                
                EXEC  [App].[spBorrarPlanAccion] @IDPlanAccion = 0 , @IDReferencia=@IDObjetivoEmpleado ,@IDTipoPlanAccion = @ID_TIPO__PLAN_ACCION_OBJETIVO,@IDUsuario=@IDUsuarioConsulta
         
            END                   
            RETURN;
            
        END    
		  
    END TRY  
    BEGIN CATCH  
	     SELECT 'Ocurrio un error no controlado' as Mensaje
                   ,-1 as TipoRespuesta
    END CATCH ;
GO
