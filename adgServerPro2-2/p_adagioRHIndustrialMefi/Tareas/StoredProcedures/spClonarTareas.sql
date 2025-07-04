USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de clonar una tarea en base al 'IDTarea'
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDTarea
        IDTarea que se va a clonar.        
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spClonarTareas](    
    @IDTarea int ,         
    @IDUsuario int
) as
begin    
    
    DECLARE @IDTareaClonada int
    DECLARE @IDTipoTablero INT 
    DECLARE @IDReferencia int 
    declare @IDEstatusTarea int
    DECLARE @Orden int 

    select 
        @IDTipoTablero=IDTipoTablero ,
        @IDReferencia=IDReferencia,
        @IDEstatusTarea=IDEstatusTarea,
        @Orden =Orden
    from Tareas.tblTareas
    where IDTarea =@IDTarea
    
    insert into Tareas.tblTareas (
        [Titulo],
        [Descripcion],
        [FechaRegistro],
        [IDUsuarioCreacion],
        [IDTipoTablero],
        [IDReferencia],
        [IDEstatusTarea],
        [FechaInicio],
        [FechaFin],
        [IDPrioridad],
        [IDUsuariosAsignados],
        [TotalCheckListActivos],
        [TotalCheckListNoActivos],
        CheckListJson,
        [TotalAdjuntos]        ,
        [Orden])
    SELECT 
        [Titulo],
        [Descripcion],
        [FechaRegistro],
        [IDUsuarioCreacion],
        [IDTipoTablero],
        [IDReferencia],
        [IDEstatusTarea],
        [FechaInicio],
        [FechaFin],
        [IDPrioridad],
        [IDUsuariosAsignados],
        [TotalCheckListActivos],
        [TotalCheckListNoActivos],
        CheckListJson,
        [TotalAdjuntos],        
        [Orden]
    From Tareas.tblTareas WHERE IDTarea=@IDTarea

    SET @IDTareaClonada=@@IDENTITY
    
    update TareaS.tblTareas set Orden=Orden+1   where IDTarea=@IDTareaClonada

    UPDATE TareaS.tblTareas set Orden=Orden + 1  
    where  IDTipoTablero=@IDTipoTablero
        AND IDReferencia=@IDReferencia
        and IDEstatusTarea=@IDEstatusTarea
        AND Orden>@Orden and IDTarea<> @IDTareaClonada

    
    

    EXEC [Tareas].[spBuscarTareasMin]
        @IDTarea =@IDTareaClonada ,
        @IDTipoTablero =null , 
        @IDReferencia =null ,
	    @IDUsuario =@IDUsuario

end
GO
