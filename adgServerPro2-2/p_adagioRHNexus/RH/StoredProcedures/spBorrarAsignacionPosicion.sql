USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	 SP PARA DESASIGNAR AL EMPLEADO DE LA POSISICON
-- =============================================
CREATE PROCEDURE [RH].[spBorrarAsignacionPosicion]
    @IDUsuario int,
    @IDPosicion int     
AS
BEGIN
    BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion

			declare  @IDEstatusOcupado INT
            set @IDEstatusOcupado= 2;

            update RH.tblCatPosiciones 
                set
                    IDEmpleado = null
            where IDPosicion = @IDPosicion
				
            insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
            select @IDPosicion,@IDEstatusOcupado,@IDUsuario,null

            EXEC [RH].[spActualizarTotalesPosiciones] @IDPosicion, @IDUsuario
			  

			COMMIT TRANSACTION AsignarColaboradorAPosicion
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @MESSAGE VARCHAR(max) =  ERROR_MESSAGE(),
			@SEVERITY VARCHAR(max) =  ERROR_SEVERITY(),
			@STATE VARCHAR(max) =  ERROR_STATE();			
		RAISERROR(  
			@MESSAGE
			,@SEVERITY
			,@STATE );
        
	END CATCH;

END
GO
