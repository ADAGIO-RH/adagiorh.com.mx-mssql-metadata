USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spAutorizarDeclinarObjetivoEmpleado](	 
    @IDObjetivoEmpleado int
    ,@Value int    
	,@IDUsuarioAutorizo int
) as
    /*
        Value=2 autorizado
        Value=3 rechazado
    */
	SET FMTONLY OFF;  
    DECLARE 
        @OldJSON VARCHAR(Max),        
		@NewJSON VARCHAR(Max),
        @IDCicloMedicionObjetivo INT = 0,
        @IDIdioma VARCHAR(20),    
        @IDEmpleado INT = 0,
        @Message VARCHAR(max),
        @IDEmpleadoUsuarioAutorizo INT = 0,
        @IDUsuarioCreo INT = 0,
        @IDEmpleadoUsuarioCreo INT=0, 
        @FechaInicioCicloMedicion DATE,
        @EmpleadoApruebaObjetivos BIT = 0,
        @IDEstatusAutorizacion INT = 0 ,
        @EsJefeUsuario BIT = 0,
        @ID_ESTATUS_PENDIENTE_AUTORIZAR INT = 1,
        @ID_ESTATUS_AUTORIZACION_AUTORIZADO INT = 2,
        @ID_ESTATUS_AUTORIZACION_NO_AUTORIZADO INT = 3,
        @ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_COMENZAR INT = 1,
        @ID_ESTATUS_OBJETIVO_EMPLEADO_EN_PROGRESO INT = 2,
        @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZAR INT = 8,                    
        @ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR INT = 9;

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuarioAutorizo, 'esmx')


    SELECT 
        @IDCicloMedicionObjetivo=IDCicloMedicionObjetivo
       ,@IDEmpleado=IDEmpleado
       ,@IDEstatusAutorizacion=IDEstatusAutorizacion   
       ,@IDUsuarioCreo=IDUsuarioCreo    
    FROM Evaluacion360.tblObjetivosEmpleados
    WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado

    SELECT 
        @FechaInicioCicloMedicion=FechaInicio
       ,@EmpleadoApruebaObjetivos=ISNULL(EmpleadoApruebaObjetivos,CAST(0 AS BIT))
        FROM Evaluacion360.tblCatCiclosMedicionObjetivos
    WHERE IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo

    SELECT 
        @IDEmpleadoUsuarioAutorizo=ISNULL(IDEmpleado,0)
    FROM Seguridad.tblUsuarios where IDUsuario=@IDUsuarioAutorizo

    SELECT 
        @IDEmpleadoUsuarioCreo=ISNULL(IDEmpleado,0)
    FROM Seguridad.tblUsuarios where IDUsuario=@IDUsuarioCreo



    SELECT TOP 1  @EsJefeUsuario=CAST(1 AS BIT)
        FROM RH.tblJefesEmpleados JE
    WHERE JE.IDJefe=@IDEmpleadoUsuarioAutorizo 
    AND JE.IDEmpleado=@IDEmpleado

    ---Si el objetivo no esta en estatus pendiente de autorizar no se puede autorizar
    IF(@IDEstatusAutorizacion <> @ID_ESTATUS_PENDIENTE_AUTORIZAR)
    BEGIN
        set @Message = FORMATMESSAGE('No se puede autorizar este objetivo debido a su estatus actual de autorización')
		raiserror(@Message,16,1)
		return;    
    END    
    ----La misma persona que crea el objetivo, no lo puede autorizar
    IF( @IDUsuarioAutorizo=@IDUsuarioCreo )
    BEGIN
        set @Message = FORMATMESSAGE('No tienes permiso para autorizar este objetivo ya que fue creado por tu usuario')
		raiserror(@Message,16,1)
		return;    
    END
    ---Si no eres el empleado que tiene el objetivo y no eres su jefe no lo puedes autorizar
    IF(@IDEmpleadoUsuarioAutorizo <> @IDEmpleado AND @EsJefeUsuario = CAST(0 AS BIT))
    BEGIN
        set @Message = FORMATMESSAGE('No tienes permiso para autorizar este objetivo porque no eres jefe del empleado')
		raiserror(@Message,16,1)
		return;    
    END
    
    ---Si el empleado esta autorizando un objetivo suyo y el ciclo no lo permite no puede autorizar
    IF(@IDEmpleadoUsuarioAutorizo = @IDEmpleado AND @EmpleadoApruebaObjetivos=CAST(0 AS BIT) )
    BEGIN
        set @Message = FORMATMESSAGE('No tienes permiso para modificar este objetivo debido a la configuración del ciclo de medición')
		raiserror(@Message,16,1)
		return;    
    END

    ---Si eres jefe solo puedes autorizar permisos que haya capturado el empleado
    IF(@EsJefeUsuario = CAST(1 AS BIT) AND (@IDEmpleadoUsuarioCreo <> @IDEmpleado))
    BEGIN
        set @Message = FORMATMESSAGE('No tienes permiso para modificar este objetivo ya que no entra en tu línea de autorización')
		raiserror(@Message,16,1)
		return;    
    END

    
    

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
                ,JSON_VALUE(eoe.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusObjetivoEmpleado
                ,oe.IDEstatusAutorizacion
                ,JSON_VALUE(cea.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusAutorizacion                
                ,oe.IDPeriodicidadActualizacion
				,oe.IDOperador
                ,oe.IDUsuarioCreo
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as UsuarioCreo
				,oe.FechaHoraReg                
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
                join Evaluacion360.tblCatEstatusObjetivosEmpleado eoe on eoe.IDEstatusObjetivoEmpleado=oe.IDEstatusObjetivoEmpleado
                join App.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
                join app.tblCatEstatusAutorizacion cea on cea.IDEstatusAutorizacion=oe.IDEstatusAutorizacion
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    

    IF(@Value=@ID_ESTATUS_AUTORIZACION_AUTORIZADO)
    BEGIN
        UPDATE Evaluacion360.tblObjetivosEmpleados
        SET IDEstatusAutorizacion=@ID_ESTATUS_AUTORIZACION_AUTORIZADO
            ,IDEstatusObjetivoEmpleado=CASE WHEN GETDATE()<@FechaInicioCicloMedicion THEN @ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_COMENZAR ELSE @ID_ESTATUS_OBJETIVO_EMPLEADO_EN_PROGRESO END
            ,IDUsuarioAutorizo=@IDUsuarioAutorizo
        WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado
    END
    ELSE IF(@Value=@ID_ESTATUS_AUTORIZACION_NO_AUTORIZADO)
    BEGIN
        UPDATE Evaluacion360.tblObjetivosEmpleados
        SET IDEstatusAutorizacion=@ID_ESTATUS_AUTORIZACION_NO_AUTORIZADO
            ,IDEstatusObjetivoEmpleado=@ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR
            ,IDUsuarioAutorizo=@IDUsuarioAutorizo
        WHERE IDObjetivoEmpleado=@IDObjetivoEmpleado
    END

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
                ,JSON_VALUE(eoe.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusObjetivoEmpleado
                ,oe.IDEstatusAutorizacion
                ,JSON_VALUE(cea.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusAutorizacion                
                ,oe.IDPeriodicidadActualizacion
				,oe.IDOperador
                ,oe.IDUsuarioCreo
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as UsuarioCreo
				,oe.FechaHoraReg                
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
                join Evaluacion360.tblCatEstatusObjetivosEmpleado eoe on eoe.IDEstatusObjetivoEmpleado=oe.IDEstatusObjetivoEmpleado
                join App.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
                join app.tblCatEstatusAutorizacion cea on cea.IDEstatusAutorizacion=oe.IDEstatusAutorizacion
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

    EXEC Evaluacion360.spUProgresoGeneralPorCicloEmpleado @IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo, @IDEmpleado = @IDEmpleado                                                                        
    
    EXEC [Auditoria].[spIAuditoria] @IDUsuarioAutorizo,'Evaluacion360.tblObjetivosEmpleados',' Evaluacion360.spAutorizarDeclinarObjetivoEmpleado','UPDATE',@NewJSON,@OldJSON
GO
