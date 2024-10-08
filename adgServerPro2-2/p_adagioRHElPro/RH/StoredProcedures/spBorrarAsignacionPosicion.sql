USE [p_adagioRHElPro]
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
	declare  
		@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE INT = 2,
		@IDPlaza int
    ;

	select @IDPlaza = IDPlaza
	from RH.tblCatPosiciones
    where IDPosicion = @IDPosicion

    BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion
            update RH.tblCatPosiciones 
                set
                    IDEmpleado = null
            where IDPosicion = @IDPosicion
				
            insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
            select @IDPosicion,@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario,null

            EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario

            -- Actualizar relación jefes empleados de los subordinados

          exec [RH].[spActualizarJefesEmpleadosSubordinados] @IDPosicion=@IDPosicion;



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
