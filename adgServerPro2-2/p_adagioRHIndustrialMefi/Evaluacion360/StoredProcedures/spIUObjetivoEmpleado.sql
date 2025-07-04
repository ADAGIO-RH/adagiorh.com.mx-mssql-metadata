USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [Evaluacion360].[spIUObjetivoEmpleado](
	@IDObjetivoEmpleado int = 0,
    @Nombre varchar(500),
	@Descripcion varchar(max),
	@IDCicloMedicionObjetivo int,
    @IDTipoMedicionObjetivo int,
    @IDEmpleado int,
    @Objetivo varchar(max),	
	@Peso decimal(18,2),
	@IDEstatusObjetivoEmpleado int,
    @IDPeriodicidadActualizacion int,
    @IDOperador int,
	@IDUsuarioCreo int
) as

	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
        @Message varchar(max),
		@PorcentajeAlcanzado decimal(18,2),
		@FechaInicioCicloMedicion date,
        @TotalProgreso varchar(max) = '0', 
        @Actual varchar(max),       
        @IDEstatusAutorizacion int,
        @ObjetivoCapturadoPorJefe bit=0,
        @PermitirIngresoObjetivosEmpleados bit,
        @EmpleadoApruebaObjetivos bit,
        @IDEmpleadoUsuarioCreo int=0,
        @IDEstatusCicloMedicionObjetivo int=0,
        @ID_TIPO_MEDICION_OBJETIVO_FECHA int = 3,
        @ID_OPERADOR_MENOR_IGUAL int = 1,
        @ID_OPERADOR_MAYOR_IGUAL int = 2,
        @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZACION INT = 8 ,
        @ID_ESTATUS_AUTORIZACION_PENDIENTE_AUTORIZACION INT = 1,
        @ID_ESTATUS_AUTORIZACION_AUTORIZADO INT = 2,
        @ID_ESTATUS_AUTORIZACION_NO_AUTORIZADO INT = 3,
        @ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR INT = 1,
        @ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO INT = 2
	;

        

    SET @Descripcion=UPPER(@Descripcion)
    SET @Nombre=UPPER(@Nombre)


    SELECT @FechaInicioCicloMedicion=CMO.FechaInicio
          ,@PermitirIngresoObjetivosEmpleados=isnull(CMO.PermitirIngresoObjetivosEmpleados,CAST(0 AS bit))
          ,@EmpleadoApruebaObjetivos=isnull(CMO.EmpleadoApruebaObjetivos,CAST(0 AS bit))
          ,@IDEstatusCicloMedicionObjetivo=IDEstatusCicloMedicion
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos CMO WITH (NOLOCK)
    WHERE CMO.IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo

    
    SELECT 
        @IDEmpleadoUsuarioCreo=ISNULL(IDEmpleado,0)
    FROM Seguridad.tblUsuarios 
    WHERE IDUsuario=@IDUsuarioCreo
        
    SELECT TOP 1 
        @ObjetivoCapturadoPorJefe = cast (1 as bit)
    FROM RH.tblJefesEmpleados JE
    WHERE JE.IDJefe=@IDEmpleadoUsuarioCreo 
    AND JE.IDEmpleado=@IDEmpleado
    

    IF(@IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_SIN_COMENZAR AND @IDEstatusCicloMedicionObjetivo<>@ID_ESTATUS_CICLO_MEDICION_EN_PROGRESO)
    BEGIN 
            set @Message = FORMATMESSAGE('El estatus actual del ciclo de medición no permite capturar o realizar cambios en objetivos')
			raiserror(@Message,16,1)
			return;						
    END

	IF(@IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA AND ISNULL(TRY_CONVERT(FLOAT,@Objetivo),0)<0)
    BEGIN 
            set @Message = FORMATMESSAGE('El valor del objetivo no puede ser menor a 0')
			raiserror(@Message,16,1)
			return;						
    END

    IF(ISNULL(TRY_CONVERT(FLOAT,@Peso),0)<0)
    BEGIN 
            set @Message = FORMATMESSAGE('El valor del peso no puede ser menor a 0')
			raiserror(@Message,16,1)
			return;						
    END


	IF (isnull(@IDObjetivoEmpleado, 0) = 0)
	BEGIN
        ---Validación para que los usuarios no puedan crearse objetivos si el ciclo de medición no lo permite
        IF(@IDUsuarioCreo=ISNULL((SELECT IDUsuario FROM Seguridad.tblUsuarios WHERE IDEmpleado=@IDEmpleado),0) AND @PermitirIngresoObjetivosEmpleados=CAST(0 AS bit))
        BEGIN 
            set @Message = FORMATMESSAGE('El ciclo de medición no esta configurado para que el usuario capture sus propios objetivos .')
			raiserror(@Message,16,1)
			return;						
        END
        
        ---Determinación de estatus de aprobación
        IF(@IDUsuarioCreo=ISNULL((SELECT IDUsuario FROM Seguridad.tblUsuarios WHERE IDEmpleado=@IDEmpleado),0) AND @PermitirIngresoObjetivosEmpleados=CAST(1 AS bit))
        BEGIN
            SET @IDEstatusAutorizacion= @ID_ESTATUS_AUTORIZACION_PENDIENTE_AUTORIZACION
            SET @IDEstatusObjetivoEmpleado = @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZACION
        END
        ELSE IF(@EmpleadoApruebaObjetivos= CAST(1 AS BIT))
        BEGIN
            SET @IDEstatusAutorizacion = @ID_ESTATUS_AUTORIZACION_PENDIENTE_AUTORIZACION
            SET @IDEstatusObjetivoEmpleado = @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZACION
        END
        ELSE
        BEGIN
            SET @IDEstatusAutorizacion = @ID_ESTATUS_AUTORIZACION_AUTORIZADO
        END

		insert Evaluacion360.tblObjetivosEmpleados(
			 Nombre
			,Descripcion
			,IDCicloMedicionObjetivo
			,IDTipoMedicionObjetivo
			,IDEmpleado
            ,Objetivo            
            ,Peso
            ,PorcentajeAlcanzado
            ,IDEstatusObjetivoEmpleado
            ,IDEstatusAutorizacion
            ,IDPeriodicidadActualizacion
            ,IDOperador
            ,IDUsuarioCreo
            ,FechaHoraReg
			
		)
		values (
			 @Nombre
			,@Descripcion
			,@IDCicloMedicionObjetivo
			,@IDTipoMedicionObjetivo
			,@IDEmpleado
            ,@Objetivo            
            ,@Peso
			,isnull(@PorcentajeAlcanzado, 0)
			,@IDEstatusObjetivoEmpleado
            ,@IDEstatusAutorizacion
            ,@IDPeriodicidadActualizacion
			,@IDOperador
            ,@IDUsuarioCreo
			,getdate()
		)

		set @IDObjetivoEmpleado = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				 oe.IDObjetivoEmpleado
				,oe.Nombre
                ,oe.Descripcion
                ,oe.IDEmpleado
				,oe.Objetivo				
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
                ,oe.IDPeriodicidadActualizacion
				,oe.IDOperador
                ,oe.IDUsuarioCreo
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as UsuarioCreo
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
                join Evaluacion360.tblCatEstatusObjetivosEmpleado eoe on eoe.IDEstatusObjetivoEmpleado=oe.IDEstatusObjetivoEmpleado
                join App.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuarioCreo,'Evaluacion360.tblObjetivosEmpleados',' Evaluacion360.spIUObjetivoEmpleado','INSERT',@NewJSON,''
	END ELSE
	BEGIN
		select @OldJSON = a.JSON 
		from (
			select 
				 oe.IDObjetivoEmpleado
				,oe.Nombre
                ,oe.Descripcion
                ,oe.IDEmpleado
				,oe.Objetivo				
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
                ,oe.IDPeriodicidadActualizacion
				,oe.IDOperador
                ,oe.IDUsuarioCreo
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as UsuarioCreo
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
                join Evaluacion360.tblCatEstatusObjetivosEmpleado eoe on eoe.IDEstatusObjetivoEmpleado=oe.IDEstatusObjetivoEmpleado
                join App.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

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
                        
        END
        ELSE
        BEGIN
            SELECT @Actual = OE.Actual
            FROM Evaluacion360.tblObjetivosEmpleados OE
            WHERE OE.IDObjetivoEmpleado=@IDObjetivoEmpleado

            SET @PorcentajeAlcanzado = ISNULL(Evaluacion360.fnCalcularPorcentaje(
                                                                           @IDTipoMedicionObjetivo                                                                        
                                                                          , CASE WHEN @IDOperador = @ID_OPERADOR_MAYOR_IGUAL THEN @Objetivo 
                                                                                 WHEN @IDOperador = @ID_OPERADOR_MENOR_IGUAL THEN @Actual 
                                                                                 ELSE '0'
                                                                                 END
                                                                          , CASE WHEN @IDOperador = @ID_OPERADOR_MAYOR_IGUAL THEN @Actual
                                                                                 WHEN @IDOperador = @ID_OPERADOR_MENOR_IGUAL THEN @Objetivo 
                                                                                 ELSE '0'
                                                                                 END
                                                                          ,@FechaInicioCicloMedicion
                                                                          ,@IDOperador
                                                                        ),0)
            
        END


		update Evaluacion360.tblObjetivosEmpleados
			set
                     Nombre=@Nombre
                    ,Descripcion=@Descripcion
                    ,IDTipoMedicionObjetivo=@IDTipoMedicionObjetivo
                    ,Objetivo=@Objetivo                    
                    ,Peso=@Peso            
                    ,PorcentajeAlcanzado=@PorcentajeAlcanzado        
                    ,IDEstatusObjetivoEmpleado	= case when PorcentajeAlcanzado > 0 and IDEstatusObjetivoEmpleado = 1 then 2 else @IDEstatusObjetivoEmpleado end
                    ,IDPeriodicidadActualizacion= @IDPeriodicidadActualizacion
                    ,UltimaActualizacion	= getdate()
                    ,IDOperador=@IDOperador
    
		where IDObjetivoEmpleado=@IDObjetivoEmpleado
    
		select @NewJSON = a.JSON 
		from (		 
			select 
				 oe.IDObjetivoEmpleado
				,oe.Nombre
                ,oe.Descripcion
                ,oe.IDEmpleado
				,oe.Objetivo				
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
                ,oe.IDPeriodicidadActualizacion
				,oe.IDOperador
                ,oe.IDUsuarioCreo
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as UsuarioCreo
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
                join Evaluacion360.tblCatEstatusObjetivosEmpleado eoe on eoe.IDEstatusObjetivoEmpleado=oe.IDEstatusObjetivoEmpleado
                join App.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuarioCreo,'Evaluacion360.tblObjetivosEmpleados',' Evaluacion360.spIUObjetivoEmpleado','UPDATE',@NewJSON,@OldJSON
	END

    exec Evaluacion360.spUProgresoGeneralPorCicloEmpleado @IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo, @IDEmpleado = @IDEmpleado                                                                        

	exec Evaluacion360.spBuscarObjetivosEmpleados 
		@IDObjetivoEmpleado=@IDObjetivoEmpleado, 
		@IDUsuarioConsulta=@IDUsuarioCreo
GO
