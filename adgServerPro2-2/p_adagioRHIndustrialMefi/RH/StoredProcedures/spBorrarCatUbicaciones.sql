USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatUbicaciones] --@IDUbicacion=13, @IDUsuario=1
(
      @IDUbicacion int 
	  ,@ConfirmarEliminar bit=0
    ,@IDUsuario int 
)


as 
DECLARE	
	@TotalUbicaciones int
	;
begin TRY

if((select count(*)from [RH].[tblUbicacionesEmpleados] WHERE IDUbicacion =@IDUbicacion)>0 AND @ConfirmarEliminar=0)
    begin	
	select @TotalUbicaciones =count(*)from [RH].[tblUbicacionesEmpleados] WHERE IDUbicacion =@IDUbicacion
	
	 select 
            'Esta ubicacion tiene '+cast(@TotalUbicaciones as varchar)+ 
                CASE WHEN @TotalUbicaciones=1 THEN ' empleado la ubicacion será eliminada ¿Desea continuar?'
                     ELSE ' empleados la ubicacion será eliminada ¿Desea continuar?' END AS Mensaje
            ,1 as TipoRespuesta
            RETURN
	end
	ELSE
	BEGIN
    DELETE [RH].[tblCatUbicaciones] 
	    WHERE IDUbicacion = @IDUbicacion
		SELECT 'Objetivo eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
            RETURN;
		END
   END TRY  
    BEGIN CATCH  
         SELECT 'Ocurrio un error no controlado' as Mensaje
                   ,-1 as TipoRespuesta
    END CATCH ;
GO
