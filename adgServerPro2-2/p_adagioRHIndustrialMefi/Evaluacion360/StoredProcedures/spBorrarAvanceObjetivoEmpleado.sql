USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [Evaluacion360].[spBorrarAvanceObjetivoEmpleado](
	 @IDAvanceObjetivoEmpleado int = 0    
	,@IDUsuario int
) as

	SET FMTONLY OFF;  
    DECLARE 
        @OldJSON varchar(Max),
        @Message varchar(max),
        @IDEmpleado int,
        @IDObjetivoEmpleado int,
        @IDTipoMedicionObjetivo int,
        @IDOperador int,
        @TotalProgreso varchar(max),
        @PorcentajeAlcanzado decimal(18,2),
        @IDEstatusAutorizacion int = 0,
        @IDEstatusCicloMedicionObjetivo int = 0,
        @ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR int = 1,
        @ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO int = 2,
        @ID_ESTATUS_AUTORIZACION_AUTORIZADO int = 2,
        @ID_TIPO_MEDICION_OBJETIVO_FECHA int = 3,
        @ID_OPERADOR_MENOR_IGUAL int = 1,
        @ID_OPERADOR_MAYOR_IGUAL int = 2,
        @IDCicloMedicionObjetivo int,
        @FechaInicioCicloMedicion date,
        @Actual varchar(max),
        @Objetivo varchar(max),
		@NewJSON varchar(Max);

    SELECT @IDObjetivoEmpleado = IDObjetivoEmpleado           
    FROM Evaluacion360.tblAvanceObjetivoEmpleado
    WHERE IDAvanceObjetivoEmpleado=@IDAvanceObjetivoEmpleado

    
    SELECT 
        @IDTipoMedicionObjetivo  = IDTipoMedicionObjetivo
       ,@IDOperador              = IDOperador
       ,@IDCicloMedicionObjetivo = IDCicloMedicionObjetivo
       ,@Objetivo                = Objetivo
       ,@IDEmpleado              = IDEmpleado
       ,@IDEstatusAutorizacion   = IDEstatusAutorizacion
    FROM Evaluacion360.tblObjetivosEmpleados
    WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado

    SELECT 
        @FechaInicioCicloMedicion=CMO.FechaInicio
       ,@IDEstatusCicloMedicionObjetivo=CMO.IDEstatusCicloMedicion
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos CMO WITH (NOLOCK)
    WHERE CMO.IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo

     IF(@IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR AND @IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO)
    BEGIN 
            set @Message = FORMATMESSAGE('El estatus actual del ciclo de medición no permite capturar o realizar cambios en objetivos')
			raiserror(@Message,16,1)
			return;						
    END

    IF(@IDEstatusAutorizacion<>@ID_ESTATUS_AUTORIZACION_AUTORIZADO)
    BEGIN 
            set @Message = FORMATMESSAGE('No se pueden capturar avances en objetivos que no esten autorizados')
			raiserror(@Message,16,1)
			return;						
    END


    select @OldJSON = a.JSON 
		from (
			select 
				 [AOE].[IDAvanceObjetivoEmpleado]
                ,[AOE].[IDObjetivoEmpleado]
                ,[AOE].[Valor]
                ,[AOE].[Fecha]
                ,[AOE].[FechaCaptura]
                ,[AOE].[Comentario]
                ,[AOE].[IDUsuario]                
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario				
			from Evaluacion360.tblAvanceObjetivoEmpleado AOE
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = AOE.IDUsuario                                
			where (AOE.IDAvanceObjetivoEmpleado= @IDAvanceObjetivoEmpleado)
		) b
	cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a


    DELETE Evaluacion360.tblAvanceObjetivoEmpleado WHERE IDAvanceObjetivoEmpleado=@IDAvanceObjetivoEmpleado

    IF(@IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA)
    BEGIN
        SELECT 
            @TotalProgreso = CONVERT(varchar(max), SUM(CAST(Valor AS decimal(18, 2))))
        FROM Evaluacion360.tblAvanceObjetivoEmpleado
        WHERE IDObjetivoEmpleado = @IDObjetivoEmpleado;
        
        SET @PorcentajeAlcanzado = ISNULL(Evaluacion360.fnCalcularPorcentaje(
                                                                       @IDTipoMedicionObjetivo                                                                        
                                                                      , CASE WHEN @IDOperador = @ID_OPERADOR_MAYOR_IGUAL THEN @Objetivo 
                                                                             WHEN @IDOperador = @ID_OPERADOR_MENOR_IGUAL THEN @TotalProgreso 
                                                                             ELSE '0'
                                                                             END
                                                                      , CASE WHEN @IDOperador = @ID_OPERADOR_MAYOR_IGUAL THEN @TotalProgreso
                                                                             WHEN @IDOperador = @ID_OPERADOR_MENOR_IGUAL THEN @Objetivo 
                                                                             ELSE '0'
                                                                             END
                                                                      ,@FechaInicioCicloMedicion
                                                                      ,@IDOperador
                                                                    ),0)
        SET @Actual= @TotalProgreso
    END
    ELSE
    BEGIN
        SET @PorcentajeAlcanzado = 0
        SET @Actual = NULL
    END

    UPDATE Evaluacion360.tblObjetivosEmpleados
        SET PorcentajeAlcanzado=@PorcentajeAlcanzado
           ,Actual=@Actual            
    WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado
    exec Evaluacion360.spUProgresoGeneralPorCicloEmpleado @IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo, @IDEmpleado = @IDEmpleado                                                                        

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblAvanceObjetivoEmpleado',' Evaluacion360.spBorrarAvanceObjetivoEmpleado','Delete','',@OldJSON
GO
