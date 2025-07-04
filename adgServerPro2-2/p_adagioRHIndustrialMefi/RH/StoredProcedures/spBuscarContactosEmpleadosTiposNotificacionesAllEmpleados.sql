USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RH].[spBuscarContactosEmpleadosTiposNotificacionesAllEmpleados](
    @IDTipoNotificacion	varchar(50) = null
    ,@IDCliente int = null 
    ,@IDUsuario int
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Cuenta'
	,@orderDirection varchar(4) = 'asc'
) as

	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@IDIdioma varchar(20)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = 
		case 
			when @query is null then '""' 
			when @query = '' then '""'
			when @query = '""' then '""'
		else @query  end


	declare @tempResponse as table (
		IDContactoEmpleadoTipoNotificacion  int   
        ,IDTipoNotificacion  varchar(50)
        ,IDTemplateNotificacion int
        ,IDEmpleado int 
        ,ClaveEmpleado   varchar(255)
		,Cuenta   varchar(255)
        ,IDCliente   int
        ,NombreCompleto varchar(255)
        ,Valor VARCHAR(255)    
        ,IDMedioNotificacion  varchar(50)        
        ,MedioNotificacion  varchar(255)        
        ,IDContactoEmpleado int        			 
    );

    INSERT @tempResponse    
    select 
		s.IDContactoEmpleadoTipoNotificacion,
		s.IDTipoNotificacion,
		s.IDTemplateNotificacion,    
		s.IDEmpleado,    
		em.ClaveEmpleado,
		u.Cuenta,
		em.IDCliente,
		em.NOMBRECOMPLETO NombreCompleto, 
		CE.[Value] ,
		MN.IDMedioNotificacion,
		JSON_VALUE(MN.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion,
		isnull(s.IDContactoEmpleado,0) IDContactoEmpleado
    from RH.tblContactosEmpleadosTiposNotificaciones s
		INNER JOIN App.tblTiposNotificaciones AS TP on tp.IDTipoNotificacion=s.IDTipoNotificacion
		inner join App.tblTemplateNotificaciones Template on S.IDTipoNotificacion = Template.IDTipoNotificacion
		inner join App.tblMediosNotificaciones MN on MN.IDMedioNotificacion = Template.IDMedioNotificacion
		inner join Seguridad.tblUsuarios u on u.IDEmpleado=s.IDEmpleado
		inner join RH.tblEmpleadosMaster em on em.IDEmpleado=u.IDEmpleado
		left join RH.tblContactoEmpleado CE on CE.IDEmpleado = S.IDEmpleado and S.IDContactoEmpleado = CE.IDContactoEmpleado
	--	left join RH.tblCatTipoContactoEmpleado TCC on TCC.IDTipoContacto = CE.IDTipoContactoEmpleado    
    where s.IDTipoNotificacion = @IDTipoNotificacion and em.IDCliente=@IDCliente and (@query = '""' or u.Nombre like '%'+@query+'%' or u.Cuenta like '%'+@query+'%' or  u.Email like '%'+@query+'%') 
    order by u.Cuenta

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDTipoNotificacion) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Cuenta'			and @orderDirection = 'asc'		then Cuenta end,			
		case when @orderByColumn = 'Cuenta'			and @orderDirection = 'desc'	then Cuenta end desc,					
		Cuenta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
