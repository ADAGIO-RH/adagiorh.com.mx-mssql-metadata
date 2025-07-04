USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBuscarContactosUsuariosTiposNotificaciones] 
(
    @IDTipoNotificacion	varchar(50) = null,
    @IDCliente int =null 
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
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
			    IDContactoUsuarioTipoNotificacion  int   
                ,IDTipoNotificacion  varchar(50)
                ,IDTemplateNotificacion int
                ,IDUsuario int 
			    ,Cuenta   varchar(255)
                ,IDCliente   int
                ,NombreCompleto varchar(255)
                ,Email VARCHAR(255)                            			
    );

    INSERT @tempResponse
    select s.IDContactoUsuarioTipoNotificacion,
    s.IDTipoNotificacion,
    s.IDTemplateNotificacion,    
    s.IDUsuario,
    u.Cuenta,
    S.IDCliente,
    concat(u.Nombre,' ',u.Apellido) NombreCompleto  , 
    u.Email 
    from App.tblContactosUsuariosTiposNotificaciones s
    inner join Seguridad.tblUsuarios u on u.IDUsuario=s.IDUsuario
    where s.IDTipoNotificacion = @IDTipoNotificacion and s.IDCliente=@IDCliente and (@query = '""' or u.Nombre like '%'+@query+'%' or u.Cuenta like '%'+@query+'%' or  u.Email like '%'+@query+'%') 
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
