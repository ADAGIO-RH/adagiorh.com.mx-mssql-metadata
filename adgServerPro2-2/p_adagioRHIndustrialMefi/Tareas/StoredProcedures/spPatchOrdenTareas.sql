USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de actualizar el orden de una tarea. Esto se utiliza en el 'dashboard de tareas' cuando una tarea se ha movido.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    @IDTarea - 
        IDTarea de la tarea que se ha movido.
    @NuevoOrden
        Este es el orden asignado a la tarea.
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        @IDTipoTablero hace se relaciona con '[Tareas].[tblCatTipoTablero]'         
    @IDNuevoEstatusTarea
        Es el IDEstatusTarea, se relaciona con la tabla `tareas.tblCatEstatusTareas`
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/

CREATE proc [Tareas].[spPatchOrdenTareas](    
    @IDTarea int ,    
    @NuevoOrden int,
    @IDReferencia int ,
    @IDTipoTablero int,
    @IDNuevoEstatusTarea int ,
    @IDUsuario int
) as
begin    
            
    
    declare @IDActualEstatusTarea int 
    declare @OrdenActual int 

    DECLARE @TablaTemporal TABLE (IDTarea INT, Orden INT);
    
                
    SELECT @OrdenActual=orden,@IDActualEstatusTarea=IDEstatusTarea from Tareas.tblTareas where IDTarea=@IDTarea

    
    UPDATE Tareas.tblTareas 
    SET Orden = Orden - 1 
    OUTPUT inserted.IDTarea, inserted.Orden INTO @TablaTemporal
    WHERE IDReferencia = @IDReferencia 
        AND IDTipoTablero = @IDTipoTablero 
        AND IDEstatusTarea = @IDActualEstatusTarea 
        AND Orden > @OrdenActual;

    UPDATE Tareas.tblTareas 
    SET Orden = Orden + 1 
    OUTPUT inserted.IDTarea, inserted.Orden INTO @TablaTemporal
    WHERE IDReferencia = @IDReferencia 
        AND IDTipoTablero = @IDTipoTablero 
        AND IDEstatusTarea = @IDNuevoEstatusTarea 
        AND Orden >= @NuevoOrden 
        AND IDTarea <> @IDTarea;

    UPDATE Tareas.tblTareas 
    SET Orden = @NuevoOrden,
        IDEstatusTarea = @IDNuevoEstatusTarea 
    -- OUTPUT inserted.IDEstatusTarea, inserted.Orden INTO @TablaTemporal
    WHERE IDTarea = @IDTarea;


    DECLARE @ID_TIPO_TABLERO_ONBOARDING INT
    set @ID_TIPO_TABLERO_ONBOARDING=3;

    if( @IDTipoTablero = @ID_TIPO_TABLERO_ONBOARDING)
    begin
        DECLARE @IDEstatusTareaTerminado INT

        DECLARE @TotalTareas INT
        DECLARE @TotalTareasTerminadas INT
        SELECT @IDEstatusTareaTerminado = IDEstatusTarea from tareas.tblCatEstatusTareas WHERE IDTipoTablero=@IDTipoTablero and IDReferencia=0 and IsEnd=1 
        
        select @TotalTareas=count(*) from Tareas.tblTareas WHERE IDTipoTablero =@IDTipoTablero AND IDReferencia=@IDReferencia 
        select @TotalTareasTerminadas=count(*) from Tareas.tblTareas WHERE IDTipoTablero =@IDTipoTablero AND IDReferencia=@IDReferencia  AND IDEstatusTarea=@IDEstatusTareaTerminado

        IF(@TotalTareas=@TotalTareasTerminadas)
        BEGIN
            UPDATE Onboarding.tblProcesosOnboarding SET Terminado=1 where IDProcesoOnboarding=@IDReferencia
        END
        ELSE 
        BEGIN
            UPDATE Onboarding.tblProcesosOnboarding SET Terminado=0 where IDProcesoOnboarding=@IDReferencia
        END



    end
    SELECT IDTarea,Orden FROM @TablaTemporal;
end
GO
