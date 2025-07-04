USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spIUProcesoOnboarding](
    @IDProcesoOnboarding int,
    @NombreProceso varchar(255),
    @IDEmpleadoNuevo int,
    -- @IDPlaza int,
    -- @IDArea int,
    --@FechaInicio date,
    @IDsPlantilla varchar(max),
    @IDEmpleadoEncargado int,
    @IDUsuario int ,
    @Terminado bit    

)
AS BEGIN
    IF(ISNULL(@IDProcesoOnboarding,0)=0)
        BEGIN
            INSERT INTO Onboarding.tblProcesosOnboarding(
         
                    NombreProceso,
                    IDNuevoEmpleado,
                    -- IDPlaza,
                    -- IDArea,
                    --FechaInicio,
                    IDsPlantilla,
                    IDEmpleadoEncargado,
                    Terminado
                )
                values (
                      
                        @NombreProceso,
                        @IDEmpleadoNuevo,
                        -- @IDPlaza,
                        -- @IDArea,
                       -- @FechaInicio,
                        @IDsPlantilla,
                        @IDEmpleadoEncargado,
                        @Terminado

                )
                   set @IDProcesoOnboarding=@@IDENTITY
    END ELSE
        BEGIN
            UPDATE Onboarding.tblProcesosOnboarding
            SET                   
                    --NombreProceso= @NombreProceso,
                    IDNuevoEmpleado=@IDEmpleadoNuevo,
                    -- IDPlaza=@IDPlaza,
                    -- IDArea=@IDArea,
                   -- FechaInicio=@FechaInicio,
                    --IDsPlantilla=@IDsPlantilla,
                    IDEmpleadoEncargado=@IDEmpleadoEncargado,
                    Terminado= @Terminado
            WHERE IDProcesoOnboarding =@IDProcesoOnboarding
        END        

  EXEC [Onboarding].[spBuscarProcesosOnboarding]  @IDProcesoOnboarding= @IDProcesoOnboarding, @IDUsuario=@IDUsuario
END
GO
