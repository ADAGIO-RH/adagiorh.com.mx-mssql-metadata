USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp sirve para autorizar o declinar las solicitudes de prestamos de intranet
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-11-29
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Intranet].[spAutorizarDeclinarSolicitudPrestamos](
	@IDSolicitudPrestamo int = 0	
    ,@Comentarios varchar(max)
    ,@IDEstatusPrestamo int 
    ,@Intereses decimal (10,2)
    ,@IDEstatusSolicitudPrestamo int
	,@IDUsuario int
) as
begin

    DECLARE 
		@IDEstatusSolicitudPrestamoActual INT,								
		@IDPrestamo int = 0,		
		@EnviarNotificacion bit = 0,
        @IDFondoAhorro INT,        
        @MontoPrestamo DECIMAL(10,2),
        @IDEmpleado INT,             
        @Cuotas	DECIMAL(10,2),
        @CantidadCuotas  INT,        
        @FechaInicioPago	date,        
        @IDTipoPrestamo INT;
 
    BEGIN TRY
        BEGIN TRAN TransAutorizarDeclinarSolPrest     
            --SELECT 1/0;-- PROVOCAR EXCEPCIÓN  
            SELECT
                @IDFondoAhorro= ISNULL(sp.IDFondoAhorro,0),
                @IDEstatusSolicitudPrestamoActual=sp.IDEstatusSolicitudPrestamo,
                @IDTipoPrestamo=sp.IDTipoPrestamo,
                @MontoPrestamo= sp.MontoPrestamo,
                @IDEmpleado= sp.IDEmpleado,                
                @FechaInicioPago=sp.FechaInicioPago,
                @Cuotas=sp.Cuotas,
                @CantidadCuotas=sp.CantidadCuotas
            From Intranet.tblSolicitudesPrestamos  sp
                WHERE IDSolicitudPrestamo= @IDSolicitudPrestamo
            
	        set @IDEstatusPrestamo	= case when @IDEstatusPrestamo	= 0 then null else @IDEstatusPrestamo end

            IF (@IDEstatusSolicitudPrestamoActual =1 AND @IDEstatusSolicitudPrestamo <> @IDEstatusSolicitudPrestamoActual)
                BEGIN        
                    IF(@IDEstatusSolicitudPrestamo = 2)  -- CANCELADO
                        BEGIN
                            UPDATE [Intranet].[tblSolicitudesPrestamos]
                                SET
                                    Cancelado		= 1,
                                    MotivoCancelacion= @Comentarios,
                                    FechaHoraCancelacion	= getdate(),
                                    Autorizado				= null,
                                    IDUsuarioCancelo =@IDUsuario,
                                    IDEstatusSolicitudPrestamo =@IDEstatusSolicitudPrestamo
                            WHERE IDSolicitudPrestamo = @IDSolicitudPrestamo                                        
                        END 
                    ELSE IF(@IDEstatusSolicitudPrestamo = 3 ) -- APROBADO/AUTORIZADO
                        BEGIN
                            
                            exec [Nomina].[spUIPrestamos] 
                                @IDPrestamo			= @IDPrestamo output 
                                ,@Codigo			= ''
                                ,@IDEmpleado		= @IDEmpleado  
                                ,@IDTipoPrestamo	= @IDTipoPrestamo  
                                ,@IDEstatusPrestamo	= @IDEstatusPrestamo  
                                ,@MontoPrestamo		= @MontoPrestamo
                                ,@Cuotas			= @Cuotas
                                ,@CantidadCuotas	= @CantidadCuotas  
                                ,@Descripcion		= @Comentarios
                                ,@FechaInicioPago	= @FechaInicioPago 
                                ,@Intereses			= @Intereses
                                ,@IDUsuario			= @IDUsuario                                 

                            if (@IDTipoPrestamo = 6) -- Préstamo de Fondo de ahorro
                            begin
                                exec [Nomina].[spIUPrestamoFondoAhorro]
                                    @IDPrestamoFondoAhorro	= 0
                                    ,@IDFondoAhorro			= @IDFondoAhorro
                                    ,@IDEmpleado			= @IDEmpleado
                                    ,@Monto					= @MontoPrestamo
                                    ,@IDPrestamo			= @IDPrestamo
                                    ,@IDUsuario				= @IDUsuario
                            end

                            UPDATE [Intranet].[tblSolicitudesPrestamos]
                                SET
                                    Cancelado		= null,
                                    FechaHoraAutorizacion	= getdate(),
                                    Autorizado				= 1,
                                    Descripcion= @Comentarios, 
                                    IDUsuarioAutorizo=@IDUsuario,
                                    Intereses= @Intereses,
                                    IDEstatusSolicitudPrestamo = @IDEstatusSolicitudPrestamo,
                                    IDEstatusPrestamo = @IDEstatusPrestamo,
                                    IDPrestamo= @IDPrestamo
                                WHERE IDSolicitudPrestamo = @IDSolicitudPrestamo

                        END
                    ELSE IF(@IDEstatusSolicitudPrestamo = 4)  -- NO AUTORIZADO
                        BEGIN
                            UPDATE [Intranet].[tblSolicitudesPrestamos]
                            SET
                                Cancelado  = null,                
                                Autorizado = 0,
                                FechaHoraCancelacion	= getdate(),
                                MotivoCancelacion=@Comentarios,
                                IDUsuarioCancelo=@IDUsuario,
                                IDEstatusSolicitudPrestamo = @IDEstatusSolicitudPrestamo
                            where IDSolicitudPrestamo = @IDSolicitudPrestamo        
                        END       

                    EXEC [App].[spINotificacioSolicitudPrestamoIntranet] @IDSolicitudPrestamo
                END
                
        COMMIT TRAN TransAutorizarDeclinarSolPrest
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransAutorizarDeclinarSolPrest
        EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '1700001'
    END CATCH	    	        
end
GO
