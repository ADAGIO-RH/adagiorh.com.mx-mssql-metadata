USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUContactosEmpleadosTiposNotificaciones](
	@IDContactoEmpleadoTipoNotificacion int = 0, 
	@IDEmpleado int,
	@IDTipoNotificacion varchar(50),
	@IDTemplateNotificacion int,
	@IDContactoEmpleado int,
	@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
        @NewJSON Varchar(Max); 

	declare @tempResponse as table (
		IDTipoNotificacion   varchar(255)   					
		,IDTemplateNotificacion int							
		,IDEmpleado int
		,IDContactoEmpleado int 				
	);


    /*if  (@IDTemplateNotificacion=-1)
    begin 

        select @IDTemplateNotificacion=tn.IDTemplateNotificacion 
		From RH.tblContactoEmpleado ce 
			inner join rh.tblCatTipoContactoEmpleado cem on cem.IDTipoContacto=ce.IDTipoContactoEmpleado
			inner join App.tblTemplateNotificaciones tn on tn.IDMedioNotificacion=cem.IDMedioNotificacion 
        where  tn.IDTipoNotificacion=@IDTipoNotificacion  and ce.IDContactoEmpleado=@IDContactoEmpleado and ce.IDEmpleado=@IDEmpleado
    end

    if exists (select top 1 1 
				from  RH.tblContactosEmpleadosTiposNotificaciones  n 
				where n.IDTemplateNotificacion=@IDTemplateNotificacion and 
                    n.IDEmpleado=@IDEmpleado and 
                    n.IDTipoNotificacion= @IDTipoNotificacion and 
                    n.IDContactoEmpleado=@IDContactoEmpleado
				)
	begin
		raiserror('El contacto del empleado ya esta en uso.',16,1);
		return;
	end; */
    
    INSERT INTO RH.tblContactosEmpleadosTiposNotificaciones(IDEmpleado,IDTemplateNotificacion,IDTipoNotificacion,IDContactoEmpleado)            
    SELECT IDEmpleado,IDTemplateNotificacion,IDTipoNotificacion,CASE WHEN ISNULL(@IDContactoEmpleado,0) = 0 THEN null else @IDContactoEmpleado end fROM (
        SELECT 
            @IDEmpleado IDEmpleado,
            s.IDTemplateNotificacion,
            s.IDTipoNotificacion   
            FROM app.tblTemplateNotificaciones  s 
        WHERE s.IDTipoNotificacion=@IDTipoNotificacion
            EXCEPT
        SELECT  
            ce.IDEmpleado,
            ce.IDTemplateNotificacion,
            s.IDTipoNotificacion        
        FROM app.tblTemplateNotificaciones  s        
        LEFT JOIN  rh.tblContactosEmpleadosTiposNotificaciones ce on s.IDTemplateNotificacion=ce.IDTemplateNotificacion
        WHERE s.IDTipoNotificacion=@IDTipoNotificacion and (ce.IDEmpleado=@IDEmpleado )
    ) AS TABLA 
 
	IF(ISNULL(@IDContactoEmpleadoTipoNotificacion,0) <> 0)	 
    BEGIN
		select @OldJSON = a.JSON from [RH].[tblContactosEmpleadosTiposNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion

        UPDATE   ce            
            set ce.IDContactoEmpleado = CASE WHEN ISNULL(@IDContactoEmpleado,0) = 0 THEN null else @IDContactoEmpleado end
				--ce.IDTemplateNotificacion = @IDTemplateNotificacion,
				--ce.IDTipoNotificacion = @IDTipoNotificacion
        FROM RH.tblContactosEmpleadosTiposNotificaciones ce
        WHERE ce.IDTipoNotificacion = @IDTipoNotificacion and IDEmpleado = @IDEmpleado

		/*UPDATE RH.tblContactosEmpleadosTiposNotificaciones
			set IDContactoEmpleado = CASE WHEN ISNULL(@IDContactoEmpleado,0) = 0 THEN null else @IDContactoEmpleado end, 
				IDTemplateNotificacion = @IDTemplateNotificacion,
				IDTipoNotificacion = @IDTipoNotificacion
		WHERE IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion
		and IDEmpleado = @IDEmpleado*/
		
		select @NewJSON = a.JSON from [RH].[tblContactosEmpleadosTiposNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContactosEmpleadosTiposNotificaciones]','[RH].[spIUContactosEmpleadosTiposNotificaciones]','UPDATE',@NewJSON,@OldJSON

	END

    
	
	EXEC RH.spBuscarContactosEmpleadosTiposNotificaciones 
		@IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion
		,@IDEmpleado = @IDEmpleado
		,@IDUsuario = @IDUsuario
END
GO
