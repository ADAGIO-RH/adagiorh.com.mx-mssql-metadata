USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de crear un tablero junto con sus configuraciones necesarios para hacer funcionar el 'Dashboard de Tareas'.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @Titulo 
        Titulo del tablero.
    @Descripción
        Es una descripción breve acerca del tablero.
    @IDsUsuarios
        Son los `IDUsuarios` concatenados por ','.
    @dtEstatusTareas   
        Son los estatus tareas iniciales que tendra el tablero. Se relaciona con la tabla `Tareas.tblCatEstatusTareas`
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/

CREATE proc [Tareas].[spIUTablero](    
    @IDTablero int=0,
	@Titulo varchar(100),
    @IDsUsuarios varchar(max),   
    @Descripcion varchar(max),    
    @IDStyleBackground int,
    @dtEstatusTareas [Tareas].[dtCatEstatusTareas] readonly,
	@IDUsuario int
) as
begin
    
    DECLARE @TIPO_TABLERO_GENERAL INT
    SET @TIPO_TABLERO_GENERAL=1;
    
    set @IDsUsuarios= case when isnull(@IDsUsuarios,'')='' then cast(@IDUsuario as varchar(10)) else @IDsUsuarios+','+ cast(@IDUsuario as varchar(10)) END;

    IF( isnull(@IDTablero,0)=0)
    BEGIN
        INSERT INTO Tareas.tblTablero(Titulo,Descripcion,IDStyleBackground,IDUsuarioCreacion)
        values(@Titulo, @Descripcion,@IDStyleBackground,@IDUsuario)
        SET @IDTablero =SCOPE_IDENTITY()  
        
        SELECT [IDTablero], [Titulo], [Descripcion], [IDUsuarioCreacion], [FechaRegistro],t.IDStyleBackground,back.[Value] as Style FROM Tareas.tblTablero  t
        INNER JOIN Tareas.tblCatStylesBackground back on back.IDStyleBackground=t.IDStyleBackground
        WHERE IDTablero=@IDTablero

        IF( EXISTS(SELECT TOP 1 1 FROM @dtEstatusTareas))
        BEGIN        
            EXEC [Tareas].[spImportarEstatusTareas]
                @dtEstatusTareas =@dtEstatusTareas,         
                @IDReferencia=@IDTablero,   
                @IDUsuario =@IDUsuario
        END
        IF( ISNULL(@IDsUsuarios,'') <> '')
        begin 
            exec [Tareas].[spITableroUsuarios]
                @IDsUsuarios =@IDsUsuarios, 
                @IDTipoTablero=@TIPO_TABLERO_GENERAL,
                @IDReferencia =@IDTablero ,
                @IDUsuario =@IDUsuario 
        end     
        
    end ELSE
    BEGIN
        update Tareas.tblTablero set 
        IDStyleBackground=isnull(@IDStyleBackground,IDStyleBackground) ,
        Titulo=isnull(@Titulo,Titulo),
        Descripcion=isnull(@Descripcion,Descripcion)

        where IDTablero=@IDTablero;
        SELECT [IDTablero], [Titulo], [Descripcion], [IDUsuarioCreacion], [FechaRegistro],t.IDStyleBackground,back.[Value] as Style FROM Tareas.tblTablero  t
        INNER JOIN Tareas.tblCatStylesBackground back on back.IDStyleBackground=t.IDStyleBackground
        WHERE IDTablero=@IDTablero

        IF( ISNULL(@IDsUsuarios,'') <> '')
        begin 
            exec [Tareas].[spITableroUsuarios]
                @IDsUsuarios =@IDsUsuarios, 
                @IDTipoTablero=@TIPO_TABLERO_GENERAL,
                @IDReferencia =@IDTablero ,
                @IDUsuario =@IDUsuario 
        end     
    end    
end
GO
