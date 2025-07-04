USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de obtener los miembros que tienen permitido ver el tablero.     
    También especifíca si el usuario se encuentra activo en el tablero.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        @IDTipoTablero hace se relaciona con '[Tareas].[tblCatTipoTablero]'         
    @IDTarea 
        Si este recibe el 'IDTarea', en la columna `AsignadoAlaTarea` especificara si esta asignado a la tarea o no.
    @Search
        Este parametro es para realizar una busqueda entre los miembros del tablero o de la tarea.
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarMiembrosTablero](    	    
    @IDTipoTablero int,
    @IDReferencia int,
    @IDTarea int ,
    @Search VARCHAR(max),
	@IDUsuario int
) as
begin

    DECLARE @tblUsuarios as table ( 
        IDUsuario int , 
        ClaveEmpleado varchar(100),
        NombreCompleto VARCHAR(150),    
        AsignadoAlaTarea bit ,
        UrlFoto varchar(255),
        Activo bit 
    )

    INSERT INTO @tblUsuarios      
    SELECT u.IDUsuario,ISNULL(M.ClaveEmpleado,'N/A') ,
            case when m.IDEmpleado IS not null 
                -- then  concat(m.Nombre, ' ', isnull(concat(SegundoNombre,' '),''),isnull(concat(Materno,' '),'') ,isnull(concat(Paterno,''),'')) 
                THEN concat(u.Nombre ,' ', u.Apellido)
                else concat(u.Nombre ,' ', u.Apellido) end ,0,
            case when fe.IDEmpleado is not null 
                then CONCAT('Fotos/Empleados/',m.ClaveEmpleado,'.jpg') 
                when fu.IDUsuario is not null 
                then CONCAT('Fotos/Usuarios/',fu.IDUsuario,'.jpg') 
                else
                    'Fotos/nofoto.jpg'
                end 
        as UrlFoto,
        case when tr.IDUsuario is null then 0 else 1 end as Activo
    FROM  Tareas.tblTableroUsuarios ut
    INNER JOIN [Seguridad].[tblUsuarios] u on ut.IDUsuario= u.IDUsuario    
    left join Tareas.tblTableroSignalR tr on tr.IDTipoTablero=@IDTipoTablero AND TR.IDReferencia=@IDReferencia and tr.IDUsuario=u.IDUsuario
    LEFT JOIN RH.tblEmpleadosMaster m on m.IDEmpleado = u.IDEmpleado    
    left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado=u.IDEmpleado
    left join [Seguridad].[tblFotoUsuarios] fu with (nolock) on fu.IDUsuario=u.IDUsuario
    WHERE ut.IDTipoTablero=@IDTipoTablero and ut.IDReferencia =@IDReferencia

    IF( isnull(@IDTarea,0) >0)
    BEGIN
       DECLARE @cadenaIDSUsuariosAsignador varchar(max);      
        select @cadenaIDSUsuariosAsignador = IDUsuariosAsignados                 
        FROM Tareas.tblTareas where IDTarea=@IDTarea                    

        UPDATE tt 
        set tt.AsignadoAlaTarea=1
        from @tblUsuarios tt 
        INNER JOIN (  
             SELECT Value as IDUsuario FROM OpenJson(@cadenaIDSUsuariosAsignador)  with( Value int '$.IDUsuario' )    
        ) as usuariosTarea on usuariosTarea.IDUsuario=tt.IDUsuario
    END
                     
    SELECT 
        DISTINCT
        [IDUsuario],
        [ClaveEmpleado],
        [NombreCompleto],
        [AsignadoAlaTarea],
        [UrlFoto],
        [Activo] 
    FROM @tblUsuarios

end
GO
