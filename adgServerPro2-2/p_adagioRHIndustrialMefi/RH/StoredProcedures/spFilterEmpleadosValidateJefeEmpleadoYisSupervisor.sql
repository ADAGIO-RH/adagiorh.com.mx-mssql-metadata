USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: 
** Autor			: Jose VARGAS
** Email			: jvargas@adagiorh.com
** FechaCreacion	: 
** Paremetros		:              	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2023-01-25			JOSE ROMAN		CONDICION PARA QUE NO SALGA LA RELACION DE FILTRO SUPERVISOR CON 
									CON EL EMPLEADO DEL MISMO USUARIO.
***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleadosValidateJefeEmpleadoYisSupervisor](  
	@IDUsuario	int 	
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)as   
	
    set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDEmpleadoUsuario int  = 0
	;

	set @IDEmpleadoUsuario = ISNULL((select  IDEmpleado from Seguridad.tblUsuarios U where IDUsuario = @IDUsuario),0)
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	declare @ResponseEmpleados as table (
		[IDEmpleado] [int] NULL,
		[ClaveEmpleado] [varchar](20) NULL,				
		[Nombre] [varchar](50) NULL,
		[NOMBRECOMPLETO] [varchar](50) NULL,		
        [Iniciales] [varchar](5) NULL,	
		[Departamento] [varchar](50) NULL,		
		[Sucursal] [varchar](50) NULL,		
		[Puesto] [varchar](100) NULL,
		[TipoFiltro] [varchar](50) NULL,
		SolicitudesPendientes int NULL,
        DiasTomados int NULL,
		DiasDisponibles int NULL,
        DiasDisfrutar int NULL
	)

	declare @ResponseEmpleadosFinal as table (
		[IDEmpleado] [int] NULL,
		[ClaveEmpleado] [varchar](20) NULL,				
		[Nombre] [varchar](50) NULL,
		[NOMBRECOMPLETO] [varchar](50) NULL,		
        [Iniciales] [varchar](5) NULL,	
		[Departamento] [varchar](50) NULL,		
		[Sucursal] [varchar](50) NULL,		
		[Puesto] [varchar](100) NULL,
		[TipoFiltro] [varchar](50) NULL,
		SolicitudesPendientes int NULL,
        DiasTomados int default(0),
		DiasDisponibles int default(0),
        DiasDisfrutar int default(0),
		TotalPaginas int default(0),
		TotalRows int default(0)
	)



    
    insert into @ResponseEmpleados(
		[IDEmpleado],
		[ClaveEmpleado],				
		[Nombre],
		[NOMBRECOMPLETO] ,		
        [Iniciales] ,	
		[Departamento] ,		
		[Sucursal],		
		[Puesto] ,
		[TipoFiltro],
		[SolicitudesPendientes]
	)
	select  e.IDEmpleado
			,e.ClaveEmpleado			
			,e.Nombre			
			,e.NOMBRECOMPLETO			
			,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1)  as Iniciales
            ,e.Departamento
            ,e.Sucursal
            ,e.Puesto
            ,dt.Tipo [TipoFiltro]
            ,(
                select sum(total) from (
                    Select count(*)  as total
				        from Intranet.tblSolicitudesEmpleado 
				    where IDEmpleado = e.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
                    union 
                    Select count(*) as total
				        from Intranet.tblSolicitudesPrestamos 
				    where IDEmpleado = e.IDEmpleado and IDEstatusSolicitudPrestamo = 1 -- PENDIENTES
                ) as tblTotalSolicitudes                                
			) as SolicitudesPendientes	
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Utilerias.fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados(@IDUsuario) dt on dt.IDEmpleado=e.IDEmpleado -- and dt.Tipo<>'Propio'
        
	where 
        e.Vigente=1
        and (@query = '""' or CONTAINS(e.*, @query)) 		
	order by e.ClaveEmpleado asc


    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @ResponseEmpleados

	select @TotalRegistros = cast(COUNT([IDEmpleado]) as int) from @ResponseEmpleados		

	insert into @ResponseEmpleadosFinal
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
    ,TotalRows = @TotalRegistros
	from @ResponseEmpleados
	WHERE 1 = CASE WHEN IDEmpleado in (@IDEmpleadoUsuario) and [TipoFiltro] in('Filtro-Supervisor','Filter-Supervisor') THEN 0
				ELSE 1 END
	order by 
		case when @orderByColumn = 'ClaveEmpleado'		and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'		and @orderDirection = 'desc'	then ClaveEmpleado end desc,			
		case when @orderByColumn = 'NombreCompleto'		and @orderDirection = 'asc'		then NombreCompleto end,			
		case when @orderByColumn = 'NombreCompleto'		and @orderDirection = 'desc'	then NombreCompleto end desc,			
		case when @orderByColumn = 'Departamento'		and @orderDirection = 'asc'		then Departamento end,		
		case when @orderByColumn = 'Departamento'		and @orderDirection = 'desc'	then Departamento end desc,		
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'asc'		then Sucursal end,				
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'desc'	then Sucursal end desc,				
		case when @orderByColumn = 'Puesto'				and @orderDirection = 'asc'		then Puesto end,					
		case when @orderByColumn = 'Puesto'				and @orderDirection = 'desc'	then Puesto end desc,							
        case when @orderByColumn = 'SolicitudesPendientes'				and @orderDirection = 'asc'		then SolicitudesPendientes end,					
		case when @orderByColumn = 'SolicitudesPendientes'				and @orderDirection = 'desc'	then SolicitudesPendientes end desc,							
        case when @orderByColumn = 'TipoFiltro'				and @orderDirection = 'asc'		then TipoFiltro end,					
		case when @orderByColumn = 'TipoFiltro'				and @orderDirection = 'desc'	then TipoFiltro end desc,							
        
		ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	
    DECLARE @TableSaldos as Table(
		IDEmpleado int,
		Anio int,	
		DiasTomados 	decimal(18,2),
		DiasDisponibles decimal(18,2),
        DiasDisfrutar 	decimal(18,2)
	)


   
    Declare @IDEmpleado INT
    ,@tempDiasVacacionesRep [Asistencia].[dtSaldosDeVacaciones]
    ,@SumDiasDisponibles int
    ,@DiasDisfrutar int 


    Select @IDEmpleado = (Select MIN(IDEmpleado) from @ResponseEmpleadosFinal)

    WHILE(@IDEmpleado <= (Select MAX(IDEmpleado) from @ResponseEmpleadosFinal))
    BEGIN
    BEGIN TRY
			insert @tempDiasVacacionesRep
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado,@Proporcional = null, @FechaBaja = null, @IDUsuario = @IDUsuario
		END TRY
		BEGIN CATCH
			print ERROR_MESSAGE() 
			INSERT INTO @TableSaldos(IDEmpleado)
			SELECT @IDEmpleado
		END CATCH

        Select @SumDiasDisponibles = SUM(DiasDisponibles) from @tempDiasVacacionesRep

        Select @DiasDisfrutar = COUNT(*) from Asistencia.tblIncidenciaEmpleado where IDEmpleado = @IDEmpleado AND IDIncidencia = 'V' AND Fecha >= GETDATE()

        

		INSERT INTO @TableSaldos
	    Select top 1 @IDEmpleado,anio,DiasTomados,@SumDiasDisponibles,@DiasDisfrutar 
		FROM @tempDiasVacacionesRep

		Delete @tempDiasVacacionesRep

		SELECT @IDEmpleado = min(IDEmpleado) from @ResponseEmpleadosFinal where IDEmpleado > @IDEmpleado
    END

	update f
		set 
		f.DiasTomados  = isnull(s.DiasTomados,0) 
		,f.DiasDisponibles = isnull(s.DiasDisponibles,0)
		,f.DiasDisfrutar  = isnull(s.DiasDisfrutar,0)
	from @ResponseEmpleadosFinal F
		left join @TableSaldos s
			on f.IDEmpleado = s.IDEmpleado

	select * from @ResponseEmpleadosFinal
GO
