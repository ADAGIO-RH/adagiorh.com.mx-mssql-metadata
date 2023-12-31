USE [q_adagioRHTuning]
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

    if  (@IDTemplateNotificacion=-1)
    begin 

        select @IDTemplateNotificacion=tn.IDTemplateNotificacion From RH.tblContactoEmpleado ce 
        inner join rh.tblCatTipoContactoEmpleado cem on cem.IDTipoContacto=ce.IDTipoContactoEmpleado
        inner join App.tblTemplateNotificaciones tn on tn.IDMedioNotificacion=cem.IDMedioNotificacion 
        where  tn.IDTipoNotificacion=@IDTipoNotificacion  and ce.IDContactoEmpleado=@IDContactoEmpleado and ce.IDEmpleado=@IDEmpleado
    end

    if exists (select top 1 1 from  RH.tblContactosEmpleadosTiposNotificaciones  n where    n.IDTemplateNotificacion=@IDTemplateNotificacion and 
                                                                                            n.IDEmpleado=@IDEmpleado and 
                                                                                            n.IDTipoNotificacion= @IDTipoNotificacion and 
                                                                                            n.IDContactoEmpleado=@IDContactoEmpleado)
	begin
		raiserror('El contacto del empleado ya esta en uso.',16,1);
		return;
	end;
    
	IF(ISNULL(@IDContactoEmpleadoTipoNotificacion,0) = 0)
	BEGIN
		INSERT INTO RH.tblContactosEmpleadosTiposNotificaciones(IDEmpleado,IDTemplateNotificacion,IDTipoNotificacion,IDContactoEmpleado)
		VALUES(@IDEmpleado,@IDTemplateNotificacion,@IDTipoNotificacion,CASE WHEN ISNULL(@IDContactoEmpleado,0) = 0 THEN null else @IDContactoEmpleado end)

		set @IDContactoEmpleadoTipoNotificacion = @@IDENTITY

			
		select @NewJSON = a.JSON from [RH].[tblContactosEmpleadosTiposNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContactosEmpleadosTiposNotificaciones]','[RH].[spIUContactosEmpleadosTiposNotificaciones]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[tblContactosEmpleadosTiposNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion

		UPDATE RH.tblContactosEmpleadosTiposNotificaciones
			set IDContactoEmpleado = CASE WHEN ISNULL(@IDContactoEmpleado,0) = 0 THEN null else @IDContactoEmpleado end, 
				IDTemplateNotificacion = @IDTemplateNotificacion,
				IDTipoNotificacion = @IDTipoNotificacion
		WHERE IDContactoEmpleadoTipoNotificacion = @IDContactoEmpleadoTipoNotificacion
		and IDEmpleado = @IDEmpleado
		
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
