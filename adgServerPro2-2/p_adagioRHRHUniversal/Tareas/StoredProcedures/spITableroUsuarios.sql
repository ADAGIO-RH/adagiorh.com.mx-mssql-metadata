USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de asignar los usuarios algún tablero.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        @IDTipoTablero hace se relaciona con '[Tareas].[tblCatTipoTablero]'         
    @IDsUsuario
        Son los IDUsuario, que se asignaran al tablero. Debe tener el siguiente formato.
        `[{"IDUsuario":?},{"IDUsuario":?},...]`
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spITableroUsuarios](
    @IDTipoTablero int ,
    @IDReferencia int ,
    @IDsUsuarios varchar(max),
    @IDUsuario int
)
as
begin

    declare @tempUsuarios as table(
        IDUsuario int ,
        ClaveEmpleado varchar(100),
        NombreCompleto VARCHAR(150),
        UrlFoto varchar(150),
        Activo bit 
    )

    INSERT INTO @tempUsuarios
    SELECT u.IDUsuario, ISNULL(M.ClaveEmpleado,'N/A') ,
        case when m.IDEmpleado IS not null 
                then  concat(m.Nombre, ' ', isnull(concat(SegundoNombre,' '),''),isnull(concat(Materno,' '),'') ,isnull(concat(Paterno,''),'')) 
                else concat(u.Nombre ,' ', u.Apellido) end ,
        case when fe.IDEmpleado is not null 
                then CONCAT('/Empleados/',m.ClaveEmpleado,'.jpg') 
                when fu.IDUsuario is not null 
                then CONCAT('/Usuarios/',fu.IDUsuario,'.jpg') 
                else
                    'Fotos/nofoto.jpg'
                end 
        as UrlFoto,
        case when tr.IDUsuario is null then 0 else 1 end as Activo
    FROM (  
             SELECT Value as IDUsuario
        FROM OpenJson(@IDsUsuarios)  with( Value int '$.IDUsuario' )    
    ) as ut
        INNER JOIN [Seguridad].[tblUsuarios] u on ut.IDUsuario= u.IDUsuario
        LEFT JOIN Tareas.tblTableroSignalR tr on tr.IDTipoTablero=@IDTipoTablero AND TR.IDReferencia=@IDReferencia and tr.IDUsuario=u.IDUsuario
        LEFT JOIN RH.tblEmpleadosMaster m on m.IDEmpleado = u.IDEmpleado
        LEFT JOIN [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado=u.IDEmpleado
        LEFT JOIN [Seguridad].[tblFotoUsuarios] fu with (nolock) on fu.IDUsuario=u.IDUsuario

    INSERT INTO [Tareas].[tblTableroUsuarios]
        (IDTipoTablero,IDReferencia,IDUsuario)
    SELECT @IDTipoTablero, @IDReferencia, IDUsuario
    from @tempUsuarios

    SELECT [IDUsuario],
        [ClaveEmpleado],
        [NombreCompleto],
        [UrlFoto],
        [Activo]
    FROM @tempUsuarios

end
GO
