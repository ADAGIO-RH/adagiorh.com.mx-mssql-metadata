USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de clonar un 'estatu tarea' junto con todas sus depedencias como tareas.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDEstatusTarea
        IDEstatusTarea que se va a clonar.
    @IDUsuario
        IDUsuario que ejecuto la acción
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spClonarEstatusTareas](    
    @IDEstatusTarea int ,     	
    @IDUsuario int
) as
begin    
        
    declare @TblTareasClonadas as table(
        IDTarea  int ,
        Titulo varchar(100),
        Descripcion varchar(max),
        FechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP ,
        IDUsuarioCreacion int,
        IDTipoTablero int , 
        IDReferencia int ,
        IDEstatusTarea int ,    
        FechaInicio date,
        FechaFin date,
        IDPrioridad int ,     
        IDUsuariosAsignados varchar(max) ,
        Orden int
    )
    

    declare @ordenNuevoEstatus int 
    DECLARE @IDReferencia int 
    DECLARE @IDTipoTablero int 
    

    declare @IDEstatusTareaClonado int 

    select @ordenNuevoEstatus= Orden+1 ,
        @IDReferencia=IDReferencia,
        @IDTipoTablero=IDTipoTablero
    from Tareas.tblCatEstatusTareas 
    where IDEstatusTarea=@IDEstatusTarea

    

    UPDATE Tareas.tblCatEstatusTareas 
    SET Orden=Orden+1 
    WHERE 
        (IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia)
    AND 
    
    Orden>=@ordenNuevoEstatus

    INSERT INTO Tareas.tblCatEstatusTareas ([IDTipoTablero],[IDReferencia], [Icon], [Titulo], [Descripcion], [Orden])
    select @IDTipoTablero,@IDReferencia, [Icon],concat([Titulo],' -COPY'),[Descripcion],@ordenNuevoEstatus FROM Tareas.tblCatEstatusTareas WHERE IDEstatusTarea=@IDEstatusTarea
    set @IDEstatusTareaClonado=@@IDENTITY
        

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
        [Orden]             
        )
    SELECT 
        [Titulo],
        [Descripcion],
        [FechaRegistro],
        @IDUsuario,
        [IDTipoTablero],
        [IDReferencia],
        @IDEstatusTareaClonado,
        [FechaInicio],
        [FechaFin],
        [IDPrioridad],
        [IDUsuariosAsignados],
        [TotalCheckListActivos],
        [TotalCheckListNoActivos],
        CheckListJson,
        [TotalAdjuntos],        
        [Orden]
    FROM Tareas.tblTareas
    WHERE 
        IDReferencia=@IDReferencia     
        and IDTipoTablero=@IDTipoTablero 
        and IDEstatusTarea=@IDEstatusTarea  
        and Archivado=0

    

    -- RETORNA 2 TABLAS LA PRIMERA PARA EL ESTATUS Y LA SEGUNDA PARA LAS TAREAS
    EXEC [Tareas].[spBuscarEstatusTareas]    	        
        @IDEstatusTarea  =@IDEstatusTareaClonado,
        @IDTipoTablero=@IDTipoTablero ,
        @IDReferencia =@IDReferencia ,
	    @IDUsuario =@IDUsuario

    EXEC [Tareas].[spBuscarTareasMin] 
        @IDUsuario=@IDUsuario,
        @IDTarea=null,
        @IDEstatusTarea  =@IDEstatusTareaClonado,
        @IDTipoTablero=@IDTipoTablero, 
        @IDReferencia =@IDReferencia
end
GO
