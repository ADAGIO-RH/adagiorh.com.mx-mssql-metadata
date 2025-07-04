USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de insertar o actualizar los `estatus tareas`.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    
    Sí @IDEstatusTarea es 0, se creará un nuevo `estatus tarea`. De lo contrario actualizará en el @IDEstatusTarea especificado.
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.

    Las variables @Titulo, @Descripción, @Icon, @IsEnd y @IsDefault no están directamente vinculadas a ninguna tabla de la base de datos; simplemente contienen información general relacionada con la tabla.
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spIUEstatusTareas](
	@IDEstatusTarea  int  ,
    @IDTipoTablero int ,
    @IDReferencia int ,
    @Icon varchar(20),
    @Titulo VARCHAR(100),
    @Descripcion varchar(max),
    @IsDefault bit,
    @IsEnd bit,
	@IDUsuario int
) as
begin

    if (ISNULL(@IDEstatusTarea, 0) = 0)
	begin
    
        declare @maxOrden int
        select @maxOrden=MAX(Orden)+1 from Tareas.tblCatEstatusTareas where IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia  
        set @maxOrden=ISNULL(@maxOrden,1)


        insert into Tareas.tblCatEstatusTareas ([IDTipoTablero],[IDReferencia],[Icon],[Titulo],[Descripcion],IsDefault,IsEnd,Orden)
        Values(@IDTipoTablero,@IDReferencia,@Icon,@Titulo,@Descripcion,@IsDefault,@IsEnd,@maxOrden)
        SET @IDEstatusTarea=@@IDENTITY

	end else
	begin
		UPDATE Tareas.tblCatEstatusTareas
        set 
            Titulo=@Titulo,
            Descripcion= @Descripcion , 
            Icon=@Icon,
            IsDefault=@IsDefault   
        where IDEstatusTarea=@IDEstatusTarea
	end
    EXEC [Tareas].[spBuscarEstatusTareas] @IDEstatusTarea= @IDEstatusTarea ,@IDUsuario=1   ,@IDTipoTablero=null,@IDReferencia=null 
end
GO
