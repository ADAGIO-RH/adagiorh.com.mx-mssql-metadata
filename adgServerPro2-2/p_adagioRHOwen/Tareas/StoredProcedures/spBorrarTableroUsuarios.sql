USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de eliminar el acceso al 'tablero'
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        @IDTipoTablero hace se relaciona con '[Tareas].[tblCatTipoTablero]'         
    @IDsUsuarios
        Son los IDUsuarios concatenados por ','. 
        Ej. 
        Para eliminar los usuarios 1 y 2. El valor a enviar es `1,2`  
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/

CREATE proc [Tareas].[spBorrarTableroUsuarios](
	@IDsUsuarios varchar(max),    
    @IDTipoTablero int ,
    @IDReferencia int ,
	@IDUsuario int
) as
BEGIN

    declare @tempUsuarios as table(
        IDUsuario int 
    )

    INSERT INTO @tempUsuarios
    SELECT [value] FROM string_split(@IDsUsuarios,',')

    DELETE from Tareas.tblTableroUsuarios where IDUsuario in (select IDUsuario from @tempUsuarios) and  IDTipoTablero=@IDTipoTablero AND IDReferencia=@IDReferencia
END
GO
