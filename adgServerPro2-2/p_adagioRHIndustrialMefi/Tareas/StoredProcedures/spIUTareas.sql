USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de insertar o actualizar tareas.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDTarea
        Sí `IDTarea` es 0, se creará una tarea nueva. De lo contrario actualizará en el IDTarea especificado.
    
    @UsuariosAsignadosJson 
        Son los IDUsuario, que se asignaron a la tarea. El formato es el siguiente:
        `[{"IDUsuario":?},{"IDUsuario":?},...]`
    @IDPrioridad
        Se relaciona con la tabla de `Tareas.tblCatPrioridad`.
    @IDEstatusTarea
        Se relaciona con la tabla de `Tareas.tblCatEstatusTareas`.
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.


    Las variables @Titulo, @Descripción, @FechaInicio y @FechaFin no están directamente vinculadas a ninguna tabla de la base de datos; simplemente contienen información general relacionada con la tabla.


** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/


CREATE proc [Tareas].[spIUTareas](    
    @IDTarea int ,     
	@Titulo varchar(100),
    @Descripcion varchar(max),    
    @IDTipoTablero  int ,
    @IDReferencia int,
    @IDEstatusTarea int , 
    @FechaInicio date , 
    @FechaFin date ,
    @IDPrioridad int ,
    @TotalCheckListActivos int,
    @TotalCheckListNoActivos int,
    @TotalAdjuntos int,
    @UsuariosAsignadosJson VARCHAR(max) =null,
    @IDUnidadDeTiempo int , 
    @ValorUnidadDeTiempo int,
    @CheckListJson varchar(max),    
    @IDUsuario int
) as
begin    
    
    declare @IDsForInsertUsuarios varchar(max)
    if @UsuariosAsignadosJson IS NULL
    BEGIN
        SET @IDsForInsertUsuarios=CONCAT('[ { "IDUsuario":',@IDUsuario,'}]');
    end ELSE
    BEGIN
        SET @IDsForInsertUsuarios=@UsuariosAsignadosJson;
    end

    SET @CheckListJson= case when isnull(@CheckListJson,'')=''  then '[]' else @CheckListJson end;

	if (ISNULL(@IDTarea, 0) = 0)
	begin
        
        declare @lastOrden int
        if (@IDEstatusTarea is null )
        begin
            select  @lastOrden =max(Orden)+1 from Tareas.tblTareas  where IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia 
            SET @lastOrden= ISNULL(@lastOrden,1)
        end  else 
        BEGIN
            select  @lastOrden =max(Orden)+1 from Tareas.tblTareas  where IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia and IDEstatusTarea=@IDEstatusTarea
            SET @lastOrden= ISNULL(@lastOrden,1)
        end         

        IF(@IDUnidadDeTiempo IS NOT NULl)
        begin 
            declare @tiempoSegundos int 
            select @tiempoSegundos= TiempoEnSegundos from app.tblCatUnidadesDeTiempo where IDUnidadDeTiempo=@IDUnidadDeTiempo

            SET @FechaInicio=getdate()
            SET @FechaFin= DATEADD(SECOND, (@tiempoSegundos*@ValorUnidadDeTiempo), GETDATE())
            
        end
        insert into Tareas.tblTareas (Titulo,Descripcion,FechaRegistro,IDUsuarioCreacion,IDTipoTablero,IDReferencia,IDEstatusTarea,FechaInicio,FechaFin,IDPrioridad,IDUsuariosAsignados,Orden,IDUnidadDeTiempo,ValorUnidadTIempo,CheckListJson,TotalCheckListActivos,TotalCheckListNoActivos,TotalAdjuntos)
        Values(@Titulo,@Descripcion,getdate(),@IDUsuario,@IDTipoTablero,@IDReferencia,@IDEstatusTarea,@FechaInicio,@FechaFin,@IDPrioridad,@IDsForInsertUsuarios,(@lastOrden),@IDUnidadDeTiempo,@ValorUnidadDeTiempo,@CheckListJson,@TotalCheckListActivos,@TotalCheckListNoActivos,@TotalAdjuntos)
        
        SET @IDTarea=@@IDENTITY

	end else
	begin
		UPDATE Tareas.tblTareas 
        set 
            Titulo=@Titulo ,
            Descripcion= @Descripcion , 
            IDEstatusTarea=@IDEstatusTarea , 
            FechaInicio=@FechaInicio,
            FechaFin=@FechaFin,
            IDPrioridad =@IDPrioridad ,            
            IDUsuariosAsignados = CASE WHEN @UsuariosAsignadosJson IS NULL THEN IDUsuariosAsignados ELSE @UsuariosAsignadosJson END,
            IDUnidadDeTiempo=@IDUnidadDeTiempo,
            ValorUnidadTIempo=@ValorUnidadDeTiempo,
            CheckListJson=@CheckListJson
        where IDTarea=@IDTarea
	end

    EXEC [Tareas].[spBuscarTareas]
        @IDTarea =@IDTarea ,
        @IDTipoTablero =null , 
        @IDReferencia =null ,
	    @IDUsuario =@IDUsuario

    
end
GO
