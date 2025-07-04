USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se usa solo para que el colaborador cree y/o actualice su solicitud.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-03-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-11-30			Jose Vargas		    Se han realizado cambios importantes en este sp, los cuales son:
                                        * Se ha dividido la funcionalidad del "Guardado"  y la "Autorizacion o Denegacion([Intranet].[spAutorizarDeclinarSolicitudPrestamos])"
                                        * Cuando se crea el registro 
                                            - IDEstatusSolicitudPrestamo: por default siempre se agregara en 1(Pendiente)
                                            - IDEstatusPrestamo: Este campo se quita del insert por que solamente se usa al momento de autorizar la solicitud.                                            
                                        * Updated
                                            Se quitaron algunos campos del "Update" que se utilizaban especificamente en las autorizaciones, los cuales son:
                                                - Cancelado
                                                - MotivoCancelacion
                                                - FechaHoraCancelacion
                                                - Autorizado
                                                - FechaHoraAutorizacion
                                                - Descripcion                                                 
                                                - IDPrestamo
                                                - Intereses
                                                - IDEstatusPrestamo                                                
***************************************************************************************************/
CREATE proc [Intranet].[spIUSolicitudesPrestamos](
	@IDSolicitudPrestamo int = 0
	,@IDEmpleado int
	,@IDTipoPrestamo int
	,@MontoPrestamo decimal(18, 2)
	,@Cuotas decimal(18, 2)
	,@CantidadCuotas int
	,@FechaInicioPago date			
	,@IDFondoAhorro int = null	
	,@IDUsuario int
) as
begin

	declare 				
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Intranet].[spIUSolicitudesPrestamos]',
		@Tabla		varchar(max) = '[Intranet].[tblSolicitudesPrestamos]',
		@Accion		varchar(20)	= '';	
	set @IDFondoAhorro		= case when @IDFondoAhorro		= 0 then null else @IDFondoAhorro end	

    BEGIN TRY
        BEGIN TRAN TransIUSolicitudPrestamo                   
            --SELECT 1/0;-- PROVOCAR EXCEPCIÓN  
            if (isnull(@IDSolicitudPrestamo,0) = 0)
            begin
                insert [Intranet].[tblSolicitudesPrestamos](IDEmpleado, IDTipoPrestamo, MontoPrestamo, Cuotas, CantidadCuotas, FechaInicioPago, IDEstatusSolicitudPrestamo, FechaCreacion, IDFondoAhorro)
                values(@IDEmpleado, @IDTipoPrestamo, @MontoPrestamo, @Cuotas, @CantidadCuotas, @FechaInicioPago, 1, getdate(), @IDFondoAhorro)

                set @IDSolicitudPrestamo = @@IDENTITY

                select @NewJSON = a.JSON
                    ,@Accion = 'INSERT'
                from [Intranet].[tblSolicitudesPrestamos] b
                    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
                WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo

                exec [App].[spINotificacioSolicitudPrestamoIntranet] @IDSolicitudPrestamo
            end else 
            begin
                select @OldJSON = a.JSON
                    ,@Accion = 'UPDATE'
                from [Intranet].[tblSolicitudesPrestamos] b
                    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
                WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo

                
                update [Intranet].[tblSolicitudesPrestamos]
                    set IDTipoPrestamo	= @IDTipoPrestamo, 
                        MontoPrestamo	= @MontoPrestamo, 
                        Cuotas			= @Cuotas,
                        CantidadCuotas	= @CantidadCuotas, 
                        FechaInicioPago	= @FechaInicioPago,                                																																								
                        IDFondoAhorro	= @IDFondoAhorro
                where IDSolicitudPrestamo = @IDSolicitudPrestamo

                select @NewJSON = a.JSON
                    ,@Accion = 'UPDATE'
                from [Intranet].[tblSolicitudesPrestamos] b
                    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
                WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo
            end        
            EXEC [Auditoria].[spIAuditoria]
                @IDUsuario		= @IDUsuario
                ,@Tabla			= @Tabla
                ,@Procedimiento	= @NombreSP
                ,@Accion		= @Accion
                ,@NewData		= @NewJSON
                ,@OldData		= @OldJSON    
            select @IDSolicitudPrestamo 'IDSolicitudPrestamo'                    
        COMMIT TRAN TransIUSolicitudPrestamo
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransIUSolicitudPrestamo
        EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1700002'
    END CATCH	 

end
GO
