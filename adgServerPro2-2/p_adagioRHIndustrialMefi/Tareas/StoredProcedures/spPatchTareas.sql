USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de actualizar parcialmente la tarea.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDTarea 
        IDTarea que se modificara.    
    @StringColumnasAModificar 
        Esta variable sirve para identificar que propiedad se modificara, 
        si se necesita modificar mas de una columna, Estos tienen que enviarse concatenados por ','. 
        Ej.'Titulo,Descripción', Adicional a esto es necesario enviar @Descripcion y @Titulo.

        La siguiente lista son las columnas consideradas, junto con las variables necesarias a enviar dependiendo del valor de '@StringColumnasAModificar'
        * Titulo (@Titulo)
        * Descripcion (@Descripcion)
        * IDEstatusTarea (@IDEstatusTarea)
        * FechaInicio (@FechaInicio)
        * FechaFin (@FechaFin)
        * IDPrioridad (@IDPrioridad)
        * IDUsuariosAsignados (@IDUsuarioAsignado,@FlagAsignar)        

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spPatchTareas](    
    @IDTarea int ,     
	@Titulo varchar(100),
    @Descripcion varchar(max),        
    @IDEstatusTarea int , 
    @FechaInicio date , 
    @FechaFin date ,
    @IDPrioridad int ,
    @IDUsuarioAsignado int,
    @FlagAsignar bit,
    @CheckListJson VARCHAR(max),
    @TotalCheckListActivos int,
    @TotalCheckListNoActivos int,    
    @TotalAdjuntos int,
    @StringColumnasAModificar VARCHAR(max),    
    @Archivado bit ,
    @IDUsuario int
) as
begin    

    declare @columnasTareas as table (
        columna VARCHAR(20)
    );

    -- select 1/0;
    insert into @columnasTareas (columna)
    select value from string_split(@StringColumnasAModificar,',')

    IF( exists(select top 1 1 from @columnasTareas where columna='Titulo'))
    BEGIN
        update Tareas.tblTareas set Titulo=@Titulo WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='Archivado'))
    BEGIN
        update Tareas.tblTareas set Archivado=@Archivado WHERE IDTarea=@IDTarea
    end
    

    IF( exists(select top 1 1 from @columnasTareas where columna='Descripcion'))
    BEGIN
        update Tareas.tblTareas set Descripcion=@Descripcion WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='IDEstatusTarea'))
    BEGIN
        update Tareas.tblTareas set IDEstatusTarea=@IDEstatusTarea WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='FechaInicio'))
    BEGIN
        update Tareas.tblTareas set FechaInicio=@FechaInicio WHERE IDTarea=@IDTarea
    end
    IF( exists(select top 1 1 from @columnasTareas where columna='FechaFin'))
    BEGIN
        update Tareas.tblTareas set FechaFin=@FechaFin WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='IDPrioridad'))
    BEGIN
        update Tareas.tblTareas set IDPrioridad=@IDPrioridad WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='TotalAdjuntos'))
    BEGIN
        
        update Tareas.tblTareas set TotalAdjuntos=@TotalAdjuntos          
        WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='CheckListJson'))
    BEGIN
        
        update Tareas.tblTareas set TotalCheckListActivos=@TotalCheckListActivos ,
         TotalCheckListNoActivos=@TotalCheckListNoActivos ,
         CheckListJson=@CheckListJson
        WHERE IDTarea=@IDTarea
    end

    IF( exists(select top 1 1 from @columnasTareas where columna='IDUsuariosAsignados'))
    BEGIN
        DECLARE @cadena VARCHAR(MAX) ;
        SELECT @cadena= IDUsuariosAsignados from Tareas.tblTareas  t WHERE IDTarea=@IDTarea
                
        IF OBJECT_ID('tempdb..#TempTabla') IS NOT NULL DROP TABLE #TempTabla;

        CREATE TABLE #TempTabla (ID INT);
        
        INSERT INTO #TempTabla (ID)
        SELECT IDUsuario from openjson(@cadena) with( IDUsuario int '$.IDUsuario')

        IF @FlagAsignar = 1
        BEGIN
            IF( not exists(select top 1 1 from #TempTabla where ID = @IDUsuarioAsignado))
            begin
                insert into #TempTabla (ID) Values(@IDUsuarioAsignado)
            end
        END
        ELSE
        BEGIN
            DELETE FROM #TempTabla WHERE ID=@IDUsuarioAsignado
        END
        declare @newAsignados varchar(max)                                     
        set @newAsignados= (SELECT ID AS "IDUsuario" FROM #TempTabla FOR JSON PATH);                
        update tareas.tblTareas set IDUsuariosAsignados=@newAsignados where IDTarea=@IDTarea
    end

 
    EXEC [Tareas].[spBuscarTareas]
        @IDTarea =@IDTarea ,
        @IDTipoTablero =null , 
        @IDReferencia =null ,
	    @IDUsuario =@IDUsuario
end
GO
