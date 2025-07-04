USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga buscar la información de la tarea.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:           
    Este sp puede realizar busqueda por los siguientes filtros:
        * @IDEstatusTarea (Tareas.tblCatEstatusTareas)
        * @IDTarea
        * @IDReferencia y @IDTipoTablero (Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.)
        * @IDPrioridad 
            por defecto el valor es -1 para obtener todos.

            
    @IDUsuario
    Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarTareas] (    	
    @IDTarea int ,
    @IDTipoTablero int , 
    @IDReferencia int ,
    @IDEstatusTarea int=-1,
    @IDPrioridad int=-1,
    @Archivado bit =0,
	@IDUsuario int,
    @PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'Orden',
	@orderDirection varchar(4) = 'asc'
) as
begin

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


    

    IF OBJECT_ID('tempdb..#TempTareas') IS NOT NULL DROP TABLE #TempTareas

    select [IDTarea],
            [Titulo],
            ttm.[Descripcion],
            [FechaRegistro],
            [IDUsuarioCreacion],
            [IDTipoTablero],
            [IDReferencia],
            [IDEstatusTarea],
            [FEchaInicio],
            [FechaFin],
            ttm.[IDPrioridad] ,
            isnull(p.Descripcion,0) as Prioridad , 
            Orden,
            isnull(Archivado,0) as Archivado,
            isnull(CheckListJson,'[]') as CheckListJson,
            isnull(TotalCheckListActivos,0) as TotalCheckListActivos,
            isnull(TotalCheckListNoActivos,0) as TotalCheckListNoActivos,
            isnull(TotalAdjuntos,0) as TotalAdjuntos,
            IDUnidadDeTiempo  as  IDUnidadDeTiempo,
            ValorUnidadTIempo as ValorUnidadDeTiempo,
            isnull(
            (
                select  uu.IDUsuario,uu.ClaveEmpleado,uu.NombreCompleto ,
                        uu.Nombre,uu.Apellido ,uu.Cuenta,UrlFoto
                from (
                    Select 
                        u.IDUsuario, 
                        ISNULL(M.ClaveEmpleado,'N/A') as ClaveEmpleado, 
                        case when m.IDEmpleado IS not null 
                            then  concat(m.Nombre, ' ', isnull(concat(SegundoNombre,' '),''),isnull(concat(Materno,' '),'') ,isnull(concat(Paterno,''),'')) 
                            else concat(u.Nombre ,' ', u.Apellido) end as NombreCompleto,
                        case when fe.IDEmpleado is not null 
                            then CONCAT('/Empleados/',m.ClaveEmpleado,'.jpg') 
                            when fu.IDUsuario is not null 
                            then CONCAT('/Usuarios/',fu.IDUsuario,'.jpg') 
                            else
                                'Fotos/nofoto.jpg'
                            end 
                    as UrlFoto,
                        u.Nombre,u.Apellido ,u.Cuenta
                    From 
                    (
                        SELECT Value as IDUsuario FROM OpenJson(IDUsuariosAsignados)    
                        with(
                            Value int '$.IDUsuario'
                        )    
                    ) as listaUsuariosEnTareas
                    INNER JOIN Seguridad.tblUsuarios u on u.IDUsuario=listaUsuariosEnTareas.IDUsuario                    
                    LEFT JOIN RH.tblEmpleadosMaster m on m.IDEmpleado = u.IDEmpleado                
                    left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado=u.IDEmpleado
                    left join [Seguridad].[tblFotoUsuarios] fu with (nolock) on fu.IDUsuario=u.IDUsuario
                )  uu
                for json auto
            ),'[]') AS usuariosAsignadosJson,
            isnull(TotalComentarios,0)  as TotalComentarios              

        into #TempTareas
    From Tareas.tblTareas  ttm
    left join tareas.tblCatPrioridad p on p.IDPrioridad=ttm.IDPrioridad
    WHERE 
        (IDTarea=@IDTarea )  or 
        (
            (   
                (IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia )  
                AND 
                @IDEstatusTarea=-1 or IDEstatusTarea=@IDEstatusTarea 
                AND 
                ( @IDPrioridad=-1 or isnull(ttm.IDPrioridad,0)=isnull(@IDPrioridad,0))
            )         
            -- and 
            -- ( Archivado=@Archivado )
        )
        ORDER BY Orden     



    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempTareas

	select @TotalRegistros = cast(COUNT([IDTarea]) as decimal(18,2)) from #TempTareas		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempTareas
	order by 
		
		Orden 
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end
GO
